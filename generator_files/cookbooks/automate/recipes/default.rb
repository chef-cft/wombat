#
# Cookbook Name:: automate
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
apt_update 'packages' do
  action :update
  only_if { node['platform_family'] == 'debian' }
end

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

user 'delivery'

group 'delivery' do
  members 'delivery'
end

directory '/var/opt/delivery'
directory '/var/opt/delivery/license'
directory '/var/opt/delivery/nginx'
directory '/var/opt/delivery/nginx/ca'
directory '/etc/delivery' do
  mode '0644'
end

file '/var/opt/delivery/.telemetry.disabled' do
  action :create
end

file '/etc/delivery/automate.pem' do
  content lazy { IO.read('/tmp/private.pem') }
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

file '/var/opt/delivery/license/delivery.license' do
  content lazy { IO.read('/tmp/delivery.license') }
  action :create
  sensitive true
end

chef_automate "#{node['demo']['automate_fqdn']}" do
  accept_license true
  channel node['demo']['versions']['automate'].split('-')[0].to_sym
  version node['demo']['versions']['automate'].split('-')[1]
  enterprise node['demo']['enterprise']
  chef_server node['demo']['chef_server_url']
  chef_user 'automate'
  chef_user_pem lazy { IO.read('/etc/delivery/automate.pem') }
  validation_pem lazy { IO.read('/etc/delivery/automate.pem') }
  builder_pem lazy { IO.read('/tmp/private.pem') }
  license 'delivery.license'
  config <<-EOS
    nginx['ssl_protocols'] = 'TLSv1.2'
    insights['enable'] = true
    compliance_profiles['enable'] = true
  EOS
  action :create 
end

execute 'delivery-ctl reconfigure' do
  command 'delivery-ctl reconfigure'
  action :run
  retries 5
  retry_delay 10
end

node['demo']['users'].each do |user, info|
  if user != 'admin'
    execute "delivery-ctl create-user #{user}" do
      command "delivery-ctl create-user #{node['demo']['enterprise']} #{user} --password #{info['password']}"
      action :run
      retries 5
      retry_delay 2
      not_if "delivery-ctl list-users #{node['demo']['enterprise']} | grep #{user}"
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
