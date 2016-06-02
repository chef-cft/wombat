#!/bin/bash -eux

echo "127.0.0.1 chef-server.$DOMAIN chef-server" | sudo tee -a /etc/hosts
sudo hostnamectl set-hostname chef-server
wget -q https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_$CHEF_SERVER_VER-1_amd64.deb -O /tmp/chef-server-core_$CHEF_SERVER_VER-1_amd64.deb
sudo dpkg -i /tmp/chef-server-core_$CHEF_SERVER_VER-1_amd64.deb
sudo mkdir -p /var/opt/opscode/nginx/ca/
sudo cp /tmp/chef_server.crt /var/opt/opscode/nginx/ca/chef-server.$DOMAIN.crt
sudo cp /tmp/chef_server.key /var/opt/opscode/nginx/ca/chef-server.$DOMAIN.key
sudo chef-server-ctl install opscode-push-jobs-server
sudo chef-server-ctl reconfigure
sudo opscode-push-jobs-server-ctl reconfigure
sudo chef-server-ctl install chef-manage
sudo chef-server-ctl reconfigure
sudo chef-manage-ctl reconfigure --accept-license
