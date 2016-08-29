#
# Cookbook Name:: infranodes
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

chef_ingredient 'chef' do
  channel node['demo']['versions']['chef'].split('-')[0].to_sym
  version node['demo']['versions']['chef'].split('-')[1]
  action :install
end

directory '/etc/chef'

template '/etc/chef/client.rb' do
  source 'client.rb.erb'
  variables({
      :chef_server_url => node['demo']['chef_server_url'],
      :name => node['demo']['node-name'],
      :automate_fqdn => node['demo']['automate_fqdn']
  })
end

file '/etc/chef/client.pem' do
  content lazy { IO.read('/tmp/private.pem') }
end

###todo: centralize this into the wombat cookbook
directory '/etc/chef/trusted_certs'

%w(chef automate compliance).each do |f|
  file "/etc/chef/trusted_certs/#{node['demo']['domain_prefix']}#{f}_#{node['demo']['domain'].tr('.','_')}.crt" do
    content lazy { IO.read("/tmp/#{f}.crt") }
  end
end
###
node.set['push_jobs']['chef']['chef_server_url'] = node['demo']['chef_server_url']
node.set['push_jobs']['chef']['node_name'] = node['demo']['node-name']
include_recipe 'wombat::authorized-keys'
include_recipe 'wombat::etc-hosts'
include_recipe 'push-jobs'
