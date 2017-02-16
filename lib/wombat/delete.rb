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
      @remove_all = opts.remove_all.nil? ? false : opts.remove_all
      @azure_async = opts.azure_async.nil? ? false : opts.azure_async
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

        # Connect to Azure
        azure_conn = connect_azure()

        # Create a resource client so that the resource group can be deleted
        @resource_management_client = Azure::ARM::Resources::ResourceManagementClient.new(azure_conn)
        @resource_management_client.subscription_id = ENV['AZURE_SUBSCRIPTION_ID']

        # Only delete the entire resource group if it has been explicitly set
        if (@remove_all) 
          banner(format("Deleting resource group: %s", stack))

          resource_management_client.resource_groups.begin_delete(stack)

          info "Destroy operation accepted and will continue in the background."
        else
        
          banner(format("Tidying resource group: %s", stack))

          # Create new deployment using the tidy template so that the storage account is left
          # behind but all the other resources are removed
          template_file = File.read("#{conf['stack_dir']}/#{stack}.tidy.json")

          # determine the name of the deployment
          deployment_name = format('deploy-tidy-%s', Time.now().to_i)

          # Create the deployment definition
          deployment = Azure::ARM::Resources::Models::Deployment.new
          deployment.properties = Azure::ARM::Resources::Models::DeploymentProperties.new
          deployment.properties.mode = Azure::ARM::Resources::Models::DeploymentMode::Complete
          deployment.properties.template = JSON.parse(template_file)

          # Perform the deployment to the named resource group
          begin
            resource_management_client.deployments.begin_create_or_update_async(stack, deployment_name, deployment).value!
          rescue MsRestAzure::AzureOperationError => operation_error
            rest_error = operation_error.body['error']
            deployment_active = rest_error['code'] == 'DeploymentActive'
            if deployment_active
              info format("Deployment for resource group '%s' is ongoing", stack)
            else
              warn rest_error
              raise operation_error
            end
          end

          # Monitor the deployment
          if @azure_async
            info "Deployment operation accepted.  Use the Azure Portal to check progress"
          else
            info "Removing Automate resources"
            follow_azure_deployment(stack, deployment_name)
          end
        end
      end
    end
  end
end