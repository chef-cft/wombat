#!/bin/bash -eux

# wget -qO - https://downloads.chef.io/packages-chef-io-public.key | sudo apt-key add -
# echo "deb https://packages.chef.io/stable-apt trusty  main" > chef-stable.list
# sudo mv chef-stable.list /etc/apt/sources.list.d/

sudo apt-get clean
sudo rm -rf /var/lib/apt/lists
sudo apt-get -y update
