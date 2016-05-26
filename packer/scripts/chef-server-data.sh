#!/bin/bash -eux

echo 'creating delivery user and chefautomate org'
sudo /opt/opscode/embedded/bin/chef-apply /tmp/create-user-org.rb