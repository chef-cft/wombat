require 'wombat/common'
require 'aws-sdk'
require 'ms_rest_azure'
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

        # Create the connection to Azure using the information in the environment variables
        subscription_id = ENV['AZURE_SUBSCRIPTION_ID']
        tenant_id = ENV['AZURE_TENANT_ID']
        client_id = ENV['AZURE_CLIENT_ID']
        client_secret = ENV['AZURE_CLIENT_SECRET']

        token_provider = MsRestAzure::ApplicationTokenProvider.new(tenant_id, client_id, client_secret)
        azure_conn = MsRest::TokenCredentials.new(token_provider)

        # Create a resource client so that the template can be deployed
        @resource_management_client = Azure::ARM::Resources::ResourceManagementClient.new(azure_conn)
        @resource_management_client.subscription_id = subscription_id

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

    # Track the progress of the deployment in Azure
    #
    # ===== Attributes
    #
    # * +rg_name+ - Name of the resource group being deployed to
    # * +deployment_name+ - Name of the deployment that is currently being processed
    def follow_azure_deployment(rg_name, deployment_name)

      end_provisioning_states = 'Canceled,Failed,Deleted,Succeeded'
      end_provisioning_state_reached = false

      until end_provisioning_state_reached
        list_outstanding_deployment_operations(rg_name, deployment_name)
        info ""
        sleep 10
        deployment_provisioning_state = deployment_state(rg_name, deployment_name)
        end_provisioning_state_reached = end_provisioning_states.split(',').include?(deployment_provisioning_state)
      end
      info format("Resource Template deployment reached end state of %s", deployment_provisioning_state)
    end

    # Get a list of the outstanding deployment operations
    #
    # ===== Attributes
    #
    # * +rg_name+ - Name of the resource group being deployed to
    # * +deployment_name+ - Name of the deployment that is currently being processed    
    def list_outstanding_deployment_operations(rg_name, deployment_name)
      end_operation_states = 'Failed,Succeeded'
      deployment_operations = resource_management_client.deployment_operations.list(rg_name, deployment_name)
      deployment_operations.each do |val|
        resource_provisioning_state = val.properties.provisioning_state
        unless val.properties.target_resource.nil?
          resource_name = val.properties.target_resource.resource_name
          resource_type = val.properties.target_resource.resource_type
        end
        end_operation_state_reached = end_operation_states.split(',').include?(resource_provisioning_state)
        unless end_operation_state_reached
          info format("resource %s '%s' provisioning status is %s", resource_type, resource_name, resource_provisioning_state)
        end
      end
    end

    # Get the state of the specified deployment
    #
    # ===== Attributes
    #
    # * +rg_name+ - Name of the resource group being deployed to
    # * +deployment_name+ - Name of the deployment that is currently being processed     
    def deployment_state(rg_name, deployment_name)
      deployments = resource_management_client.deployments.get(rg_name, deployment_name)
      deployments.properties.provisioning_state
    end

  end
end
