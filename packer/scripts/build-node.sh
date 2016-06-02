sudo mkdir -p /etc/chef/trusted_certs
sudo cp /tmp/chef_server.crt /etc/chef/trusted_certs/chef-server_chef-automate_com.crt
sudo cp /tmp/delivery_server.crt /etc/chef/trusted_certs/delivery-server_chef-automate_com.crt
sudo cp /tmp/private.pem /etc/chef/client.pem
echo "
chef_server_url 'https://chef-server.$DOMAIN/organizations/$ORG'
client_key '/etc/chef/client.pem'
node_name 'delivery-builder-1.$DOMAIN'
" | sudo tee /etc/chef/client.rb
