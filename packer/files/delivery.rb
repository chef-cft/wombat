delivery_fqdn "delivery-server.chef-automate.com"
delivery['chef_username'] = "delivery"
delivery['chef_private_key'] = "/etc/delivery/delivery.pem"
delivery['chef_server'] = "https://chef-server.chef-automate.com/organizations/chefautomate"
insights['enable'] = true