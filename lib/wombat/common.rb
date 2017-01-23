require 'yaml'
require 'json'
require 'erb'
require 'openssl'
require 'net/ssh'
require 'benchmark'
require 'fileutils'

module Common

  def banner(msg)
    puts "==> #{msg}"
  end

  def info(msg)
    puts "    #{msg}"
  end

  def warn(msg)
    puts ">>> #{msg}"
  end

  def duration(total)
    total = 0 if total.nil?
    minutes = (total / 60).to_i
    seconds = (total - (minutes * 60))
    format("%dm%.2fs", minutes, seconds)
  end

  def wombat
    @wombat_yml ||= ENV['WOMBAT_YML'] unless ENV['WOMBAT_YML'].nil?
    @wombat_yml ||= 'wombat.yml'
    if !File.exists?(@wombat_yml)
      warn('No wombat.yml found, copying example')
      gen_dir = "#{File.expand_path("../..", File.dirname(__FILE__))}/generator_files"
      FileUtils.cp_r "#{gen_dir}/wombat.yml", Dir.pwd
    end
    YAML.load(File.read(@wombat_yml))
  end

  def lock
    if !File.exist?('wombat.lock')
      warn('No wombat.lock found')
      return 1
    else
      JSON.parse(File.read('wombat.lock'))
    end
  end

  def bootstrap_aws
    @workstation_passwd = wombat['workstations']['password']
    rendered = ERB.new(File.read("#{conf['template_dir']}/bootstrap-aws.erb"), nil, '-').result(binding)
    Dir.mkdir("#{conf['packer_dir']}/scripts", 0755) unless File.exist?("#{conf['packer_dir']}/scripts")
    File.open("#{conf['packer_dir']}/scripts/bootstrap-aws.txt", 'w') { |file| file.puts rendered }
    banner("Generated: #{conf['packer_dir']}/scripts/bootstrap-aws.txt")
  end

  def gen_x509_cert(hostname)
    rsa_key = OpenSSL::PKey::RSA.new(2048)
    public_key = rsa_key.public_key

    subject = "/C=AU/ST=New South Wales/L=Sydney/O=#{wombat['org']}/OU=wombats/CN=#{wombat['domain_prefix']}#{hostname}.#{wombat['domain']}"

    cert = OpenSSL::X509::Certificate.new
    cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
    cert.not_before = Time.now
    cert.not_after = Time.now + 365 * 24 * 60 * 60
    cert.public_key = public_key
    cert.serial = 0x0
    cert.version = 2

    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = cert
    cert.extensions = [
      ef.create_extension('basicConstraints', 'CA:TRUE', true),
      ef.create_extension('subjectKeyIdentifier', 'hash'),
      # ef.create_extension("keyUsage", "cRLSign,keyCertSign", true),
    ]
    cert.add_extension ef.create_extension('authorityKeyIdentifier',
                                           'keyid:always,issuer:always')

    cert.sign(rsa_key, OpenSSL::Digest::SHA256.new)

    Dir.mkdir(conf['key_dir'], 0755) unless File.exist?(conf['key_dir'])

    if File.exist?("#{conf['key_dir']}/#{hostname}.crt") && File.exist?("#{conf['key_dir']}/#{hostname}.key")
      puts "An x509 certificate already exists for #{hostname}"
    else
      File.open("#{conf['key_dir']}/#{hostname}.crt", 'w') { |file| file.puts cert.to_pem }
      File.open("#{conf['key_dir']}/#{hostname}.key", 'w') { |file| file.puts rsa_key.to_pem }
      puts "Certificate created for #{wombat['domain_prefix']}#{hostname}.#{wombat['domain']}"
    end
  end

  def gen_ssh_key
    rsa_key = OpenSSL::PKey::RSA.new 2048

    type = rsa_key.ssh_type
    data = [rsa_key.to_blob].pack('m0')

    openssh_format = "#{type} #{data}"

    Dir.mkdir(conf['key_dir'], 0755) unless File.exist?(conf['key_dir'])

    if File.exist?("#{conf['key_dir']}/public.pub") && File.exist?("#{conf['key_dir']}/private.pem")
      puts 'An SSH keypair already exists'
    else
      File.open("#{conf['key_dir']}/public.pub", 'w') { |file| file.puts openssh_format }
      File.open("#{conf['key_dir']}/private.pem", 'w') { |file| file.puts rsa_key.to_pem }
      puts 'SSH Keypair created'
    end
  end

  def parse_log(log, cloud)
    regex = cloud == 'gcp' ? "A disk image was created:" : "#{wombat['aws']['region']}:"
    File.read(log).split("\n").grep(/#{regex}/) {|x| x.split[1]}.last
  end

  def infranodes
    unless wombat['infranodes'].nil?
      wombat['infranodes'].sort
    else
      puts 'No infranodes listed in wombat.yml'
      {}
    end
  end

  def build_nodes
    build_nodes = {}
    1.upto(wombat['build-nodes']['count'].to_i) do |i|
      build_nodes["build-node-#{i}"] = i
    end
    build_nodes
  end

  def workstations
    workstations = {}
    1.upto(wombat['workstations']['count'].to_i) do |i|
      workstations["workstation-#{i}"] = i
    end
    workstations
  end

  def create_infranodes_json
    infranodes_file_path = File.join(conf['files_dir'], 'infranodes-info.json')
    if File.exists?(infranodes_file_path) && is_valid_json?(infranodes_file_path)
      current_state = JSON(File.read(infranodes_file_path))
    else
      current_state = nil
    end
    return if current_state == infranodes # yay idempotence
    File.open(infranodes_file_path, 'w') do |f|
      f.puts JSON.pretty_generate(infranodes)
    end
  end

  def linux
    wombat['linux'].nil? ? 'ubuntu' : wombat['linux']
  end

  def conf
    conf = wombat['conf']
    conf ||= {}
    conf['files_dir'] ||= 'files'
    conf['key_dir'] ||= 'keys'
    conf['cookbook_dir'] ||= 'cookbooks'
    conf['packer_dir'] ||= 'packer'
    conf['log_dir'] ||= 'logs'
    conf['stack_dir'] ||= 'stacks'
    conf['template_dir'] ||= 'templates'
    conf['timeout'] ||= 7200
    conf['audio'] ||= false
    conf
  end

  def is_mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def audio?
    is_mac? && conf['audio']
  end

  def logs
    Dir.glob("#{conf['log_dir']}/#{cloud}*.log").reject { |l| !l.match(wombat['linux']) }
  end

  def calculate_templates
  globs = "*.json"
    Dir.chdir(conf['packer_dir']) do
      Array(globs).
        map { |glob| result = Dir.glob("#{glob}"); result.empty? ? glob : result }.
        flatten.
        sort.
        delete_if { |file| file =~ /\.variables\./ }.
        map { |template| template.sub(/\.json$/, '') }
    end
  end

  def update_lock(cloud)
    copy = {}
    copy = wombat
    region = copy[cloud]['region']
    linux = copy['linux']
    copy['amis'] = { region => {} }

    if logs.length == 0
      warn('No logs found - skipping lock update')
    else
      logs.each do |log|
        case log
        when /build-node/
          copy['amis'][region]['build-node'] ||= {}
          num = log.split('-')[3]
          copy['amis'][region]['build-node'].store(num, parse_log(log, cloud))
        when /workstation/
          copy['amis'][region]['workstation'] ||= {}
          num = log.split('-')[2]
          copy['amis'][region]['workstation'].store(num, parse_log(log, cloud))
        when /infranodes/
          copy['amis'][region]['infranodes'] ||= {}
          name = log.split('-')[2]
          copy['amis'][region]['infranodes'].store(name, parse_log(log, cloud))
        else
          instance = log.match("#{cloud}-(.*)-#{linux}\.log")[1]
          copy['amis'][region].store(instance, parse_log(log, cloud))
        end
      end
      copy['last_updated'] = Time.now.gmtime.strftime('%Y%m%d%H%M%S')
      banner('Updating wombat.lock')
      File.open('wombat.lock', 'w') do |f|
        f.write(JSON.pretty_generate(copy))
      end
    end
  end

  def update_template(cloud)
    if lock == 1
      warn('No lock - skipping template creation')
    else
      region = lock['aws']['region']
      @chef_server_ami = lock['amis'][region]['chef-server']
      @automate_ami = lock['amis'][region]['automate']
      @compliance_ami = lock['amis'][region]['compliance']
      @build_nodes = lock['build-nodes']['count'].to_i
      @build_node_ami = {}
      1.upto(@build_nodes) do |i|
        @build_node_ami[i] = lock['amis'][region]['build-node'][i.to_s]
      end
      @infra = {}
      infranodes.each do |name, _rl|
        @infra[name] = lock['amis'][region]['infranodes'][name]
      end
      @workstations = lock['workstations']['count'].to_i
      @workstation_ami = {}
      1.upto(@workstations) do |i|
        @workstation_ami[i] = lock['amis'][region]['workstation'][i.to_s]
      end
      @availability_zone = lock['aws']['az']
      @iam_roles = lock['aws']['iam_roles']
      @demo = lock['name']
      @version = lock['version']
      @ttl = lock['ttl']
      rendered_cfn = ERB.new(File.read("#{conf['template_dir']}/cfn.json.erb"), nil, '-').result(binding)
      Dir.mkdir(conf['stack_dir'], 0755) unless File.exist?(conf['stack_dir'])
      File.open("#{conf['stack_dir']}/#{@demo}.json", 'w') { |file| file.puts rendered_cfn }
      banner("Generated: #{conf['stack_dir']}/#{@demo}.json")
    end
  end
  
  def is_valid_json?(file)
    begin
      JSON.parse(file)
      true
    rescue JSON::ParserError => e
      false
    end
  end
end
