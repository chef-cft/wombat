require 'wombat/common'

class InitRunner
  include Common

  attr_reader :path

  def initialize(opts)
    @path = opts.path.nil? ? Dir.pwd : opts.path
  end

  def start
    copy_files(path)
  end

  private

  def copy_files(path)
    p = path == Dir.pwd ? '.' : path
    gen_dir = "#{File.expand_path("../..", File.dirname(__FILE__))}/generator_files"
    Dir["#{gen_dir}/*"].each do |source|
      if !File.exist?("#{p}/#{File.basename(source)}")
        banner("create: #{p}/#{File.basename(source)}")
        FileUtils.cp_r source, path
      else
        warn("#{p}/#{File.basename(source)} already exists")
      end
    end
  end
end
