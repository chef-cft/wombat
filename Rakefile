require 'erb'
require 'json'
require 'openssl'
require 'net/ssh'
require 'yaml'
require 'parallel'

namespace :keys do
  desc 'create keys'
  task :create do
    %w(chef-server delivery compliance).each do |hostname|
      gen_x509_cert(hostname)
    end
    gen_ssh_key
  end
end

namespace :cookbook do
  desc 'Vendor cookbooks for a template'
  task :vendor, :template do |_t, args|
    has_cookbook = %w(workstation build-node delivery compliance infranodes chef-server)
    base = args[:template].split('.json')[0]
    if has_cookbook.any? { |t| args[:template].include? t }
      sh "rm -rf vendored-cookbooks/#{base}"
      sh "berks vendor -b cookbooks/#{base}/Berksfile vendored-cookbooks/#{base}"
    else
      puts 'No cookbooks - not vendoring'
    end
  end
end

namespace :packer do
  desc 'Build an AMI'
  task :build_ami, :template do |_t, args|
    Rake::Task['cookbook:vendor'].invoke(args[:template])
    Rake::Task['cookbook:vendor'].reenable
    sh packer_build(args[:template], 'amazon-ebs')
  end

  desc 'Build all AMIs'
  task :build_amis do
    templates.each do |template|
      Rake::Task['packer:build_ami'].invoke("#{template}.json")
      Rake::Task['packer:build_ami'].reenable
    end
  end

  desc 'Build all AMIs in parallel'
  task :build_amis_parallel do
    parallel_pack(templates)
  end
end

desc 'Create/Update lockfile'
task :update_lock do
  copy = {}
  copy = wombat
  region = copy['aws']['region']
  puts 'Updating lockfile based on most recent packer logs'
  copy['amis'] = { region => {} }
  templates.each do |instance|
    if instance == 'build-node'
      copy['amis'][region].store('build-node', {})
      1.upto(wombat['build-nodes'].to_i) do |i|
        copy['amis'][region]['build-node'].store(i.to_s, parse_ami("build-node-#{i}"))
      end
    else
      copy['amis'][region].store(instance, parse_ami(instance))
    end
  end
  copy['last_updated'] = Time.now.gmtime.strftime('%Y%m%d%H%M%S')
  File.open('wombat.lock', 'w') do |f|
    f.write(JSON.pretty_generate(copy))
  end
end

namespace :cfn do
  desc 'Generate Cloud Formation Template'
  task :create_template do
    puts 'Generating CloudFormation template from lockfile'
    region = lock['aws']['region']
    @chef_server_ami = lock['amis'][region]['chef-server']
    @delivery_ami = lock['amis'][region]['delivery']
    @build_nodes = lock['build-nodes'].to_i
    @build_node_ami = {}
    1.upto(@build_nodes) do |i|
      @build_node_ami[i] = lock['amis'][region]['build-node'][i.to_s]
    end
    @workstation_ami = lock['amis'][region]['workstation']
    @az = lock['aws']['az']
    @demo = lock['name']
    rendered_cfn = ERB.new(File.read('cloudformation/cfn.json.erb'), nil, '-').result
    File.open("cloudformation/#{@demo}.json", 'w') { |file| file.puts rendered_cfn }
    puts "Generated cloudformation/#{@demo}.json"
  end

  desc 'Deploy a CloudFormation Stack from template'
  task :deploy_stack do
    sh create_stack(lock['name'], lock['aws']['region'], lock['aws']['keypair'])
  end

  desc 'Build AMIs, update lockfile, and create CFN template'
  task do_all: ['packer:build_amis', 'packer:update_amis', 'cfn:create_template']
end

namespace :tf do
  desc 'Update AMIS in tfvars'
  task :update_amis, :chef_server_ami, :delivery_ami, :build_node_ami, :workstation_ami do |_t, args|
    chef_server = args[:chef_server_ami] || File.read('./packer/logs/ami-chef-server.log').split("\n").last.split(' ')[1]
    delivery = args[:delivery_ami] || File.read('./packer/logs/ami-delivery.log').split("\n").last.split(' ')[1]
    builder = args[:build_node_ami] || File.read('./packer/logs/ami-build-node.log').split("\n").last.split(' ')[1]
    workstation = args[:workstation_ami] || File.read('./packer/logs/ami-workstation.log').split("\n").last.split(' ')[1]
    raise 'packer build logs not found, nor were image ids provided' unless chef_server && delivery && builder && workstation
    puts 'Updating tfvars based on most recent packer logs'
    @chef_server_ami = chef_server
    @delivery_ami = delivery
    @build_node_ami = builder
    @workstation_ami = workstation
    rendered_tfvars = ERB.new(File.read('terraform/templates/terraform.tfvars.erb')).result
    File.open('terraform/terraform.tfvars', 'w') { |file| file.puts rendered_tfvars }
    puts "\n" + rendered_tfvars
  end

  desc 'Terraform plan'
  task :plan do
    sh 'cd terraform && terraform plan'
  end

  desc 'Terraform apply'
  task :apply do
    sh 'cd terraform && terraform apply'
  end

  desc 'Terraform destroy'
  task :destroy do
    sh 'cd terraform && terraform destroy -force'
  end
end

def packer_build(template, builder)
  create_infranodes_json
  base = template == 'build-node' ? 'build-node-1' : template
  cmd = %W(packer build packer/#{template}.json | tee packer/logs/ami-#{base}.log)
  cmd.insert(2, "--only #{builder}")
  cmd.insert(2, "--var org=#{wombat['org']}") unless base =~ /delivery/
  cmd.insert(2, "--var domain=#{wombat['domain']}")
  cmd.insert(2, "--var enterprise=#{wombat['enterprise']}") unless base =~ /chef-server/
  cmd.insert(2, "--var chefdk=#{wombat['products']['chefdk']}") unless base =~ /chef-server/
  cmd.insert(2, "--var delivery=#{wombat['products']['delivery']}") if base =~ /delivery/
  cmd.insert(2, "--var chef-server=#{wombat['products']['chef-server']}") if base =~ /chef-server/
  cmd.insert(2, "--var build-nodes=#{wombat['build-nodes']}")
  cmd.join(' ')
end

def create_stack(stack, region, keypair)
  template_file = "file://#{File.dirname(__FILE__)}/cloudformation/#{stack}.json"
  timestamp = Time.now.gmtime.strftime('%Y%m%d%H%M%S')
  cmd = %w(aws cloudformation create-stack)
  cmd.insert(3, "--template-body #{template_file}")
  cmd.insert(3, "--parameters ParameterKey='KeyName',ParameterValue='#{keypair}'")
  cmd.insert(3, "--region #{region}")
  cmd.insert(3, "--stack-name #{stack}-#{timestamp}")
  cmd.join(' ')
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

def gen_x509_cert(hostname)
  rsa_key = OpenSSL::PKey::RSA.new(2048)
  public_key = rsa_key.public_key

  subject = "/C=AU/ST=New South Wales/L=Sydney/O=#{wombat['org']}/OU=wombats/CN=#{hostname}.#{wombat['domain']}"

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
  key_dir = 'packer/keys'

  if File.exist?("#{key_dir}/#{hostname}.crt") && File.exist?("#{key_dir}/#{hostname}.key")
    puts "An x509 certificate already exists for #{hostname}, please remove and re-run"
  else
    File.open("#{key_dir}/#{hostname}.crt", 'w') { |file| file.puts cert.to_pem }
    File.open("#{key_dir}/#{hostname}.key", 'w') { |file| file.puts rsa_key.to_pem }
    puts "Certificate created for #{hostname}.#{wombat['domain']}"
  end
end

def gen_ssh_key
  rsa_key = OpenSSL::PKey::RSA.new 2048

  type = rsa_key.ssh_type
  data = [rsa_key.to_blob].pack('m0')

  openssh_format = "#{type} #{data}"
  key_dir = 'packer/keys'

  if File.exist?("#{key_dir}/public.pub") && File.exist?("#{key_dir}/private.pem")
    puts 'An SSH keypair already exists, please remove and re-run'
  else
    File.open("#{key_dir}/public.pub", 'w') { |file| file.puts openssh_format }
    File.open("#{key_dir}/private.pem", 'w') { |file| file.puts rsa_key.to_pem }
    puts 'SSH Keypair created'
  end
end

def templates
  %w(build-node compliance chef-server delivery workstation)
end

def parse_ami(instance)
  log_dir = 'packer/logs'
  File.read("#{log_dir}/ami-#{instance}.log").split("\n").last.split(' ')[1]
end

def parallel_pack(templates)
  Parallel.map(templates, in_processes: templates.count) do |template|
    sh packer_build(template, 'amazon-ebs')
  end
end

def create_infranodes_json
  infranodes = wombat['infranodes'] || {}
  if File.exists?('packer/file/infranodes-info.json')
    current_state = JSON(File.read('files/infranodes-info.json'))
  else
    current_state = nil
  end
  return if current_state == infranodes #yay idempotence 
  File.open('packer/files/infranodes-info.json', 'w') do |f|
    f.puts JSON.pretty_generate(infranodes)
  end
end
