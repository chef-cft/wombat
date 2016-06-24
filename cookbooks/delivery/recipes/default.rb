#
# Cookbook Name:: delivery
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

chef_server_url = "https://#{node['demo']['domain-prefix']}chef-server.#{node['demo']['domain']}/organizations/#{node['demo']['org']}"
delivery_url = "https://#{node['demo']['domain-prefix']}delivery.#{node['demo']['domain']}/e/#{node['demo']['enterprise']}"

append_if_no_line "Add loopback => hostname" do
  path "/etc/hosts"
  line "127.0.0.1 #{node['demo']['domain-prefix']}delivery.#{node['demo']['domain']} delivery"
end

execute 'set hostname' do
  command 'hostnamectl set-hostname delivery'
  action :run
end

append_if_no_line "Add certificate to authorized_keys" do
  path "/home/#{node['demo']['admin-user']}/.ssh/authorized_keys"
  line lazy { IO.read('/tmp/public.pub') }
end

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

chef_ingredient 'chefdk' do
  channel :stable
  action :install
  version node['demo']['versions']['chefdk']
end

chef_ingredient 'delivery' do
  channel :stable
  action :install
  version node['demo']['versions']['delivery']
end

directory '/var/opt/delivery'
directory '/var/opt/delivery/license'
directory '/var/opt/delivery/nginx'
directory '/var/opt/delivery/nginx/ca'
directory '/etc/delivery' do
  mode '0644'
end

file '/etc/delivery/delivery.pem' do
  content lazy { IO.read('/tmp/private.pem') }
  action :create
end

file '/var/opt/delivery/license/delivery.license' do
  content lazy { IO.read('/tmp/delivery.license') }
  action :create
end

file '/etc/delivery/builder_key.pub' do
  content lazy { IO.read('/tmp/public.pub') }
  action :create
end

%w(crt key).each do |ext|
  file "/var/opt/delivery/nginx/ca/#{node['demo']['domain-prefix']}delivery.#{node['demo']['domain']}.#{ext}" do
    content lazy { IO.read("/tmp/delivery.#{ext}") }
    action :create
  end
end

template '/etc/delivery/delivery.rb' do
  source 'delivery.erb'
  variables(
    chef_server_url: chef_server_url,
    domain-prefix: node['demo']['domain_prefix']
    domain: node['demo']['domain'],
    node_name: "build-node-#{node['demo']['node-number']}"
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
    execute 'delivery-ctl create-user' do
      command "delivery-ctl create-user #{node['demo']['enterprise']} #{user} --password #{info['password']}"
      action :run
      retries 5
      retry_delay 2
    end
  else
    Chef::Log.info('Admin user already created with create-enterprise')
  end
end

include_recipe 'wombat::etc-hosts'

delete_lines "Remove loopback entry we added earlier" do
  path "/etc/hosts"
  pattern "^127\.0\.0\.1.*localhost.*#{node['demo']['domain-prefix']}delivery\.#{node['demo']['domain']}.*delivery"
end
