#
# Cookbook Name:: delivery-demo
# Libraries:: delivery_project
#
# Author:: Salim Afiune (<afiune@chef.io>)
#
# Copyright 2015, Chef Software, Inc.
#
# All rights reserved - Do Not Redistribute
#

module Delivery

  # Delivery Project
  #
  # @author Salim Afiune <afiune@chef.io>
  #
  class DeliveryProject

    attr_accessor :project
    attr_accessor :organization
    attr_accessor :enterprise

    def initialize (project, organization, enterprise)
      @project = project
      @organization = organization
      @enterprise = enterprise
    end

  end
end
