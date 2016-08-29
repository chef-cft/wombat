#
# Cookbook Name:: automate
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

append_if_no_line "Add temporary hostsfile entry: #{node['ipaddress']}" do
  path "/etc/hosts"
  line "#{node['ipaddress']} #{node['demo']['automate_fqdn']} automate"
end

execute 'hostnamectl set-hostname automate'

remote_file '/usr/local/bin/jq' do
  source 'https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  notifies :run, 'execute[chmod]', :immediately
end

execute 'chmod' do
  command 'chmod +x /usr/local/bin/jq'
  action :nothing
end

chef_ingredient 'delivery' do
  channel node['demo']['versions']['automate'].split('-')[0].to_sym
  version node['demo']['versions']['automate'].split('-')[1]
  action :install
end

directory '/var/opt/delivery'
directory '/var/opt/delivery/license'
directory '/var/opt/delivery/nginx'
directory '/var/opt/delivery/nginx/ca'
directory '/etc/delivery' do
  mode '0644'
end

file '/etc/delivery/automate.pem' do
  content lazy { IO.read('/tmp/private.pem') }
  action :create
  sensitive true
end

file '/var/opt/delivery/license/delivery.license' do
  content lazy { IO.read('/tmp/delivery.license') }
  action :create
  sensitive true
end

file '/etc/delivery/builder_key.pub' do
  content lazy { IO.read('/tmp/public.pub') }
  action :create
  sensitive true
end

%w(crt key).each do |ext|
  file "/var/opt/delivery/nginx/ca/#{node['demo']['automate_fqdn']}.#{ext}" do
    content lazy { IO.read("/tmp/automate.#{ext}") }
    action :create
    sensitive true
  end
end

template '/etc/delivery/delivery.rb' do
  source 'delivery.erb'
  variables(
    chef_server_url: node['demo']['chef_server_url'],
    delivery_fqdn: node['demo']['automate_fqdn']
  )
end

execute 'delivery-ctl reconfigure' do
  command 'delivery-ctl reconfigure'
  action :run
end

execute 'delivery-ctl create-enterprise' do
  command "delivery-ctl create-enterprise #{node['demo']['enterprise']} --password #{node['demo']['users']['admin']['password']} --ssh-pub-key-file=/etc/delivery/builder_key.pub"
  action :run
  retries 5
  retry_delay 2
  not_if "delivery-ctl list-enterprises | grep #{node['demo']['enterprise']}"
end

node['demo']['users'].each do |user, info|
  if user != 'admin'
    execute "delivery-ctl create-user #{user}" do
      command "delivery-ctl create-user #{node['demo']['enterprise']} #{user} --password #{info['password']}"
      action :run
      retries 5
      retry_delay 2
      #not_if "delivery-ctl list-users | grep #{node['demo']['enterprise']}"
    end
  else
    Chef::Log.info('Admin user already created with create-enterprise')
  end
end

include_recipe 'automate::update-users'

delete_lines "Remove temporary hostfile entry we added earlier" do
  path "/etc/hosts"
  pattern "^#{node['ipaddress']}.*#{node['demo']['automate_fqdn']}.*automate"
end

include_recipe 'wombat::authorized-keys'
include_recipe 'wombat::etc-hosts'
