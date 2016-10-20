require 'yaml'
require 'json'
require 'erb'
require 'openssl'
require 'net/ssh'
require 'benchmark'

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
    if !File.exists?('wombat.yml')
      File.open('wombat.yml', 'w') do |f|
        f.puts File.read('wombat.example.yml')
      end
    end
    YAML.load(File.read('wombat.yml'))
  end

  def lock
    JSON.parse(File.read('wombat.lock'))
  end

  def bootstrap_aws
    @workstation_passwd = wombat['workstations']['password']
    rendered = ERB.new(File.read("#{conf['template_dir']}/bootstrap-aws.erb"), nil, '-').result(binding)
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
    if File.exists?("#{conf['packer_dir']}/file/infranodes-info.json")
      current_state = JSON(File.read('files/infranodes-info.json'))
    else
      current_state = nil
    end
    return if current_state == infranodes # yay idempotence
    File.open("#{conf['packer_dir']}/files/infranodes-info.json", 'w') do |f|
      f.puts JSON.pretty_generate(infranodes)
    end
  end

  def linux
    wombat['linux'].nil? ? 'ubuntu' : wombat['linux']
  end

  def conf
    conf = wombat['conf']
    conf ||= {}
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
end
