# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  config.vm.box = "bento/ubuntu-14.04"

  # cache rules everything around me
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.auto_detect = true
    config.cache.enable :apt
  end

  # Provision a Chef server with push jobs installed
  config.vm.define "chef-server" do |cs|

    cs.vm.hostname = "chef-server"
    cs.vm.network "private_network", ip: "172.31.54.10"

    cs.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end

    cs.vm.provision "chef_solo" do |chef|
      chef.cookbooks_path = "vendored-cookbooks/chef-server"
      chef.add_recipe "mock-data"
      chef.add_recipe "chef-server"
      chef.json = {
        "demo" => {
          "admin-user" => "vagrant"
        }
      }
    end

  end

  config.vm.define "delivery" do |d|

    d.vm.network "private_network", ip: "172.31.54.11"
    d.vm.hostname = "delivery"
    d.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end

    d.vm.provision "chef_solo" do |chef|
      chef.cookbooks_path = "vendored-cookbooks/delivery"
      chef.add_recipe "mock-data"
      chef.add_recipe "delivery"
      chef.json = {
        "demo" => {
          "admin-user" => "vagrant"
        }
      }
    end

  end

  config.vm.define "compliance" do |cc|
    cc.vm.hostname = "compliance"
    cc.vm.network "private_network", ip: "172.31.54.12"

    cc.vm.provider "virtualbox" do |v|
      v.memory = 1024
      v.cpus = 1
    end

    cc.vm.provision "chef_solo" do |chef|
      chef.cookbooks_path = "vendored-cookbooks/compliance"
      chef.add_recipe "mock-data"
      chef.add_recipe "compliance"
      chef.json = {
        "demo" => {
          "admin-user" => "vagrant"
        }
      }
    end

  end

  config.vm.define "build-node-1" do |bn|
    bn.vm.network "private_network", ip: "172.31.54.101"
    bn.vm.hostname = "build-node-1"

    bn.vm.provision "chef_solo" do |chef|
      chef.cookbooks_path = "vendored-cookbooks/build-node"
      chef.add_recipe "mock-data"
      chef.add_recipe "build-node"
      chef.json = {
        "demo" => {
          "admin-user" => "vagrant"
        }
      }
    end
  end

  config.vm.define "workstation", primary: true do |wk|
    wk.vm.network "private_network", ip: "172.31.54.99"
    wk.vm.hostname = "workstation"

    wk.vm.box = "mwrock/Windows2012R2"

    wk.vm.provision "chef_solo" do |chef|
      chef.cookbooks_path = "vendored-cookbooks/workstation"
      chef.add_recipe "mock-data"
      chef.add_recipe "workstation"
      chef.json = {
        "demo" => {
          "admin-user" => "vagrant"
        }
      }
    end
  end

end
