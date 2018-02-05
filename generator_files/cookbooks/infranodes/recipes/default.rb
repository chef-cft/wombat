#
# Cookbook Name:: infranodes
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

if node['platform'] == 'windows'
  # Shouldn't need pushy on windows nodes for the time being, and timeouts are blocking builds.
  # node.default['push_jobs']['package_url'] = "https://packages.chef.io/files/stable/push-jobs-client/2.1.4/windows/2012/push-jobs-client-2.1.4-1-x86.msi"
  # node.default['push_jobs']['package_checksum'] = "3b979f8d362738c8ac126ace0e80122a4cbc53425d5f8cf9653cdd79eca16d62"

  conf_dir = "C:/chef"
  tmp_dir = "C:/Windows/Temp"
else
  conf_dir = "/etc/chef"
  tmp_dir = "/tmp"

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

directory conf_dir

template File.join(conf_dir, 'client.rb') do
  source 'client.rb.erb'
  variables({
      :chef_server_url => node['demo']['chef_server_url'],
      :name => node['demo']['node-name'],
      :automate_fqdn => node['demo']['automate_fqdn'],
      :conf_dir => conf_dir
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
node.default['push_jobs']['allow_unencrypted'] = true

include_recipe 'push-jobs' if node['platform'] == 'linux'
