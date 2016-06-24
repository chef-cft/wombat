#
# Cookbook Name:: chef-server
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

append_if_no_line "Add loopback => hostname" do
  path "/etc/hosts"
  line "127.0.0.1 #{node['demo']['domain-prefix']}chef-server.#{node['demo']['domain']} chef-server"
end

execute 'set hostname' do
  command 'hostnamectl set-hostname chef-server'
  action :run
end

append_if_no_line "Add certificate to authorized_keys" do
  path "/home/#{node['demo']['admin-user']}/.ssh/authorized_keys"
  line lazy { IO.read('/tmp/public.pub') }
end

directory '/var/opt/opscode'
directory '/var/opt/opscode/nginx'
directory '/var/opt/opscode/nginx/ca'
directory '/etc/opscode' do
  mode '0644'
end

%w(crt key).each do |ext|
  file "/var/opt/opscode/nginx/ca/#{node['demo']['domain-prefix']}chef-server.#{node['demo']['domain']}.#{ext}" do
    content lazy { IO.read("/tmp/chef-server.#{ext}") }
    action :create
  end
end

chef_ingredient 'chef-server' do
  channel :stable
  action :install
  version node['demo']['versions']['chef-server']
end

chef_ingredient 'chef-server' do
  action :reconfigure
end

chef_ingredient 'push-jobs-server' do
  channel :stable
  action :install
  version :latest
end

chef_ingredient 'push-jobs-server' do
  action :reconfigure
end

chef_ingredient 'manage' do
  channel :stable
  action :install
  version :latest
end

chef_ingredient 'chef-server' do
  action :reconfigure
end

chef_ingredient 'manage' do
  accept_license true
  action :reconfigure
end

include_recipe 'chef-server::cheffish'

include_recipe 'wombat::etc-hosts'

delete_lines "Remove loopback entry we added earlier" do
  path "/etc/hosts"
  pattern "^127\.0\.0\.1.*localhost.*#{node['demo']['domain-prefix']}chef-server\.#{node['demo']['domain']}.*chef-server"
end
