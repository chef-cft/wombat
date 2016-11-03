#
# Cookbook Name:: wombat
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

all_hosts = node['demo']['hosts'].to_h
build_ip = 50
infra_ip = 100
wkstn_ip = 200
if node['platform'] == 'windows'
  tmp_dir = "C:\\Windows\\Temp"
else
  tmp_dir = "/tmp/"
end

infranodes_file = File.join(tmp_dir, "infranodes-info.json")

if File.exists?(infranodes_file)
  infranodes = JSON(File.read(infranodes_file))
else
  infranodes = {}
end

1.upto(node['demo']['build-nodes'].to_i) do |i|
  build_node_name = "build-node-#{i}"
  next if all_hosts.key?(build_node_name)
  build_ip += 1
  all_hosts[build_node_name] = "172.31.54.#{build_ip}"
end

1.upto(node['demo']['workstations'].to_i) do |i|
  wkstn_name = "workstation-#{i}"
  next if all_hosts.key?(wkstn_name)
  wkstn_ip += 1
  all_hosts[wkstn_name] = "172.31.54.#{wkstn_ip}"
end

infranodes.sort.each do |name, _info|
  next if all_hosts.key?(name)
  infra_ip += 1
  all_hosts[name] = "172.31.54.#{infra_ip}"
end

all_hosts.each do |hostname, ipaddress|
  hostsfile_entry ipaddress do
    hostname  "#{node['demo']['domain_prefix']}#{hostname}.#{node['demo']['domain']}"
    aliases   [hostname]
    action    :create
  end
end
