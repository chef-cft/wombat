#
# Cookbook Name:: chef-server
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'cheffish'
# there is only zuul
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

config = {
  :chef_server_url => 'https://chef-server',
  :options => {
    :client_name => 'pivotal',
    :signing_key_filename => '/etc/opscode/pivotal.pem',
    :ssl_verify_mode => :verify_none
  }
}

#taken from cheffish
chef_user 'delivery' do
  chef_server config
  admin true
  display_name 'delivery'
  email 'chefeval@chef.io'
  password 'delivery'
  source_key_path '/tmp/private.pem'
end

chef_user 'workstation' do
  chef_server config
  admin true
  display_name 'workstation'
  email 'workstation@chef.io'
  password 'workstation'
  source_key_path '/tmp/private.pem'
end

chef_organization "#{node['demo']['org']}" do
  members ['delivery', 'workstation']
  chef_server config
end

conf_with_org = config.merge({
  :chef_server_url => "#{config[:chef_server_url]}/organizations/#{node['demo']['org']}"
})

all_nodes = {}
build_node_num = node['demo']['build-nodes'].to_i

if File.exists?('/tmp/infranodes-info.json')
  infranodes = JSON(File.read('/tmp/infranodes-info.json'))
else
  infranodes = {}
end

1.upto(build_node_num) do |i|
  build_node_name = "build-node-#{i}"
  all_nodes[build_node_name] = []
end

infranodes.each do |infra_node_name, rl|
  all_nodes[infra_node_name] = rl
end

all_nodes.each do |node_name, rl|
  chef_node node_name do
    tag 'delivery-build-node' if node_name.match(/^build-node/)
    run_list rl unless rl.empty?
    chef_server conf_with_org
  end

  chef_client node_name do
    source_key_path '/tmp/private.pem'
    chef_server conf_with_org
  end
end

chef_acl "" do
  rights :all, users: %w(delivery workstation), clients: all_nodes.keys
  recursive true
  chef_server conf_with_org
end