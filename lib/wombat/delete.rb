require 'wombat/common'
require 'aws-sdk'
require 'azure_mgmt_resources'

module Wombat
  class DeleteRunner
    include Wombat::Common

    attr_reader :stack, :cloud
    attr_accessor :resource_management_client

    def initialize(opts)
      @stack = opts.stack
      @cloud = opts.cloud.nil? ? "aws" : opts.cloud
      @force = opts.force.nil? ? false : opts.force
      @azure_async = opts.azure_async.nil? ? false : opts.azure_async
      @wombat_yml = opts.wombat_yml unless opts.wombat_yml.nil?
    end

    def start
      cfn_delete_stack(stack)
    end

    private

    def cfn_delete_stack(stack)

      # Delete the stack from the correct platform
      case @cloud
      when "aws"
        cfn = Aws::CloudFormation::Client.new(region: lock['aws']['region'])

        resp = cfn.delete_stack({
          stack_name: stack,
        })
        banner("Deleted #{stack}")

      when "azure"

        # Configure the delete state
        delete = false

        # Connect to Azure
        azure_conn = connect_azure()

        # Create a resource client so that the resource group can be deleted
        @resource_management_client = Azure::ARM::Resources::ResourceManagementClient.new(azure_conn)
        @resource_management_client.subscription_id = ENV['AZURE_SUBSCRIPTION_ID']

        # Check the stack that is being requested
        # If it is the parent group display a warning before attempting to delete
        if stack == wombat['name'] && !@force
          warn("You are attempting to delete the resource group that contains your custom images.  If you wish to do this please specify the --force parameter on the command")
        else
          delete = true
        end

        if (delete)
          banner(format("Deleting resource group: %s", stack))

          resource_management_client.resource_groups.begin_delete(stack)

          info "Destroy operation accepted and will continue in the background."
        end
      end
    end
  end
end