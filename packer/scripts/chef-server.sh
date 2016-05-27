#!/bin/bash -eux

echo '127.0.0.1 chef-server.chef-automate.com' | sudo tee -a /etc/hosts
sudo hostname chef-server.chef-automate.com
wget -q https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_12.6.0-1_amd64.deb -O /tmp/chef-server-core_12.6.0-1_amd64.deb
sudo dpkg -i /tmp/chef-server-core_12.6.0-1_amd64.deb
sudo chef-server-ctl install opscode-push-jobs-server
sudo chef-server-ctl reconfigure
sudo opscode-push-jobs-server-ctl reconfigure
sudo chef-server-ctl install chef-manage
sudo chef-server-ctl reconfigure
sudo chef-manage-ctl reconfigure --accept-license