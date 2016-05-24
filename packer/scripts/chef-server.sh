echo '127.0.0.1 chef-server.chef-automate.com' | sudo tee -a /etc/hosts
sudo apt-get install chef-server-core
sudo chef-server-ctl install opscode-push-jobs-server
sudo chef-server-ctl reconfigure
sudo opscode-push-jobs-server-ctl reconfigure
sudo chef-server-ctl install chef-manage
sudo chef-server-ctl reconfigure
sudo chef-manage-ctl reconfigure --accept-license