#
# Cookbook Name:: chef-server
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

append_if_no_line "Add temporary hostsfile entry: #{node['ipaddress']}" do
  path "/etc/hosts"
  line "#{node['ipaddress']} #{node['demo']['domain_prefix']}chef.#{node['demo']['domain']} chef"
end

execute 'set hostname' do
  command 'hostnamectl set-hostname chef'
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
  file "/var/opt/opscode/nginx/ca/#{node['demo']['domain_prefix']}chef.#{node['demo']['domain']}.#{ext}" do
    content lazy { IO.read("/tmp/chef.#{ext}") }
    action :create
  end
end

chef_ingredient 'chef-server' do
  channel node['demo']['versions']['chef-server'].split('-')[0].to_sym
  version node['demo']['versions']['chef-server'].split('-')[1]
end

chef_ingredient 'chef-server' do
  action :reconfigure
  config "api_fqdn 'chef.#{node['demo']['domain']}'"
end

chef_ingredient 'push-jobs-server' do
  channel :stable
  version :latest
  action  :install
end

chef_ingredient 'push-jobs-server' do
  action :reconfigure
end

chef_ingredient 'manage' do
  channel :stable
  version :latest
  action  :install
end

chef_ingredient 'chef-server' do
  action :reconfigure
end

chef_ingredient 'manage' do
  accept_license true
  action :reconfigure
end

include_recipe 'chef_server::cheffish'

delete_lines "Remove temporary hostfile entry we added earlier" do
  path "/etc/hosts"
  pattern "^#{node['ipaddress']}.*#{node['demo']['domain_prefix']}chef\.#{node['demo']['domain']}.*chef"
end

include_recipe 'wombat::etc-hosts'
