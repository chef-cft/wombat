#
# Cookbook Name:: workstation
# Recipe:: delivery
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
home = Dir.home

directory "#{home}/.delivery/" do
  action :create
end

template "#{home}/.delivery/cli.toml" do
  source 'cli.toml.erb'
  variables(
    server: "#{node['demo']['domain_prefix']}delivery.#{node['demo']['domain']}",
    ent: node['demo']['enterprise'],
    org: node['demo']['org'],
    user: node['demo']['users']['delivery']['first']
  )
end
