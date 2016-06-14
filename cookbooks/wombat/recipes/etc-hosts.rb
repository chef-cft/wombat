#
# Cookbook Name:: wombat
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

all_hosts = node['demo']['hosts'].to_h
last_ip = all_hosts[all_hosts.keys.last].split('.')[-1].to_i

if File.exists?('/tmp/infranodes-info.json')
  infranodes = JSON(File.read('/tmp/infranodes-info.json'))
else
  infranodes = {}
end

1.upto(node['demo']['build_nodes'].to_i) do |i|
  build_node_name = "build-node-#{i}"
  next if all_hosts.key?(build_node_name)
  last_ip += 1
  all_hosts[build_node_name] = "172.31.54.#{last_ip}"
end

infranodes.sort.each do |name, run_list|
  next if all_hosts.key?(name)
  last_ip += 1
  all_hosts[name] = "172.31.54.#{last_ip}"
end

all_hosts.each do |hostname, ipaddress|
  hostsfile_entry ipaddress do
    hostname  hostname
    aliases   ["#{hostname}.#{node['demo']['domain']}"]
    action    :create
  end
end

