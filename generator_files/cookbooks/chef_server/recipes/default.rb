#
# Cookbook Name:: chef-server
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

apt_update 'packages' do
  action :update
  only_if { node['platform_family'] == 'debian' }
  retries 10
  retry_delay 60
end

append_if_no_line "Add temporary hostsfile entry: #{node['ipaddress']}" do
  path "/etc/hosts"
  line "#{node['ipaddress']} #{node['demo']['domain_prefix']}chef.#{node['demo']['domain']} chef"
end

execute 'set hostname' do
  command 'hostnamectl set-hostname chef'
  action :run
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
    sensitive true
  end
end

chef_ingredient 'chef-server' do
  action [ :install, :reconfigure ]
  channel node['demo']['versions']['chef-server'].split('-')[0].to_sym
  version node['demo']['versions']['chef-server'].split('-')[1]
  config <<-EOH
api_fqdn 'chef.#{node['demo']['domain']}'
data_collector['root_url'] = 'https://#{node['demo']['domain_prefix']}automate.#{node['demo']['domain']}/data-collector/v0/'
data_collector['token'] = "#{node['demo']['data_collector_token']}"
profiles["root_url"] = "https://#{node['demo']['domain_prefix']}automate.#{node['demo']['domain']}"
EOH
end

# Temporarily reduced timeout to speed up the build.
append_if_no_line "Append a 1ms timeout for the data collector" do
  path "/etc/opscode/chef-server.rb"
  line "data_collector['timeout'] = '1'"
end

# Use an execute block so we don't revert the config.
execute 'chef-server-ctl reconfigure'

if node['platform'] == 'centos'
  # hardcoding this one as other permutations are known broken
  filename = 'opscode-push-jobs-server-1.1.6-1.x86_64.rpm'
  rpm_path = File.join(Chef::Config[:file_cache_path], filename)

  remote_file rpm_path do
    source "https://packages.chef.io/stable/el/6/#{filename}"
    action :create_if_missing
    notifies :install, 'rpm_package[push-jobs-server]', :immediately
  end

  rpm_package 'push-jobs-server' do
    action :install
    source rpm_path
    #not_if ""
  end
else
  chef_ingredient 'push-jobs-server' do
    channel node['demo']['versions']['push-jobs-server'].split('-')[0].to_sym
    version node['demo']['versions']['push-jobs-server'].split('-')[1]
    action  :install
  end
end

chef_ingredient 'push-jobs-server' do
  action :reconfigure
end

chef_ingredient 'manage' do
  channel node['demo']['versions']['manage'].split('-')[0].to_sym
  version node['demo']['versions']['manage'].split('-')[1]
  action  :install
end

# Another execute block. Keep our temp config until we finish.
execute 'chef-server-ctl reconfigure'

chef_ingredient 'manage' do
  accept_license true
  action :reconfigure
end

include_recipe 'chef_server::bootstrap_users'

# Temporary timeout no longer required. We can return to defaults now.
delete_lines "Remove the data_collector timeout before we finish." do
  path "/etc/opscode/chef-server.rb"
  pattern "^.*data_collector.*timeout.*"
  notifies :reconfigure, 'chef_ingredient[chef-server]', :immediately
end

delete_lines "Remove temporary hostfile entry we added earlier" do
  path "/etc/hosts"
  pattern "^#{node['ipaddress']}.*#{node['demo']['domain_prefix']}chef\.#{node['demo']['domain']}.*chef"
end

