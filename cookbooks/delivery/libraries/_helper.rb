#
# Cookbook Name:: delivery-demo
# Recipe:: _helper
#
# Author:: Salim Afiune (<afiune@chef.io>)
#
# Copyright 2015, Chef Software, Inc.
#
# All rights reserved - Do Not Redistribute
#

module Delivery

  module Helper
    # Delivery API helper
    #
    # This little helper will let us just type:
    #  e.g.
    #       delivery_api.get(...)
    #       delivery_api.put(...)
    #       delivery_api.post(...)
    #       delivery_api.delete(...)
    #
    def delivery_api
      @api ||= begin
        Delivery::API.new(delivery_fqdn, 'admin',delivery_admin_password, delivery_enterprise)
      end
    end
    
    # Get delivery enterprise
    
    def delivery_fqdn
      "#{node['demo']['domain_prefix']}delivery.#{node['demo']['domain']}"      
    end
    
    def delivery_enterprise
      node['demo']['enterprise']
    end
    
    def delivery_admin_password
      node['demo']['users']['admin']['password']
    end
  end
end