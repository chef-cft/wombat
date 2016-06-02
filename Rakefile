require 'erb'
require 'json'

namespace :vendor do
  desc 'Vendor build-node cookbooks'
  task :build_node do
    sh 'rm -rf packer/vendored-cookbooks/build-node'
    sh 'berks vendor -b packer/cookbooks/build-node/Berksfile packer/vendored-cookbooks/build-node'
  end

  desc 'Vendor workstation cookbooks'
  task :workstation do
    sh 'rm -rf packer/vendored-cookbooks/workstation'
    sh 'berks vendor -b packer/cookbooks/workstation/Berksfile packer/vendored-cookbooks/workstation'
  end
end

desc 'Vendor all cookbooks'
task vendor: ['vendor:build-node', 'vendor:workstation']

namespace :aws do
  desc 'Pack an AMI'
  task :pack_ami, :template do |t, args|
    sh packer_build(args[:template], 'amazon-ebs')
  end

  desc 'Pack AMIs'
  task :pack_amis do
    %w(chef-server delivery-server delivery-builder workstation).each do |template|
      Rake::Task['aws:pack_ami'].invoke("#{template}.json")
      Rake::Task['aws:pack_ami'].reenable
    end
  end

  desc 'Update AMIS in wombat.json'
  task :update_amis, :chef_server_ami, :delivery_server_ami, :delivery_builder_ami, :workstation_ami do |t, args|
    wombat['aws']['amis'][ENV['AWS_REGION']]['chef-server'] = args[:chef_server_ami] || File.read('./packer/logs/ami-chef-server.log').split("\n").last.split(" ")[1]
    wombat['aws']['amis'][ENV['AWS_REGION']]['delivery'] = args[:delivery_server_ami] || File.read('./packer/logs/ami-delivery-server.log').split("\n").last.split(" ")[1]
    wombat['aws']['amis'][ENV['AWS_REGION']]['delivery-builder'] = args[:delivery_builder_ami] || File.read('./packer/logs/ami-delivery-builder.log').split("\n").last.split(" ")[1]
    wombat['aws']['amis'][ENV['AWS_REGION']]['workstation'] = args[:workstation_ami] || File.read('./packer/logs/ami-workstation.log').split("\n").last.split(" ")[1]
    # fail "packer build logs not found, nor were image ids provided" unless chef_server && delivery && builder && workstation
    puts "Updating wombat.json based on most recent packer logs"
    File.open("wombat.json","w") do |f|
      f.write(JSON.pretty_generate(wombat))
    end
  end

  desc 'Generate Cloud Formation Template'
  task :create_cfn_template do
    puts "Generate CloudFormation template"
    @chef_server_ami = wombat['aws']['amis'][ENV['AWS_REGION']]['chef-server']
    @delivery_server_ami = wombat['aws']['amis'][ENV['AWS_REGION']]['delivery']
    @delivery_builder_ami =  wombat['aws']['amis'][ENV['AWS_REGION']]['delivery-builder']
    @workstation_ami = wombat['aws']['amis'][ENV['AWS_REGION']]['workstation']
    @availability_zone = wombat['aws']['availability_zone']
    @demo = wombat['demo']
    @version = wombat['version']
    rendered_cfn = ERB.new(File.read('cloudformation/cfn.json.erb')).result
    File.open("cloudformation/#{@demo}.json", "w") {|file| file.puts rendered_cfn }
    puts "Created cloudformation/#{@demo}.json"
  end

  desc 'Create a Stack from a CloudFormation template'
  task :create_cfn_stack, :stack, :region, :keypair do |t, args|
    stack = args[:stack] || wombat['demo']
    region = args[:region] || wombat['aws']['region']
    keypair = args[:keypair] || wombat['aws']['keypair']
    sh create_stack(stack, region, keypair)
  end

  desc 'Build a CloudFormation stack'
  task build_cfn_stack: ['vendor', 'aws:pack_amis', 'aws:update_amis', 'aws:create_cfn_template']
end

namespace :tf do
  desc 'Update AMIS in tfvars'
  task :update_amis, :chef_server_ami, :delivery_server_ami, :delivery_builder_ami, :workstation_ami do |t, args|
    chef_server = args[:chef_server_ami] || File.read('./packer/logs/ami-chef-server.log').split("\n").last.split(" ")[1]
    delivery = args[:delivery_server_ami] || File.read('./packer/logs/ami-delivery-server.log').split("\n").last.split(" ")[1]
    builder = args[:delivery_builder_ami] || File.read('./packer/logs/ami-delivery-builder.log').split("\n").last.split(" ")[1]
    workstation = args[:workstation_ami] || File.read('./packer/logs/ami-workstation.log').split("\n").last.split(" ")[1]
    fail "packer build logs not found, nor were image ids provided" unless chef_server && delivery && builder && workstation
    puts "Updating tfvars based on most recent packer logs"
    @chef_server_ami = chef_server
    @delivery_server_ami = delivery
    @delivery_builder_ami = builder
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
  cmd.insert(2, "--var org='#{wombat['organization']}'") if !(base =~ /delivery/)
  cmd.insert(2, "--var domain='#{wombat['domain']}'")
  cmd.insert(2, "--var enterprise='#{wombat['enterprise']}'") if !(base =~ /chef-server/)
  cmd.insert(2, "--var chefdk='#{version('chefdk')}'") if !(base =~ /chef-server/)
  cmd.insert(2, "--var delivery='#{version('delivery')}'") if (base =~ /delivery/)
  cmd.insert(2, "--var chef-server='#{version('chef-server')}'") if (base =~ /chef-server/)
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
