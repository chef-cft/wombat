#!/bin/bash -eux

sudo cp /tmp/private.pem /etc/delivery/delivery.pem
sudo cp /tmp/delivery.license /var/opt/delivery/license/delivery.license
sudo cp /tmp/public.pub /etc/delivery/builder_key.pub
sudo mkdir -p /var/opt/delivery/nginx/ca/
sudo cp /tmp/delivery_server.crt /var/opt/delivery/nginx/ca/delivery.$DOMAIN.crt
sudo cp /tmp/delivery_server.key /var/opt/delivery/nginx/ca/delivery.$DOMAIN.key

echo "delivery_fqdn \"delivery.$DOMAIN\"" | sudo tee -a /etc/delivery/delivery.rb
echo "delivery['chef_username'] = \"delivery\"" | sudo tee -a /etc/delivery/delivery.rb
echo "delivery['chef_private_key'] = \"/etc/delivery/delivery.pem\"" | sudo tee -a /etc/delivery/delivery.rb
echo "delivery['chef_server'] = \"https://chef-server.$DOMAIN/organizations/$ENTERPRISE\"" | sudo tee -a /etc/delivery/delivery.rb
echo "insights['enable'] = true" | sudo tee -a /etc/delivery/delivery.rb

sudo delivery-ctl reconfigure
sudo delivery-ctl create-enterprise $ENTERPRISE --password eval4me! --ssh-pub-key-file=/etc/delivery/builder_key.pub
sudo delivery-ctl create-user $ENTERPRISE delivery --password delivery

mkdir -p ~/.delivery
echo "server = \"delivery.$DOMAIN\"" | tee -a ~/.delivery/cli.toml
echo "enterprise = \"$ENTERPRISE\"" | tee -a ~/.delivery/cli.toml
echo 'user = "admin"' | tee -a ~/.delivery/cli.toml

echo -n "delivery.$DOMAIN,$ENTERPRISE,admin|" > ~/.delivery/api-tokens

echo $(curl -s -k -H "content-type: application/json" -X POST https://delivery.$DOMAIN/api/v0/e/$ENTERPRISE/get-token -d '{"username": "admin", "password": "eval4me!"}' | jq -r ".token") >> ~/.delivery/api-tokens

delivery api put users/delivery --data '{"name": "delivery", "first": "delivery", "last": "delivery", "email": "delivery@chef.io", "user_type": "internal", "ssh_pub_key": "'"$(cat /etc/delivery/builder_key.pub)"'"}'
