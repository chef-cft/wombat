require 'wombat/common'
require 'aws-sdk'
require 'azure_mgmt_resources'

module Wombat
  class DeployRunner
    include Wombat::Common

    attr_reader :stack, :cloud, :lock_opt, :template_opt
    attr_accessor :resource_management_client

    def initialize(opts)
      @stack = opts.stack
      @cloud = opts.cloud.nil? ? "aws" : opts.cloud
      @lock_opt = opts.update_lock
      @template_opt = opts.update_template
      @azure_async = opts.azure_async
    end

    def start
      update_lock(cloud) if lock_opt
      update_template(cloud) if template_opt
      create_stack(stack)
    end

    private

    def create_stack(stack)

      # Deploy the template to the correct stack
      case @cloud
      when "aws"

        template_file = File.read("#{conf['stack_dir']}/#{stack}.json")
        cfn = Aws::CloudFormation::Client.new(region: lock['aws']['region'])

        banner("Creating CloudFormation stack")
        resp = cfn.create_stack({
          stack_name: "#{stack}",
          template_body: template_file,
          capabilities: ["CAPABILITY_IAM"],
          on_failure: "DELETE",
          parameters: [
            {
              parameter_key: "KeyName",
              parameter_value: lock['aws']['keypair'],
            }
          ]
        })
        puts "Created: #{resp.stack_id}"
      when "azure"

        banner("Creating Azure RM stack")

        # determine the path to the arm template
        template_file = File.read("#{conf['stack_dir']}/#{stack}.json")

        # determine the name of the deployment
        deployment_name = format('deploy-%s', Time.now().to_i)
        
        # Connect to azure
        azure_conn = connect_azure()

        # Create a resource client so that the template can be deployed
        @resource_management_client = Azure::ARM::Resources::ResourceManagementClient.new(azure_conn)
        @resource_management_client.subscription_id = ENV['AZURE_SUBSCRIPTION_ID']

        # Create the deployment definition
        deployment = Azure::ARM::Resources::Models::Deployment.new
        deployment.properties = Azure::ARM::Resources::Models::DeploymentProperties.new
        deployment.properties.mode = Azure::ARM::Resources::Models::DeploymentMode::Incremental
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
          follow_azure_deployment(stack, deployment_name)
        end

      end
    end



  end
end
