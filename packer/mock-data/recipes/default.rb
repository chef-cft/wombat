#
# Cookbook Name:: mock-data
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'cheffish'
Chef::Config.ssl_verify_mode :verify_none

config = {
  :chef_server_url => "https://localhost",
  :options => {
    :client_name => 'pivotal',
    :signing_key_filename => '/etc/opscode/pivotal.pem'
  }
}

#taken from cheffish
chef_user 'delivery' do
  chef_server config
  admin true
  display_name 'delivery'
  email 'chefeval@chef.io'
  password 'delivery'
  source_key_path "/tmp/delivery-user.pem"
end

chef_organization 'chefautomate' do
  members 'delivery'
  chef_server config
end