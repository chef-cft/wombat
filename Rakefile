# Style tests. Rubocop and Foodcritic
namespace :packerize do
  desc 'Build Chef Server'
  task :chef_server do
    sh "cd packer && packer build ami-chef-server.json | tee -a logs/ami-chef-server.log"
  end

  desc 'Build Delivery template'
  task :delivery_server do
    sh "cd packer && packer build ami-delivery-server.json | tee -a logs/ami-delivery-server.log"
  end

  desc 'Build Workstation'
  task workstation: [:vendor] do
    sh "cd packer && packer build ami-workstation.json | tee -a logs/ami-workstation.log"
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
    puts "Updating tfvars based on most recent packer logs"
    puts "chef-server: #{chef_server}"
    puts "delivery: #{delivery}"
    puts "workstation: #{workstation}"
    tfvars = File.read('terraform/terraform.tfvars')
    replace = tfvars.gsub(/(ami-chef-server) = (\"ami-.*\")/, '\1 = ' + "\"#{chef_server}\"")
    replace1 = replace.gsub(/(ami-delivery-server) = (\"ami-.*\")/, '\1 = ' + "\"#{delivery}\"")
    replace2 = replace1.gsub(/(ami-workstation) = (\"ami-.*\")/, '\1 = ' + "\"#{workstation}\"")
    File.open('terraform/terraform.tfvars', "w") {|file| file.puts replace2 }
  end
end
