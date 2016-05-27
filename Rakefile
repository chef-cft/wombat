require 'erb'

# Style tests. Rubocop and Foodcritic
namespace :packerize do
  desc 'Build Chef Server'
  task :chef_server do
    sh "cd packer && packer build -only=aws-ebs ami-chef-server.json | tee -a logs/ami-chef-server.log"
  end

  desc 'Build Delivery template'
  task :delivery_server do
    sh "cd packer && packer build -only=aws-ebs ami-delivery-server.json | tee -a logs/ami-delivery-server.log"
  end

  desc 'Build Workstation'
  task workstation: [:vendor] do
    sh "cd packer && packer build -only=aws-ebs ami-workstation.json | tee -a logs/ami-workstation.log"
  end

  desc 'Cleanup Vendor directory'
  task :cleanup_vendor do
    sh 'rm -rf packer/vendored-cookbooks/*'
  end

  task vendor: [:cleanup_vendor] do
    sh 'berks vendor -b packer/cookbooks/workstation/Berksfile packer/vendored-cookbooks'
  end
end


desc 'Build all templates'
task packerize: ['packerize:delivery_server', 'packerize:chef_server', 'packerize:workstation']

namespace :terraform do
  desc 'Update AMIS'
  task :update_amis do
    chef_server = File.read('./packer/logs/ami-chef-server.log').split("\n").last.split(" ")[1]
    delivery = File.read('./packer/logs/ami-delivery-server.log').split("\n").last.split(" ")[1]
    workstation = File.read('./packer/logs/ami-workstation.log').split("\n").last.split(" ")[1]
    fail "packer build logs not found!" unless chef_server && delivery && workstation
    puts "Updating tfvars based on most recent packer logs"
    @chef_server_ami = chef_server
    @delivery_server_ami = delivery
    @workstation_ami = workstation
    rendered_tfvars = ERB.new(File.read('terraform/templates/terraform.tfvars.erb')).result
    File.open('terraform/terraform.tfvars', "w") {|file| file.puts rendered_tfvars }
    puts "\n" + rendered_tfvars
  end
end
