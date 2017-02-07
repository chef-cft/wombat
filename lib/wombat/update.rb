require 'wombat/common'

module Wombat
  class UpdateRunner
    include Wombat::Common

    attr_reader :cloud, :update_file

    def initialize(opts)
      @cloud = opts.cloud.nil? ? "aws" : opts.cloud
      @update_file = opts.file.nil? ? "all" : opts.file
      @wombat_yml = opts.wombat_yml
    end

    def start
      update_lock(cloud) if /(all|lock)/.match(update_file)
      update_template(cloud) if /(all|template)/.match(update_file)
    end
  end
end
