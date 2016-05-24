echo '127.0.0.1 chef-server.chef-automate.com' | sudo tee -a /etc/hosts
sudo apt-get install delivery chefdk
sudo mkdir -p /var/opt/delivery/license
sudo mkdir -p /etc/delivery
sudo chmod 0644 /etc/delivery