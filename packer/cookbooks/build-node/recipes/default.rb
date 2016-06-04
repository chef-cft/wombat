#
# Cookbook Name:: build-node
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

chef_server_url = "https://chef-server.#{node['demo']['domain']}/organizations/#{node['demo']['org']}"

file '/home/ubuntu/.ssh/authorized_keys' do
  content IO.read('/tmp/public.pub')
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  action :create
end

directory '/etc/chef'
directory '/etc/chef/trusted_certs'
 
%w(chef-server delivery compliance).each do |f|
  file "/etc/chef/trusted_certs/#{f}_#{node['demo']['domain'].tr('.','_')}.crt" do
    content IO.read("/tmp/#{f}.crt")
    action :create
  end
end
  
file '/etc/chef/client.pem' do
  content IO.read('/tmp/private.pem')
  action :create
end

template '/etc/chef/client.rb' do
  source 'client.erb'
  variables(
    chef_server_url: chef_server_url,
    client_key: '/etc/chef/client.pem',
    node_name: "build-node-#{node['demo']['node-number']}"
  )
end

node['demo']['hosts'].each do |hostname, ipaddress|
  hostsfile_entry ipaddress do
    hostname  hostname
    aliases   ["#{hostname}.#{node['demo']['domain']}"]
    action    :create
  end
end

include_recipe 'delivery_build::default'
