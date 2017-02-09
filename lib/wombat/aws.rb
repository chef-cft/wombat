require "wombat/common"
require "aws-sdk"

# http://docs.aws.amazon.com/sdkforruby/api/Aws/EC2/Client.html#describe_images-instance_method
# https://github.com/test-kitchen/kitchen-ec2/blob/aa8e7f2cf9bfbb10fa4057f3297c2a20dc079f7b/lib/kitchen/driver/aws/standard_platform.rb
# https://github.com/test-kitchen/kitchen-ec2/blob/aa8e7f2cf9bfbb10fa4057f3297c2a20dc079f7b/lib/kitchen/driver/aws/standard_platform/ubuntu.rb

module Wombat
  module Aws
    include Wombat::Common

    def find_latest_amis
      client = ::Aws::EC2::Client.new(:region => wombat["aws"]["region"])
      # static list of images
      desc_hash = {
        "ubuntu-16.04" => ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*", "099720109477"],
        "ubuntu-14.04" => ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*", "099720109477"],
        "centos-7" => ["CentOS Linux 7 x86_64 HVM EBS*", "679593333241"],
        "windows-2012r2" => ["Windows_Server-2012-R2_RTM-English-64Bit-Base-*", "801119661308"]
      }
      desc_hash.each do |k, v|
        resp = client.describe_images({
          dry_run: false,
          filters: [
            {
              name: "name",
              values: [v[0]],
            },
            {
              name: "owner-id",
              values: [v[1]],
            },
          ],
        })
        images = sort_images(resp.images)

        puts "#{k}: #{images[:image_id]}"

      end
    end

    def prefer(images, &block)
      # Put the matching ones *before* the non-matching ones.
      matching, non_matching = images.partition(&block)
      matching + non_matching
    end

    def sort_images(images)
      # P5: We prefer more recent images over older ones
      images = images.sort_by(&:creation_date).reverse
      # P4: We prefer x86_64 over i386 (if available)
      images = prefer(images) { |image| image.architecture == :x86_64 }
      # P3: We prefer gp2 (SSD) (if available)
      images = prefer(images) do |image|
        image.block_device_mappings.any? do |b|
          b.device_name == image.root_device_name && b.ebs && b.ebs.volume_type == "gp2"
        end
      end
      # P2: We prefer ebs over instance_store (if available)
      images = prefer(images) { |image| image.root_device_type == "ebs" }
      # P1: We prefer hvm (the modern standard)
      images = prefer(images) { |image| image.virtualization_type == "hvm" }
      # Grab the image from the top of the stack
      images.first
    end
  end
end
