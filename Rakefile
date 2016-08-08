require 'erb'
require 'json'
require 'openssl'
require 'net/ssh'
require 'yaml'
require 'parallel'
require 'aws-sdk'

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
    has_cookbook = %w(build-node compliance chef-server delivery infranodes workstation)
    base = args[:template].split('.json')[0]
    if has_cookbook.any? { |t| args[:template].include? t }
      sh "rm -rf vendored-cookbooks/#{base}"
      sh "rm -rf cookbooks/#{base}/Berksfile.lock"
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

  desc 'Build all infranodes listed in wombat.yml'
  task :build_infra do
    Rake::Task['cookbook:vendor'].invoke('infranodes')
    Rake::Task['cookbook:vendor'].reenable
    infranodes.each do |name, _rl|
      sh packer_build('infranodes', 'amazon-ebs', {'node-name' => name})
    end
  end

  desc 'Build all build-nodes'
  task :build_build_nodes do
    Rake::Task['cookbook:vendor'].invoke('build-node')
    Rake::Task['cookbook:vendor'].reenable
    build_nodes.each do |name, num|
      sh packer_build('build-node', 'amazon-ebs', {'node-number' => num})
    end
  end

  desc 'Build all AMIs'
  task :build_amis do
    templates.each do |template|
      Rake::Task['packer:build_ami'].invoke("#{template}")
      Rake::Task['packer:build_ami'].reenable
    end
    %w(build_nodes infra).each do |t|
      Rake::Task["packer:build_#{t}"].invoke
      Rake::Task["packer:build_#{t}"].reenable
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
    elsif instance == 'infranodes'
      copy['amis'][region].store('infranodes', {})
      infranodes.each do |name, _rl|
        copy['amis'][region]['infranodes'].store(name, parse_ami("infranodes-#{name}"))
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
    @compliance_ami = lock['amis'][region]['compliance']
    @build_nodes = lock['build-nodes'].to_i
    @build_node_ami = {}
    1.upto(@build_nodes) do |i|
      @build_node_ami[i] = lock['amis'][region]['build-node'][i.to_s]
    end
    @infra = {}
    infranodes.each do |name, _rl|
      @infra[name] = lock['amis'][region]['infranodes'][name]
    end
    @workstation_ami = lock['amis'][region]['workstation']
    @availability_zone = lock['aws']['az']
    @demo = lock['name']
    @version = lock['version']
    rendered_cfn = ERB.new(File.read('cloudformation/cfn.json.erb'), nil, '-').result
    File.open("cloudformation/#{@demo}.json", 'w') { |file| file.puts rendered_cfn }
    puts "Generated cloudformation/#{@demo}.json"
  end

  desc 'Deploy a CloudFormation stack from template'
  task :create_stack do
    create_stack(lock['name'])
  end

  desc 'Destroy a CloudFormation stack'
  task :destroy_stack, [:stack_name] do |task, args|
    destroy_stack(args[:stack_name])
  end

  desc 'List workstation IPs of a CloudFormation stack'
  task :list_ips, [:stack_name] do |task, args|
    get_workstation_ips(args[:stack_name])
  end

  desc 'Build AMIs, update lockfile, and create CFN template'
  task do_all: ['packer:build_amis', 'update_lock', 'cfn:create_template']
end

namespace :tf do
  desc 'Update AMIS in tfvars'
  task :update_amis, :chef_server_ami, :delivery_ami, :build_node_ami, :workstation_ami do |_t, args|
    chef_server = args[:chef_server_ami] || File.read('./packer/logs/ami-chef-server.log').split("\n").last.split(' ')[1]
    delivery = args[:delivery_ami] || File.read('./packer/logs/ami-delivery.log').split("\n").last.split(' ')[1]
    compliance = args[:compliance_ami] || File.read('./packer/logs/ami-compliance.log').split("\n").last.split(' ')[1]
    builder = args[:build_node_ami] || File.read('./packer/logs/ami-build-node.log').split("\n").last.split(' ')[1]
    workstation = args[:workstation_ami] || File.read('./packer/logs/ami-workstation.log').split("\n").last.split(' ')[1]
    raise 'packer build logs not found, nor were image ids provided' unless chef_server && delivery && builder && workstation
    puts 'Updating tfvars based on most recent packer logs'
    @chef_server_ami = chef_server
    @delivery_ami = delivery
    @compliance_ami = compliance
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

def packer_build(template, builder, options={})
  create_infranodes_json
  if template == 'build-node'
     log_name = "build-node-#{options['node-number']}"
  elsif template == 'infranodes'
     log_name = "infranodes-#{options['node-name']}"
  else
     log_name = template
  end

  if template == 'workstation'
    source_ami = wombat['aws']['source_ami']['windows']
  else
    source_ami = wombat['aws']['source_ami']['ubuntu']
  end

  if ENV['AWS_REGION']
    puts "Region set by environment: #{ENV['AWS_REGION']}"
  else
    puts "$AWS_REGION not set, setting to #{wombat['aws']['region']}"
    ENV['AWS_REGION'] = wombat['aws']['region']
  end

  cmd = %W(packer build packer/#{template}.json | tee packer/logs/ami-#{log_name}.log)
  cmd.insert(2, "--only #{builder}")
  cmd.insert(2, "--var org=#{wombat['org']}")
  cmd.insert(2, "--var domain=#{wombat['domain']}")
  cmd.insert(2, "--var domain_prefix=#{wombat['domain_prefix']}")
  cmd.insert(2, "--var enterprise=#{wombat['enterprise']}")
  cmd.insert(2, "--var chefdk=#{wombat['products']['chefdk']}")
  cmd.insert(2, "--var delivery=#{wombat['products']['delivery']}")
  cmd.insert(2, "--var compliance=#{wombat['products']['compliance']}")
  cmd.insert(2, "--var chef-server=#{wombat['products']['chef-server']}")
  cmd.insert(2, "--var node-name=#{options['node-name']}") if template =~ /infranodes/
  cmd.insert(2, "--var node-number=#{options['node-number']}") if template =~ /build-node/
  cmd.insert(2, "--var build-nodes=#{wombat['build-nodes']}")
  cmd.insert(2, "--var source_ami=#{source_ami}")
  cmd.join(' ')
end

def create_stack(stack_name)
  template_file = File.read("#{File.dirname(__FILE__)}/cloudformation/#{stack_name}.json")
  timestamp = Time.now.gmtime.strftime('%Y%m%d%H%M%S')
  cfn = Aws::CloudFormation::Client.new(region: lock['aws']['region'])

  puts "Creating CFN stack: #{stack_name}-#{timestamp}\n"
  resp = cfn.create_stack({
    stack_name: "#{stack_name}-#{timestamp}",
    template_body: template_file,
    capabilities: ["CAPABILITY_IAM"],
    parameters: [
      {
        parameter_key: "KeyName",
        parameter_value: lock['aws']['keypair'],
      }
    ]
  })
end

def destroy_stack(stack_name)
  cfn = Aws::CloudFormation::Client.new(region: lock['aws']['region'])

  resp = cfn.delete_stack({
    stack_name: stack_name,
  })
  puts "Destroying CFN stack: #{stack_name}"
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
  key_dir = 'packer/keys'

  if File.exist?("#{key_dir}/#{hostname}.crt") && File.exist?("#{key_dir}/#{hostname}.key")
    puts "An x509 certificate already exists for #{hostname}, please remove and re-run"
  else
    File.open("#{key_dir}/#{hostname}.crt", 'w') { |file| file.puts cert.to_pem }
    File.open("#{key_dir}/#{hostname}.key", 'w') { |file| file.puts rsa_key.to_pem }
    puts "Certificate created for #{wombat['domain_prefix']}#{hostname}.#{wombat['domain']}"
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
  %w(build-node compliance chef-server delivery infranodes workstation)
end

def parse_ami(instance)
  log_dir = 'packer/logs'
  File.read("#{log_dir}/ami-#{instance}.log").split("\n").grep(/#{wombat['aws']['region']}:/) {|x| x.split[1]}.last
end

def parallel_pack(templates)
  proc_hash = {}
  templates.each do |template_name|
    if template_name == 'infranodes'
      infranodes.each do |name, _rl|
        next if name.empty?
        proc_hash[name] = {
          'template' => 'infranodes',
          'options' => {
            'node-name' => name
          }
        }
      end
    elsif template_name == 'build-node'
      build_nodes.each do |name, num|
        proc_hash[name] = {
          'template' => 'build-node',
          'options' => {
            'node-number' => num
          }
        }
      end
    else
      proc_hash[template_name] = {
        'template' => template_name,
        'options' => {}
      }
    end
  end
  puts proc_hash
  Parallel.map(proc_hash.keys, in_processes: proc_hash.count) do |name|
    Rake::Task['cookbook:vendor'].invoke(proc_hash[name]['template'])
    Rake::Task['cookbook:vendor'].reenable
    sh packer_build(proc_hash[name]['template'], 'amazon-ebs', proc_hash[name]['options'])
  end
end

def infranodes
  unless wombat['infranodes'].empty?
    wombat['infranodes'].sort
  else
    {}
  end
end

def build_nodes
  build_nodes = {}
  1.upto(wombat['build-nodes'].to_i) do |i|
    build_nodes["build-node-#{i}"] = i
  end
  build_nodes
end

def create_infranodes_json
  if File.exists?('packer/file/infranodes-info.json')
    current_state = JSON(File.read('files/infranodes-info.json'))
  else
    current_state = nil
  end
  return if current_state == infranodes # yay idempotence
  File.open('packer/files/infranodes-info.json', 'w') do |f|
    f.puts JSON.pretty_generate(infranodes)
  end
end

def get_stack_instances(stack_name)
  cfn = Aws::CloudFormation::Client.new
  resp = cfn.describe_stack_resources({
    stack_name: stack_name,
    })

  instances = {}
  resp.stack_resources.map do |resource|
    if resource.resource_type == 'AWS::EC2::Instance'
      instances[resource.logical_resource_id] = resource.physical_resource_id
    end
  end
  instances
end

def get_workstation_ips(stack_name)
  ec2 = Aws::EC2::Resource.new
  instances = get_stack_instances(stack_name)
  instances.each do |name, id|
    instance = ec2.instance(id)
    if /Workstation/.match(name)
      puts "#{name} (#{id}) => #{instance.public_ip_address}"
    end
  end
end
