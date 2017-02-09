require "wombat/common"
require "wombat/aws"

# http://docs.aws.amazon.com/sdkforruby/api/Aws/EC2/Client.html#describe_images-instance_method
# https://github.com/test-kitchen/kitchen-ec2/blob/aa8e7f2cf9bfbb10fa4057f3297c2a20dc079f7b/lib/kitchen/driver/aws/standard_platform.rb
# https://github.com/test-kitchen/kitchen-ec2/blob/aa8e7f2cf9bfbb10fa4057f3297c2a20dc079f7b/lib/kitchen/driver/aws/standard_platform/ubuntu.rb

module Wombat
  class LatestRunner
    include Wombat::Common
    include Wombat::Aws

    attr_reader :stack, :cloud, :lock_opt, :template_opt

    def initialize(opts)
      @cloud = opts.cloud.nil? ? "aws" : opts.cloud
    end

    def start
      if cloud =~ /aws/
        find_latest_amis
      else
        puts "Unsupported for #{cloud}"
      end
    end
  end
end
