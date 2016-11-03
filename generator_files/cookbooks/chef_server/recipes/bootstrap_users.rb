#
# Cookbook Name:: chef-server
# Recipe:: bootstrap_users
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'cheffish'
# there is only zuul
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

config = {
  :chef_server_url => 'https://chef',
  :options => {
    :client_name => 'pivotal',
    :signing_key_filename => '/etc/opscode/pivotal.pem',
    :ssl_verify_mode => :verify_none
  }
}

#taken from cheffish
node['demo']['users'].each do |user, info|
  chef_user user do
    chef_server config
    admin true
    display_name user
    email info['email']
    password info['password']
    source_key_path info['pem']
  end
end

chef_organization "#{node['demo']['org']}" do
  members node['demo']['users'].keys
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
  all_nodes[build_node_name] = {}
end

infranodes.each do |infra_node_name, info|
  all_nodes[infra_node_name] = info
end

environments = infranodes.map { |_n, i| i['environment'] }.compact.uniq

environments.each do |e|
  chef_environment e do
    chef_server conf_with_org
  end
end

all_nodes.each do |node_name, info|
  chef_node node_name do
    tag 'delivery-build-node' if node_name.match(/^build-node/)
    run_list info['run_list'] if info['run_list']
    chef_environment info['environment'] if info['environment']
    chef_server conf_with_org
  end

  chef_client node_name do
    source_key_path '/tmp/private.pem'
    chef_server conf_with_org
  end
end

chef_acl "" do
  rights :all, users: node['demo']['users'].keys, clients: all_nodes.keys
  recursive true
  chef_server conf_with_org
end

chef_group "admins" do
  users node['demo']['users'].keys
  clients all_nodes.keys
  chef_server conf_with_org
end
