#!/bin/bash -eux
grep -q '172.31.54.10 chef-server' /etc/hosts || \
echo "
172.31.54.10 chef-server.chef-automate.com chef-server
172.31.54.11 delivery-server.chef-automate.com delivery-server
172.31.54.12 build-node.chef-automate.com build-node
" | sudo tee -a /etc/hosts

sudo sed -i'' "s/127.0.0.1 $(hostname).chef-automate.com $(hostname)//" /etc/hosts
