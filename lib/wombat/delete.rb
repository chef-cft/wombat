require 'wombat/common'
require 'aws-sdk'
require 'ms_rest_azure'
require 'azure_mgmt_resources'

module Wombat
  class DeleteRunner
    include Wombat::Common

    attr_reader :stack, :cloud

    def initialize(opts)
      @stack = opts.stack
      @cloud = opts.cloud.nil? ? "aws" : opts.cloud
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

        # Create the connection to Azure using the information in the environment variables
        subscription_id = ENV['AZURE_SUBSCRIPTION_ID']
        tenant_id = ENV['AZURE_TENANT_ID']
        client_id = ENV['AZURE_CLIENT_ID']
        client_secret = ENV['AZURE_CLIENT_SECRET']

        token_provider = MsRestAzure::ApplicationTokenProvider.new(tenant_id, client_id, client_secret)
        azure_conn = MsRest::TokenCredentials.new(token_provider)

        # Create a resource client so that the resource group can be deleted
        resource_management_client = Azure::ARM::Resources::ResourceManagementClient.new(azure_conn)
        resource_management_client.subscription_id = subscription_id

        banner(format("Deleting resource group: %s", stack))

        resource_management_client.resource_groups.begin_delete(stack)


      end
    end
  end
end