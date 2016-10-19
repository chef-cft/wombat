require 'optparse'
require 'ostruct'

require 'wombat/version'
require 'wombat/common'
require 'wombat/build'
require 'wombat/deploy'
require 'wombat/output'
require 'wombat/delete'

class Options

  NAME = File.basename($0).freeze

  def self.parse(args)
    options = OpenStruct.new
    options.templates = calculate_templates("*.json")

    global = OptionParser.new do |opts|
      opts.banner = "Usage: #{NAME} [SUBCOMMAND [options]]"
      opts.separator ""
      opts.version = Wombat::VERSION
      opts.separator <<-COMMANDS.gsub(/^ {8}/, "")
        build        :   build one or more templates
        help         :   prints this help message
        list         :   list all templates in project
        deploy       :   deploy a stack
        outputs      :   get outputs for a stack
        delete       :   delete a stack
      COMMANDS
    end

    templates_argv_proc = proc { |options|
      options.templates = calculate_templates(args) unless args.empty?

      options.templates.each do |t|
        if !File.exists?("packer/#{t}.json")
          $stderr.puts "File packer/#{t}.json does not exist for template '#{t}'"
          exit(1)
        end
      end
    }

    box_version_argv_proc = proc { |options|
      options.box = ARGV[0]
      options.version = ARGV[1]
    }

    stack_argv_proc = proc { |options|
      options.stack = ARGV[0]
    }

    subcommand = {
      help: {
        parser: OptionParser.new {},
        argv: proc { |options|
          puts global
          exit(0)
        }
      },
      build: {
        class: BuildRunner,
        parser: OptionParser.new { |opts|
          opts.banner = "Usage: #{NAME} build [options] TEMPLATE[ TEMPLATE ...]"

          opts.on("-c CONFIG", "--config CONFIG", "Use config file") do |opt|
            options.config = opt
          end

          opts.on("-o BUILDER", "--only BUILDER", "Use config file") do |opt|
            options.builder = opt
          end

          opts.on("--parallel", "Build in parallel") do |opt|
            options.parallel = opt
          end
        },
        argv: templates_argv_proc
      },
      list: {
        class: ListRunner,
        parser: OptionParser.new { |opts|
          opts.banner = "Usage: #{NAME} list [TEMPLATE ...]"
        },
        argv: templates_argv_proc
      },
      outputs: {
        class: OutputRunner,
        parser: OptionParser.new { |opts|
          opts.banner = "Usage: #{NAME} outputs [TEMPLATE ...]"
        },
        argv: stack_argv_proc
      },
      deploy: {
        class: DeployRunner,
        parser: OptionParser.new { |opts|
          opts.banner = "Usage: #{NAME} deploy STACK"

          opts.on("-c CLOUD", "--cloud CLOUD", "Select cloud") do |opt|
            options.cloud = opt
          end

          opts.on("--update-lock", "Update lockfile") do |opt|
            options.update_lock = opt
          end

          opts.on("--create-template", "Create template") do |opt|
            options.create_template = opt
          end
        },
        argv: stack_argv_proc
      },
      delete: {
        class: DeleteRunner,
        parser: OptionParser.new { |opts|
          opts.banner = "Usage: #{NAME} delete STACK"

          opts.on("-c CLOUD", "--cloud CLOUD", "Select cloud") do |opt|
            options.cloud = opt
          end
        },

        argv: stack_argv_proc
      }
    }

    global.order!

    command = args.empty? ? :help : ARGV.shift.to_sym
    subcommand.fetch(command).fetch(:parser).order!
    subcommand.fetch(command).fetch(:argv).call(options)

    options.command = command
    options.klass = subcommand.fetch(command).fetch(:class)

    options
  end

  def self.calculate_templates(globs)
    Dir.chdir('packer') do
      Array(globs).
        map { |glob| result = Dir.glob("#{glob}"); result.empty? ? glob : result }.
        flatten.
        sort.
        delete_if { |file| file =~ /\.variables\./ }.
        map { |template| template.sub(/\.json$/, '') }
    end
  end
end

class ListRunner

  include Common

  attr_reader :templates

  def initialize(opts)
    @templates = opts.templates
  end

  def start
    templates.each { |template| puts template }
  end
end

class Runner

  attr_reader :options

  def initialize(options)
    @options = options
  end

  def start
    options.klass.new(options).start
  end
end
