require 'wombat/common'
require 'aws-sdk'

class DeleteRunner
  include Common

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
    cfn = Aws::CloudFormation::Client.new(region: lock['aws']['region'])

    resp = cfn.delete_stack({
      stack_name: stack,
    })
    banner("Deleted #{stack}")
  end
end
