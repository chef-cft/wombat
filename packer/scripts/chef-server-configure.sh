#!/bin/bash -eux

echo 'Setting up users, orgs, and permissions via Cheffish'
sudo -E /opt/opscode/embedded/bin/chef-apply /tmp/create-user-org.rb