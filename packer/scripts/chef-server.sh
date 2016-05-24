sudo apt-get install chef-server-core
sudo chef-server-ctl install opscode-push-jobs-server
sudo chef-server-ctl reconfigure
sudo opscode-push-jobs-server-ctl reconfigure
sudo chef-server-ctl install chef-manage
sudo chef-server-ctl reconfigure
sudo chef-manage-ctl reconfigure --accept-license
# chef-server-ctl user-create delivery eval user noreply@chef.io 'eval4me!' --filename /vagrant/delivery-user.pem 2>&1
# chef-server-ctl org-create chefautomate 'chef automate evaluation' --filename /vagrant/chefautomate-validator.pem -a delivery 2>&1
