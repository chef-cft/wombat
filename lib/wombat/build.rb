
require 'wombat/common'
require 'wombat/crypto'
require 'mixlib/shellout'
require 'parallel'
require 'ms_rest_azure'
require 'azure_mgmt_resources'
require 'azure_mgmt_storage'

module Wombat
  class BuildRunner
    include Wombat::Common
    include Wombat::Crypto

    attr_reader :templates, :builder, :parallel

    def initialize(opts)
      @templates = opts.templates.nil? ? calculate_templates : opts.templates
      @builder = opts.builder.nil? ? "amazon-ebs" : opts.builder
      @parallel = opts.parallel
      @wombat_yml = opts.wombat_yml unless opts.wombat_yml.nil?
      @debug = opts.debug
      @no_vendor = opts.vendor
    end

    def start
      if which('packer').nil?
        raise "packer binary not found in path, exiting..."
      end
      banner("Generating certs (if necessary)")
      wombat['certs'].each do |hostname|
        gen_x509_cert(hostname)
      end
      banner("Generating SSH keypair (if necessary)")
      gen_ssh_key

      # If running on azure ensure that the resource group and storage account exist
      prepare_azure if builder == "azure-arm"

      time = Benchmark.measure do
        banner("Starting build for templates: #{templates}")
        aws_region_check if builder == 'amazon-ebs'
        templates.each do |t|
          vendor_cookbooks(t) unless @no_vendor
        end

        if parallel.nil?
          build_hash.each do |k, v|
            build(v['template'], v['options'])
          end
        else
          build_parallel(templates)
        end
      end
      shell_out_command("say -v fred \"Wombat has made an #{build_hash.keys}\" for you") if audio?
      banner("Build finished in #{duration(time.real)}.")
    end

    private

    def prepare_azure()

      # Ensure that a storage acocunt has been specified, if it has not error
      if wombat['azure']['storage_account'].nil?
        puts "\nA storage account name must be specified in wombat.yml, e.g.\n  openssl rand -base64 12\nEnsure all lowercase and no special characters"
        exit
      end

      # Using environment variables connect to azure
      subscription_id = ENV['AZURE_SUBSCRIPTION_ID']
      tenant_id = ENV['AZURE_TENANT_ID']
      client_id = ENV['AZURE_CLIENT_ID']
      client_secret = ENV['AZURE_CLIENT_SECRET']

      token_provider = MsRestAzure::ApplicationTokenProvider.new(tenant_id, client_id, client_secret)
      azure_conn = MsRest::TokenCredentials.new(token_provider)

      # Create a resource to create the resource group if it does not exist
      resource_management_client = Azure::ARM::Resources::ResourceManagementClient.new(azure_conn)
      resource_management_client.subscription_id = subscription_id

      # Create a storage account client to create the stoarge account if it does not exist
      storage_management_client = Azure::ARM::Storage::StorageManagementClient.new(azure_conn)
      storage_management_client.subscription_id = subscription_id

      # Check that the resource group exists
      banner(format("Checking for resource group: %s", wombat['name']))
      status = resource_management_client.resource_groups.check_existence(wombat['name'])
      if status
        puts "resource group already exists"
      else
        puts format("creating new resource group in '%s'", wombat['azure']['location'])

        # Set the parameters for the resource group
        resource_group = Azure::ARM::Resources::Models::ResourceGroup.new
        resource_group.location = wombat['azure']['location']

        # Create hash to be used as tags on the resource group
        tags = {
          owner: ENV['USER']
        }

        # If an owner has been specified in the wombat file override the owner value
        if wombat.key?('owner') && !wombat['owner'].nil?
          tags[:owner] = wombat['owner']
        end

        # Determine if there are any tags specified in the azure wmbat section that need to be added
        if wombat['azure'].key?('tags') && wombat['azure']['tags'].length > 0

          # Check to see if there are more than 15 tags in which case output a warning
          if wombat['azure']['tags'].length > 14
            warn ('More than 15 tags have been specified, only the first 15 will be added.  This is a restriction in Azure.')
          end

          # Iterate around the tags and add each one to the tags array, up to 15
          wombat['azure']['tags'].each_with_index do |(key, value), index|
            tags[key] = value

            if index == 13
              break
            end
          end

        end

        # add the tags hash to the parameters
        resource_group.tags = tags

        # Create the resource group
        resource_management_client.resource_groups.create_or_update(wombat['name'], resource_group)
      end

      # Check to see if the storage account already exists
      banner(format("Checking for storage account: %s", wombat['azure']['storage_account']))

      # Create the storage account in the resource group
      # NOTE:  This should have a test to see if the storage account exists and it available however the
      # Azure Ruby SDK has an issue with the check_name_availability method and comes back with an error
      # This would normally be done through an ARM template, but in this case needs to exist before Packer can run
      storage_account = Azure::ARM::Storage::Models::StorageAccountCreateParameters.new
      storage_account.location = wombat['azure']['location']
      sku = Azure::ARM::Storage::Models::Sku.new
      sku.name = 'Standard_LRS'
      storage_account.sku = sku
      storage_account.kind = Azure::ARM::Storage::Models::Kind::Storage

      storage_management_client.storage_accounts.create(wombat['name'], wombat['azure']['storage_account'], storage_account)

    end

    def build(template, options)
      bootstrap_aws if options['os'] == 'windows'
      shell_out_command(packer_build_cmd(template, builder, options))
    end

    def build_parallel(templates)
      Parallel.map(build_hash.keys, in_threads: build_hash.count) do |name|
        build(build_hash[name]['template'], build_hash[name]['options'])
      end
    end

    def build_hash
      proc_hash = {}
      templates.each do |template_name|
        if template_name =~ /infranodes/
          infranodes.each do |name, _rl|
            next if name.empty?
            proc_hash[name] = {
              'template' => template_name,
              'options' => {
                'node-name' => name,
                'os' => wombat['infranodes'][name]['platform']
              }
            }
          end
        elsif template_name =~ /build-node/
          build_nodes.each do |name, num|
            proc_hash[name] = {
              'template' => template_name,
              'options' => {
                'node-number' => num
              }
            }
          end
        elsif template_name =~ /workstation/
          workstations.each do |name, num|
            proc_hash[name] = {
              'template' => template_name,
              'options' => {
                'os' => wombat['workstations']['platform'],
                'workstation-number' => num
              }
            }
          end
        else
          proc_hash[template_name] = {
            'template' => template_name,
            'options' => {}
          }
        end
      end
      proc_hash
    end

    def a_to_s(*args)
      clean_array(*args).join(" ")
    end

    def clean_array(*args)
      args.flatten.reject { |i| i.nil? || i == "" }.map(&:to_s)
    end

    def b_to_c(builder)
      case builder
      when 'amazon-ebs'
        'aws'
      when 'googlecompute'
        'gce'
      when 'azure-arm'
        'azure'
      end
    end

    def shell_out_command(command)
      cmd = Mixlib::ShellOut.new(a_to_s(command), :timeout => conf['timeout'], live_stream: STDOUT)
      cmd.run_command
      cmd
    end

    def aws_region_check
      if ENV['AWS_REGION']
        banner("Region set by environment: #{ENV['AWS_REGION']}")
      else
        banner("$AWS_REGION not set, setting to #{wombat['aws']['region']}")
        ENV['AWS_REGION'] = wombat['aws']['region']
      end
    end

    def vendor_cookbooks(template)
      banner "Vendoring cookbooks for #{template}"

      if template =~ /.*-windows/
        base = template.split('-')[0]
      else
        base = template.split('.json')[0].tr('-', '_')
      end
      rm_cmd = "rm -rf #{conf['cookbook_dir']}/#{base}/Berksfile.lock vendored-cookbooks/#{base}"
      shell_out_command(rm_cmd)
      vendor_cmd = "berks vendor -q -b #{conf['cookbook_dir']}/#{base}/Berksfile vendored-cookbooks/#{base}"
      shell_out_command(vendor_cmd)
    end

    def log(template, builder, options)
      cloud = b_to_c(builder)
      case template
      when /automate/
        log_name = "#{cloud}-automate-#{linux}"
      when /chef-server/
        log_name = "#{cloud}-chef-server-#{linux}"
      when /compliance/
        log_name = "#{cloud}-compliance-#{linux}"
      when /build-node/
        log_name = "#{cloud}-build-node-#{options['node-number']}-#{linux}"
      when /workstation/
        log_name = "#{cloud}-workstation-#{options['workstation-number']}-#{linux}"
      when /infranodes/
        if options['os'] =~ /windows/
          log_name = "#{cloud}-infranodes-#{options['node-name']}-windows"
        else
          log_name = "#{cloud}-infranodes-#{options['node-name']}-#{linux}"
        end
      end
      log_file = "#{conf['log_dir']}/#{log_name}.log"
    end

    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        }
      end
      return nil
    end

    def base_image(template, builder)
      cloud = b_to_c(builder)
      if template =~ /workstation/
        wombat[cloud]['source_image']['windows']
      elsif template =~ /infranodes/
        if options['os'] == 'windows'
          wombat[cloud]['source_image']['windows']
        else
          wombat[cloud]['source_image'][linux]
        end
      else
        wombat[cloud]['source_image'][linux]
      end
    end

    def packer_build_cmd(template, builder, options)
      create_infranodes_json
      Dir.mkdir(conf['log_dir'], 0755) unless File.exist?(conf['log_dir'])

      cmd = %W(packer build #{conf['packer_dir']}/#{template}.json | tee #{log(template, builder, options)})
      cmd.insert(2, "--only #{builder}")
      cmd.insert(2, "--var org=#{wombat['org']}")
      cmd.insert(2, "--var domain=#{wombat['domain']}")
      cmd.insert(2, "--var domain_prefix=#{wombat['domain_prefix']}")
      cmd.insert(2, "--var enterprise=#{wombat['enterprise']}")
      cmd.insert(2, "--var chefdk=#{wombat['products']['chefdk']}")
      cmd.insert(2, "--var chef_ver=#{wombat['products']['chef'].split('-')[1]}")
      cmd.insert(2, "--var chef_channel=#{wombat['products']['chef'].split('-')[0]}")
      cmd.insert(2, "--var automate=#{wombat['products']['automate']}")
      cmd.insert(2, "--var compliance=#{wombat['products']['compliance']}")
      cmd.insert(2, "--var chef-server=#{wombat['products']['chef-server']}")
      cmd.insert(2, "--var push-jobs-server=#{wombat['products']['push-jobs-server']}")
      cmd.insert(2, "--var manage=#{wombat['products']['manage']}")
      cmd.insert(2, "--var node-name=#{options['node-name']}") if template =~ /infranodes/
      cmd.insert(2, "--var node-number=#{options['node-number']}") if template =~ /build-node/
      cmd.insert(2, "--var build-nodes=#{wombat['build-nodes']['count']}")
      cmd.insert(2, "--var winrm_password=#{wombat['workstations']['password']}")
      cmd.insert(2, "--var winrm_username=Administrator")
      cmd.insert(2, "--var workstation-number=#{options['workstation-number']}") if template =~ /workstation/
      cmd.insert(2, "--var workstations=#{wombat['workstations']['count']}")
      cmd.insert(2, "--var aws_source_ami=#{base_image(template, builder)}") if builder =~ /amazon-ebs/
      cmd.insert(2, "--var gce_source_image=#{base_image(template, builder)}") if builder =~ /googlecompute/
      cmd.insert(2, "--var azure_location=#{wombat['azure']['location']}")
      cmd.insert(2, "--var ssh_username=#{linux}")
      cmd.insert(2, "--var azure_resource_group=#{wombat['name']}")
      cmd.insert(2, "--var azure_storage_account=#{wombat['azure']['storage_account']}")
      cmd.insert(2, "--debug") if @debug
      cmd.join(' ')
    end
  end
end
