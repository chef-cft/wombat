require 'erb'
require 'json'

# Style tests. Rubocop and Foodcritic
namespace :packerize do
  desc 'Build Chef Server'
  task :chef_server do
    sh build_command('chef-server.json')
  end

  desc 'Build Delivery Server'
  task :delivery_server do
    sh build_command('delivery-server.json')
  end

  desc 'Build Delivery Builder'
  task :delivery_builder do
    sh build_command('delivery-builder.json')
  end

  desc 'Build Workstation'
  task workstation: [:vendor] do
    sh build_command('workstation.json')
  end

  desc 'Cleanup Vendor directory'
  task :cleanup_vendor do
    sh 'rm -rf packer/vendored-cookbooks/*'
  end

  task vendor: [:cleanup_vendor] do
    sh 'berks vendor -b packer/cookbooks/workstation/Berksfile packer/vendored-cookbooks'
  end
end

def version(thing)
  file = File.read('wombat.json')
  hash = JSON.parse(file)
  hash['versions'][thing]
end

def build_command(template)
  base = template.split('.json')[0]
  cmd = %W(packer build packer/#{template} | tee packer/logs/ami-#{base}.log)
  cmd.insert(2, "--only amazon-ebs")
  cmd.insert(2, "--var chefdk='#{version('chefdk')}'")
  cmd.insert(2, "--var delivery='#{version('delivery')}'")
  cmd.insert(2, "--var chef-server='#{version('chef-server')}'")
  cmd.join(' ')
end

desc 'Build all AMIs'
task packerize: ['packerize:chef_server', 'packerize:delivery_server', 'packerize:delivery_builder', 'packerize:workstation']

namespace :terraform do
  desc 'Update AMIS'
  task :update_amis, :chef_server_ami, :delivery_server_ami, :workstation_ami do |t, args|
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
