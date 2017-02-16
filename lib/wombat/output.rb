require 'wombat/common'
require 'aws-sdk'
require 'azure_mgmt_network'

module Wombat
  class OutputRunner
    include Wombat::Common

    attr_reader :stack, :cloud
    attr_accessor :network_management_client

    def initialize(opts)
      @stack = opts.stack
      @cloud = opts.cloud.nil? ? "aws" : opts.cloud
    end

    def start

      # Get the IP addresses for the workstations
      case cloud
      when "aws"
        cfn_workstation_ips(stack)
      when "azure"
        azure_workstation_ips(stack)
      end
    end

    private

    def cfn_workstation_ips(stack)
      ec2 = Aws::EC2::Resource.new
      instances = cfn_stack_instances(stack)
      instances.each do |name, id|
        instance = ec2.instance(id)
        if /Workstation/.match(name)
          puts "#{name} (#{id}) => #{instance.public_ip_address}"
        end
      end
    end

    def cfn_stack_instances(stack)
      cfn = Aws::CloudFormation::Client.new
      resp = cfn.describe_stack_resources({
        stack_name: stack,
        })

      instances = {}
      resp.stack_resources.map do |resource|
        if resource.resource_type == 'AWS::EC2::Instance'
          instances[resource.logical_resource_id] = resource.physical_resource_id
        end
      end
      instances
    end

    def azure_workstation_ips(stack)

      # Connect to Azure
      azure_conn = connect_azure()

      # Create a resource client so that the template can be deployed
      @network_management_client = Azure::ARM::Network::NetworkManagementClient.new(azure_conn)
      network_management_client.subscription_id = ENV['AZURE_SUBSCRIPTION_ID']

      # Obtain a list of all the Public IP addresses in the stack
      public_ip_addresses = network_management_client.public_ipaddresses.list(stack)

      banner(format("Public IP Addresses in '%s'", stack))

      if public_ip_addresses.length == 0

        warn('No public IP addresses')

      else

        # Iterate around the public IP addresses and output each one
        public_ip_addresses.each do |public_ip_address|

          # Output the details about the IP address
          puts format("%s:\t%s (%s)", public_ip_address.name, public_ip_address.ip_address, public_ip_address.dns_settings.fqdn)
        end
      end
    end
  end
end
