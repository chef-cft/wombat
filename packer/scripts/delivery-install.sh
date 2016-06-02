#!/bin/bash -eux

echo '127.0.0.1 delivery-server.chef-automate.com delivery-server' | sudo tee -a /etc/hosts
sudo hostnamectl set-hostname delivery-server
sudo wget -q https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /usr/local/bin/jq
sudo chmod +x /usr/local/bin/jq
wget -q https://packages.chef.io/stable/ubuntu/12.04/chefdk_$CHEFDK_VER-1_amd64.deb -O /tmp/chefdk_$CHEFDK_VER-1_amd64.deb
sudo dpkg -i /tmp/chefdk_$CHEFDK_VER-1_amd64.deb
wget -q https://chef.bintray.com/current-apt/ubuntu/14.04/delivery_$DELIVERY_VER-1_amd64.deb -O /tmp/delivery_$DELIVERY_VER-1_amd64.deb
sudo dpkg -i /tmp/delivery_$DELIVERY_VER-1_amd64.deb
sudo mkdir -p /var/opt/delivery/license
sudo mkdir -p /etc/delivery
sudo chmod 0644 /etc/delivery
