require 'wombat/common'
require 'aws-sdk'
require 'ms_rest_azure'
require 'azure_mgmt_resources'

module Wombat
  class DeployRunner
    include Wombat::Common

    attr_reader :stack, :cloud, :lock_opt, :template_opt

    def initialize(opts)
      @stack = opts.stack
      @cloud = opts.cloud.nil? ? "aws" : opts.cloud
      @lock_opt = opts.update_lock
      @template_opt = opts.update_template
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
      resource_group = ENV['AZURE_RESOURCE_GROUP']

      token_provider = MsRestAzure::ApplicationTokenProvider.new(tenant_id, client_id, client_secret)
      azure_conn = MsRest::TokenCredentials.new(token_provider)

      # Create a resource client so that the template can be deployed
      resource_management_client = Azure::ARM::Resources::ResourceManagementClient.new(azure_conn)
      resource_management_client.subscription_id = subscription_id

      # Create the deployment definition
      deployment = Azure::ARM::Resources::Models::Deployment.new
      deployment.properties = Azure::ARM::Resources::Models::DeploymentProperties.new
      deployment.properties.mode = Azure::ARM::Resources::Models::DeploymentMode::Incremental
      deployment.properties.template = JSON.parse(template_file)

      # Perform the deployment to the named resource group
      response = resource_management_client.deployments.create_or_update(resource_group, deployment_name, deployment)

    end
    end

  end
end
