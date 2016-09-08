require 'wombat/common'
require 'aws-sdk'

class OutputRunner

  include Common

  attr_reader :stack

  def initialize(opts)
    @stack = opts.stack
  end

  def start
    cfn_workstation_ips(stack)
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
end
