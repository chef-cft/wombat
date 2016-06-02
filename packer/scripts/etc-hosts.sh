#!/bin/bash -eux
grep -q '172.31.54.10 chef-server' /etc/hosts || \
echo "
172.31.54.10 chef-server.$DOMAIN chef-server
172.31.54.11 delivery-server.$DOMAIN delivery-server
172.31.54.12 delivery-builder-1.$DOMAIN delivery-builder-1
" | sudo tee -a /etc/hosts

sudo sed -i'' "s/127.0.0.1 $(hostname).$DOMAIN $(hostname)//" /etc/hosts
