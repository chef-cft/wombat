
require 'wombat/common'
require 'mixlib/shellout'
require 'parallel'

class BuildRunner

  include Common

  attr_reader :templates, :builder, :config, :parallel

  def initialize(opts)
    @templates = opts.templates
    @builder = opts.builder.nil? ? "amazon-ebs" : opts.builder
    @config = opts.config
    @parallel = opts.parallel
  end

  def start
    banner("Generating certs (if necessary)")
    wombat['certs'].each do |hostname|
      gen_x509_cert(hostname)
    end
    banner("Generating SSH keypair (if necessary)")
    gen_ssh_key

    time = Benchmark.measure do
      banner("Starting build for templates: #{templates}")
      aws_region_check if builder == 'amazon-ebs'
      templates.each do |t|
        vendor_cookbooks(t)
      end

      if parallel.nil?
        build_hash.each do |k, v|
          build(v['template'], v['options'])
          shell_out_command("say -v fred \"Wombat has made an #{k}\" for you") if is_mac?
        end
      else
        build_parallel(templates)
      end
    end
    banner("Build finished in #{duration(time.real)}.")
  end

  private

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
      elsif template_name == 'build-node'
        build_nodes.each do |name, num|
          proc_hash[name] = {
            'template' => 'build-node',
            'options' => {
              'node-number' => num
            }
          }
        end
      elsif template_name == 'workstation'
        workstations.each do |name, num|
          proc_hash[name] = {
            'template' => 'workstation',
            'options' => {
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
      cloud = 'aws'
    when 'googlecompute'
      cloud = 'gce'
    end
  end

  def shell_out_command(command)
    cmd = Mixlib::ShellOut.new(a_to_s(command), :timeout => 3600, live_stream: STDOUT)
    cmd.run_command
    cmd
  end

  def is_mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
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
    rm_cmd = "rm -rf #{cookbook_dir}/#{base}/Berksfile.lock vendored-cookbooks/#{base}"
    shell_out_command(rm_cmd)
    vendor_cmd = "berks vendor -q -b #{cookbook_dir}/#{base}/Berksfile vendored-cookbooks/#{base}"
    shell_out_command(vendor_cmd)
  end

  def log(template, builder, options)
    cloud = b_to_c(builder)
    case template
    when 'build-node'
      log_name = "#{cloud}-build-node-#{options['node-number']}-#{linux}"
    when 'workstation'
      log_name = "#{cloud}-workstation-#{options['workstation-number']}-#{linux}"
    when /infranodes/
      if options['os'] =~ /windows/
        log_name = "#{cloud}-infranodes-#{options['node-name']}-windows"
      else
        log_name = "#{cloud}-infranodes-#{options['node-name']}-#{linux}"
      end
    else
     log_name = "#{cloud}-#{template}-#{linux}"
    end
    log_file = "#{log_dir}/#{log_name}.log"
  end

  def packer_build_cmd(template, builder, options)
    create_infranodes_json

    if template == 'workstation'
      source_ami = wombat['aws']['source_ami']['windows']
      source_image = wombat['gce']['source_image']['windows']
    elsif template =~ /infranodes/
      if options['os'] == 'windows'
        source_ami = wombat['aws']['source_ami']['windows']
        source_image = wombat['gce']['source_image']['windows']
      else
        source_ami = wombat['aws']['source_ami'][linux]
        source_image = wombat['gce']['source_image'][linux]
      end
    else
      source_ami = wombat['aws']['source_ami'][linux]
      source_image = wombat['gce']['source_image'][linux]
    end

    # TODO: fail if packer isn't found in a graceful way
    cmd = %W(packer build #{packer_dir}/#{template}.json | tee #{log(template, builder, options)})
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
    cmd.insert(2, "--var aws_source_ami=#{source_ami}")
    cmd.insert(2, "--var gce_source_image=#{source_image}")
    cmd.insert(2, "--var ssh_username=#{linux}")
    cmd.join(' ')
  end
end
