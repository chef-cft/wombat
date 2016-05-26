#!/bin/bash -eux

sudo cp /tmp/delivery.rb /etc/delivery/delivery.rb
sudo cp /tmp/delivery.pem /etc/delivery/delivery.pem
sudo cp /tmp/delivery.license /var/opt/delivery/license/delivery.license
sudo cp /tmp/builder_key.pub /etc/delivery/builder_key.pub

sudo delivery-ctl reconfigure
sudo delivery-ctl create-enterprise chefautomate --password eval4me! --ssh-pub-key-file=/etc/delivery/builder_key.pub
sudo delivery-ctl create-user chefautomate delivery --password delivery

mkdir -p ~/.delivery
cp /tmp/cli.toml ~/.delivery/cli.toml
echo -n "delivery-server.chef-automate.com,chefautomate,admin|" > ~/.delivery/api-tokens

echo $(curl -s -k -H "content-type: application/json" -X POST https://delivery-server.chef-automate.com/api/v0/e/chefautomate/get-token -d '{"username": "admin", "password": "eval4me!"}' | jq -r ".token") >> ~/.delivery/api-tokens

delivery api put users/delivery --data '{"name": "delivery", "first": "delivery", "last": "delivery", "email": "delivery@chef.io", "user_type": "internal", "ssh_pub_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrrOTkLJKDy60wDfN5n+4bVneDJKAJZO+BvJkyFKIA/Z9Eu8M9WZ8tbFvMPekuO6E+aAp2QIJ7B//Hy9WIVDeRHeHqqc8ZM/gV7VGeFc+qEdNkz60+yv9wvOVywCU9rn5xLpncXtU1TYs4DvitNdD7mNCy+AVw9sVaX1KWVohP/TwOiJJHT1e9kIoBo1rb9onfSeCqTXgsbNgufne25u4aN8+3t0ppdxnm0fVt97a8SKPSk3P+VLYn4o+ziWEyRsywCV02NxFLr75Oh3i4GKSjVHgx32lpxjZd3oQAPuFcI1+iAWO6YXisQTKExlRfjikSJFOAtHVqpHM0nOMdxKKV root@chef-server"}'
