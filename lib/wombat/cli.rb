require 'optparse'
require 'ostruct'

require 'wombat/version'
require 'wombat/common'
require 'wombat/build'
require 'wombat/deploy'
require 'wombat/output'
require 'wombat/delete'
require 'wombat/update'
require 'wombat/init'
require 'wombat/latest'

module Wombat
  class Options

    NAME = File.basename($0).freeze

    def self.parse(args)
      options = OpenStruct.new

      global = OptionParser.new do |opts|
        opts.banner = "Usage: #{NAME} [SUBCOMMAND [options]]"
        opts.separator ""
        opts.version = Wombat::VERSION
        opts.separator <<-COMMANDS.gsub(/^ {8}/, "")
          build        :   build one or more templates
          delete       :   delete a stack
          deploy       :   deploy a stack
          help         :   prints this help message
          init         :   create wombat skeleton project
          list         :   list all templates in project
          outputs      :   get outputs for a stack
          latest       :   search for latest images
          update       :   update lock and/or cloud template
        COMMANDS
      end

      templates_argv_proc = proc { |options|
        options.templates = ARGV unless args.empty?
      }

      box_version_argv_proc = proc { |options|
        options.box = ARGV[0]
        options.version = ARGV[1]
      }

      stack_argv_proc = proc { |options|
        options.stack = ARGV[0]
      }

      file_argv_proc = proc { |options|
        options.file = ARGV[0]
      }

      subcommand = {
        build: {
          class: BuildRunner,
          parser: OptionParser.new { |opts|
            opts.banner = "Usage: #{NAME} build [options] TEMPLATE[ TEMPLATE ...]"

            opts.on("-o BUILDER", "--only BUILDER", 'Only build the builds with the given comma-separated names') do |opt|
              options.builder = opt
            end

            opts.on("--parallel", "Build in parallel") do |opt|
              options.parallel = opt
            end

            opts.on("-c CONFIG", "--config CONFIG", "Specify a different yaml config (default is wombat.yml)") do |opt|
              options.wombat_yml = opt
            end

            opts.on("--debug", "Run in debug mode.") do |opt|
              options.debug = opt
            end

            opts.on("--novendorcookbooks", "Do not vendor cookbooks") do |opt|
              options.vendor = opt
            end
          },
          argv: templates_argv_proc
        },
        delete: {
          class: DeleteRunner,
          parser: OptionParser.new { |opts|
            opts.banner = "Usage: #{NAME} delete STACK"

            opts.on("-c CLOUD", "--cloud CLOUD", "Select cloud") do |opt|
              options.cloud = opt
            end

            opts.on("--force", "Force the removal of the parent resource group") do |opt|
              options.force = opt
            end

            opts.on("--async", "Delete resources asynchronously when not removing all, e.g. do not block command line.  (Azure Only)") do |opt|
              options.azure_async = opt
            end

            opts.on("--config CONFIG", "Specify a different yaml config (default is wombat.yml)") do |opt|
              options.wombat_yml = opt
            end

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

            opts.on("--update-template", "Update template") do |opt|
              options.update_template = opt
            end

            opts.on("--async", "Deploy stack asynchronously, e.g. do not block command line.  Only applies to Azure deployments.") do |opt|
              options.azure_async = opt
            end

            opts.on("--config CONFIG", "Specify a different yaml config (default is wombat.yml)") do |opt|
              options.wombat_yml = opt
            end
          },
          argv: stack_argv_proc
        },
        help: {
          parser: OptionParser.new {},
          argv: proc { |options|
            puts global
            exit(0)
          }
        },
        init: {
          class: InitRunner,
          parser: OptionParser.new { |opts|
            opts.banner = "Usage: #{NAME} init"

            opts.on("-p PATH", "--path PATH", "Path to copy skeleton") do |opt|
              options.path = opt
            end
          },
          argv: stack_argv_proc
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
            opts.banner = "Usage: #{NAME} outputs STACK"

            opts.on("-c CLOUD", "--cloud CLOUD", "Select cloud") do |opt|
              options.cloud = opt
            end
          },
          argv: stack_argv_proc
        },
        latest: {
          class: LatestRunner,
          parser: OptionParser.new { |opts|
            opts.banner = "Usage: #{NAME} search"

            opts.on("-c CLOUD", "--cloud CLOUD", "Select cloud") do |opt|
              options.cloud = opt
            end
          },
          argv: stack_argv_proc
        },
        update: {
          class: UpdateRunner,
          parser: OptionParser.new { |opts|
            opts.banner = "Usage: #{NAME} update [lock || template]"

            opts.on("-c CLOUD", "--cloud CLOUD", "Select cloud") do |opt|
              options.cloud = opt
            end

            opts.on("--config CONFIG", "Specify a different yaml config (default is wombat.yml)") do |opt|
              options.wombat_yml = opt
            end
          },
          argv: file_argv_proc
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
  end

  class ListRunner

    include Wombat::Common

    attr_reader :templates

    def initialize(opts)
      @templates = opts.templates.nil? ? calculate_templates : opts.templates
    end

    def start
      templates.each do |t|
        if !File.exists?("#{conf['packer_dir']}/#{t}.json")
          $stderr.puts "File #{conf['packer_dir']}/#{t}.json does not exist for template '#{t}'"
          exit(1)
        else
          puts t
        end
      end
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
end
