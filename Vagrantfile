# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  config.vm.box = "bento/ubuntu-14.04"
  
  # Configure all systems with the Chef apt repos
  config.vm.provision "shell", inline: <<-APT_REPOS
    wget -qO - https://downloads.chef.io/packages-chef-io-public.key | sudo apt-key add -
    echo "deb https://packages.chef.io/stable-apt trusty  main" > chef-stable.list
    sudo mv chef-stable.list /etc/apt/sources.list.d/
    sudo apt-get update
  APT_REPOS
  
  # Ensure all systems know about each other
  config.vm.provision "shell", inline: <<-HOSTS_FILE.gsub(/^\s+/, "")
    grep -q '172.31.54.10 chef-server' /etc/hosts || \
    echo "
    172.31.54.10 chef-server.chef-automate.com
    172.31.54.11 delivery-server.chef-automate.com
    172.31.54.12 build-node.chef-automate.com
    " | sudo tee -a /etc/hosts
  HOSTS_FILE

  # cache rules everything around me
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.auto_detect = true
    config.cache.enable :apt
  end

  # Provision a Chef server with push jobs installed
  config.vm.define "server" do |cs|
  
    cs.vm.network "private_network", ip: "172.31.54.10"
    
    cs.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end
    
    cs.vm.hostname = "chef-server.chef-automate.com"
    
    cs.vm.provision "shell", inline: <<-CONFIG_CS
      sudo apt-get install chef-server-core
      sudo chef-server-ctl install opscode-push-jobs-server
      sudo chef-server-ctl reconfigure
      sudo opscode-push-jobs-server-ctl reconfigure
      sudo chef-server-ctl install chef-manage
      sudo chef-server-ctl reconfigure
      sudo chef-manage-ctl reconfigure --accept-license
      sudo chef-server-ctl user-create delivery eval user noreply@chef.io 'eval4me!' --filename /vagrant/delivery-user.pem 2>&1
      sudo chef-server-ctl org-create chefautomate 'chef automate evaluation' --filename /vagrant/chefautomate-validator.pem -a delivery 2>&1
    CONFIG_CS
    
  end
  
  config.vm.define "build_node" do |bn|
    bn.vm.network "private_network", ip: "172.31.54.12"
    bn.vm.hostname = "build-node.chef-automate.com"
  end
  
  config.vm.define "delivery" do |d|
  
    d.vm.network "private_network", ip: "172.31.54.11"
    d.vm.hostname = "delivery-server.chef-automate.com"
    d.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end
      
    d.vm.provision "shell", inline: <<-CONFIG_DS
      sudo apt-get install delivery chefdk
      [ -d /var/opt/delivery/license ] || sudo mkdir /var/opt/delivery/license/
      sudo cp /vagrant/delivery.license /var/opt/delivery/license/delivery.license
      [ -d /etc/delivery ] || sudo mkdir /etc/delivery && sudo chmod 0644 /etc/delivery
      sudo cp /vagrant/delivery-user.pem /etc/delivery/delivery.pem
    CONFIG_DS

    d.vm.provision "chef_apply" do |delivery_rb|
      delivery_rb.recipe = <<-RENDER_DELIVERY_RB
       file "/etc/delivery/delivery.rb" do
         content <<-EOH.gsub /^\s+/, ""
           delivery_fqdn "delivery-server.chef-automate.com"
           delivery['chef_username'] = "delivery"
           delivery['chef_private_key'] = "/etc/delivery/delivery.pem"
           delivery['chef_server'] = "https://chef-server.chef-automate.com/organizations/chefautomate"
           insights['enable'] = true
         EOH
       end
      RENDER_DELIVERY_RB
    end

    d.vm.provision "shell", inline: <<-RECONFIG_DS
      sudo delivery-ctl reconfigure
      [ -e /etc/delivery/builder_key ] || sudo ssh-keygen -t rsa -N '' -b 2048 -f /etc/delivery/builder_key
      sudo delivery-ctl create-enterprise chefautomate --password eval4me! --ssh-pub-key-file=/etc/delivery/builder_key.pub > /vagrant/delivery-admin.creds
      sudo delivery-ctl create-user chefautomate delivery --password delivery > /vagrant/delivery.creds
      sudo delivery-ctl install-build-node chefautomate \
      --fqdn build-node.chef-automate.com \
      --username vagrant \
      --password vagrant \
      --installer $(ls /var/cache/apt/archives/chefdk_*_amd64.deb)
    RECONFIG_DS
    

  end
  
end
