#
# Cookbook Name:: infranodes
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

unless nodes['platform'] == 'windows'
  apt_update 'packages' do
    action :update
    only_if { node['platform_family'] == 'debian' }
  end
end
  
chef_ingredient 'chef' do
  channel node['demo']['versions']['chef'].split('-')[0].to_sym
  version node['demo']['versions']['chef'].split('-')[1]
  action :install
end

if node['platform'] == 'windows'
  conf_dir = "C:/chef"
  tmp_dir = "C:/Windows/Temp"
else
  conf_dir = "/etc/chef"
  tmp_dir = "/tmp"
end

directory conf_dir

template File.join(conf_dir, 'client.rb') do
  source 'client.rb.erb'
  variables({
      :chef_server_url => node['demo']['chef_server_url'],
      :name => node['demo']['node-name'],
      :automate_fqdn => node['demo']['automate_fqdn']
  })
end

file File.join(conf_dir, 'client.pem') do
  content lazy { IO.read(File.join(tmp_dir, 'private.pem')) }
end

###todo: centralize this into the wombat cookbook
directory File.join(conf_dir, 'trusted_certs')

%w(chef automate compliance).each do |f|
  file File.join(conf_dir, "trusted_certs/#{node['demo']['domain_prefix']}#{f}_#{node['demo']['domain'].tr('.','_')}.crt") do
    content lazy { IO.read(File.join(tmp_dir, "#{f}.crt")) }
  end
end
###
node.set['push_jobs']['chef']['chef_server_url'] = node['demo']['chef_server_url']
node.set['push_jobs']['chef']['node_name'] = node['demo']['node-name']
include_recipe 'push-jobs'
