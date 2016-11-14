require 'wombat/common'
require 'aws-sdk'

class DeployRunner
  include Common

  attr_reader :stack, :cloud, :lock_opt, :template_opt

  def initialize(opts)
    @stack = opts.stack
    @cloud = opts.cloud.nil? ? "aws" : opts.cloud
    @lock_opt = opts.update_lock
    @template_opt = opts.update_template
  end

  def start
    case cloud
    when 'aws'
      update_lock(cloud) if lock_opt
      update_template(cloud) if template_opt
      create_stack(stack)
    end
  end

  private

  def create_stack(stack)
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
  end

end
