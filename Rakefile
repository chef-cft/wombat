require 'erb'
require 'json'
require 'openssl'
require 'net/ssh'

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
  task :vendor, :template do |t, args|
    has_cookbook = %w(workstation build-node delivery)
    base = args[:template].split('.json')[0]
    if has_cookbook.any? { |t| args[:template].include? t }
      sh "rm -rf packer/vendored-cookbooks/#{base}"
      sh "berks vendor -b packer/cookbooks/#{base}/Berksfile packer/vendored-cookbooks/#{base}"
    else
      puts 'No cookbooks - not vendoring'
    end
  end
end

namespace :aws do
  desc 'Pack an AMI'
  task :pack_ami, :template do |t, args|
    Rake::Task['cookbook:vendor'].invoke(args[:template])
    Rake::Task['cookbook:vendor'].reenable
    sh packer_build(args[:template], 'amazon-ebs')
  end

  desc 'Pack AMIs'
  task :pack_amis do
    %w(chef-server delivery build-node workstation).each do |template|
      Rake::Task['aws:pack_ami'].invoke("#{template}.json")
      Rake::Task['aws:pack_ami'].reenable
    end
  end

  desc 'Update AMIS in wombat.json'
  task :update_amis, :chef_server_ami, :delivery_ami, :build_node_ami, :workstation_ami do |t, args|
    copy = {}
    copy = wombat
    region = copy['aws']['region']
    copy['amis'][region]['chef-server'] = args[:chef_server_ami] || File.read('./packer/logs/ami-chef-server.log').split("\n").last.split(" ")[1]
    copy['amis'][region]['delivery'] = args[:delivery_ami] || File.read('./packer/logs/ami-delivery.log').split("\n").last.split(" ")[1]
    copy['amis'][region]['build-node']['1'] = args[:build_node_ami] || File.read('./packer/logs/ami-build-node.log').split("\n").last.split(" ")[1]
    copy['amis'][region]['workstation'] = args[:workstation_ami] || File.read('./packer/logs/ami-workstation.log').split("\n").last.split(" ")[1]
    copy['last_updated'] = Time.now.gmtime.strftime("%Y%m%d%H%M%S")
    # fail "packer build logs not found, nor were image ids provided" unless chef_server && delivery && builder && workstation
    puts "Updating wombat.json based on most recent packer logs"
    File.open("wombat.json","w") do |f|
      f.write(JSON.pretty_generate(copy))
    end
  end

  desc 'Generate Cloud Formation Template'
  task :create_cfn_template do
    puts "Generate CloudFormation template"
    region = wombat['aws']['region']
    @chef_server_ami = wombat['amis'][region]['chef-server']
    @delivery_ami = wombat['amis'][region]['delivery']
    @build_nodes = wombat['build-nodes'].to_i
    @build_node_ami = {}
    1.upto(@build_nodes) do |i|
      @build_node_ami[i] = wombat['amis'][region]["build-node"][i.to_s]
    end
    @workstation_ami = wombat['amis'][region]['workstation']
    @az = wombat['aws']['az']
    @demo = wombat['name']
    rendered_cfn = ERB.new(File.read('cloudformation/cfn.json.erb'),nil,'-').result
    File.open("cloudformation/#{@demo}.json", "w") {|file| file.puts rendered_cfn }
    puts "Created cloudformation/#{@demo}.json"
  end

  desc 'Create a Stack from a CloudFormation template'
  task :create_cfn_stack do
    sh create_stack(wombat['name'], wombat['aws']['region'], wombat['aws']['keypair'])
  end

  desc 'Build a CloudFormation stack'
  task build_cfn_stack: ['aws:pack_amis', 'aws:update_amis', 'aws:create_cfn_template']
end

namespace :tf do
  desc 'Update AMIS in tfvars'
  task :update_amis, :chef_server_ami, :delivery_ami, :build_node_ami, :workstation_ami do |t, args|
    chef_server = args[:chef_server_ami] || File.read('./packer/logs/ami-chef-server.log').split("\n").last.split(" ")[1]
    delivery = args[:delivery_ami] || File.read('./packer/logs/ami-delivery.log').split("\n").last.split(" ")[1]
    builder = args[:build_node_ami] || File.read('./packer/logs/ami-build-node.log').split("\n").last.split(" ")[1]
    workstation = args[:workstation_ami] || File.read('./packer/logs/ami-workstation.log').split("\n").last.split(" ")[1]
    fail "packer build logs not found, nor were image ids provided" unless chef_server && delivery && builder && workstation
    puts "Updating tfvars based on most recent packer logs"
    @chef_server_ami = chef_server
    @delivery_ami = delivery
    @build_node_ami = builder
    @workstation_ami = workstation
    rendered_tfvars = ERB.new(File.read('terraform/templates/terraform.tfvars.erb')).result
    File.open('terraform/terraform.tfvars', "w") {|file| file.puts rendered_tfvars }
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
  base = template.split('.json')[0]
  cmd = %W(packer build packer/#{template} | tee packer/logs/ami-#{base}.log)
  cmd.insert(2, "--only #{builder}")
  cmd.insert(2, "--var org='#{wombat['org']}'") if !(base =~ /delivery/)
  cmd.insert(2, "--var domain='#{wombat['domain']}'")
  cmd.insert(2, "--var enterprise='#{wombat['enterprise']}'") if !(base =~ /chef-server/)
  cmd.insert(2, "--var chefdk='#{wombat['products']['chefdk']}'") if !(base =~ /chef-server/)
  cmd.insert(2, "--var delivery='#{wombat['products']['delivery']}'") if (base =~ /delivery/)
  cmd.insert(2, "--var chef-server='#{wombat['products']['chef-server']}'") if (base =~ /chef-server/)
  cmd.insert(2, "--var build-nodes='#{wombat['build-nodes']}'")
  cmd.join(' ')
end

def create_stack(stack, region, keypair)
  template_file = "file://#{File.dirname(__FILE__)}/cloudformation/#{stack}.json"
  timestamp = Time.now.gmtime.strftime("%Y%m%d%H%M%S")
  cmd = %W(aws cloudformation create-stack)
  cmd.insert(3, "--template-body #{template_file}")
  cmd.insert(3, "--parameters ParameterKey='KeyName',ParameterValue='#{keypair}'")
  cmd.insert(3, "--region #{region}")
  cmd.insert(3, "--stack-name #{stack}-#{timestamp}")
  cmd.join(' ')
end

def wombat
  file = File.read('wombat.json')
  hash = JSON.parse(file)
end

def version(thing)
  wombat['pkg-versions'][thing]
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
    ef.create_extension("basicConstraints","CA:TRUE", true),
    ef.create_extension("subjectKeyIdentifier", "hash"),
    # ef.create_extension("keyUsage", "cRLSign,keyCertSign", true),
  ]
  cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                        "keyid:always,issuer:always")

  cert.sign(rsa_key, OpenSSL::Digest::SHA256.new)
  key_dir = 'packer/keys'

  if File.exist?("#{key_dir}/#{hostname}.crt") && File.exist?("#{key_dir}/#{hostname}.key")
    puts "An x509 certificate already exists for #{hostname}, please remove and re-run"
  else
    File.open("#{key_dir}/#{hostname}.crt", "w") {|file| file.puts cert.to_pem }
    File.open("#{key_dir}/#{hostname}.key", "w") {|file| file.puts rsa_key.to_pem }
    puts "Certificate created for #{hostname}.#{wombat['domain']}"
  end
end

def gen_ssh_key
  rsa_key = OpenSSL::PKey::RSA.new 2048

  type = rsa_key.ssh_type
  data = [ rsa_key.to_blob ].pack('m0')

  openssh_format = "#{type} #{data}"
  key_dir = 'packer/keys'

  if File.exist?("#{key_dir}/public.pub") && File.exist?("#{key_dir}/private.pem")
    puts "An SSH keypair already exists, please remove and re-run"
  else
    File.open("#{key_dir}/public.pub", "w") {|file| file.puts openssh_format }
    File.open("#{key_dir}/private.pem", "w") {|file| file.puts rsa_key.to_pem }
    puts 'SSH Keypair created'
  end
end