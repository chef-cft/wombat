#
# Cookbook Name:: wombat
# Recipe:: authorized-keys
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

append_if_no_line "Add certificate to authorized_keys" do
  path "/home/#{node['demo']['admin-user']}/.ssh/authorized_keys"
  line lazy { IO.read('/tmp/public.pub') }
end

node.default['authorization']['sudo']['include_sudoers_d'] = true

sudo 'centos' do
  user 'centos'
  nopasswd true
  defaults ['!requiretty']
  only_if { node['platform'] == 'centos' }
end
