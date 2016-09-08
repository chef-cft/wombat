
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
    banner("Generating keys (if necessary)")
    wombat['certs'].each do |hostname|
      gen_x509_cert(hostname)
    end

    gen_ssh_key

    if parallel
      time = Benchmark.measure do
        banner("Starting parallel build for templates: #{templates}")
        parallel_pack(templates, builder)
      end
    else
      time = Benchmark.measure do
        banner("Starting sequential build for templates: #{templates}")
        templates.each do |template|
          options = {}
          # TODO: this needs to be abstracted badly
          case template
          when 'build-node', 'build-nodes'
            vendor_cookbooks('build-node')
            build_nodes.each do |name, num|
              template = 'build-node'
              options = {'node-number' => num}
              packer_cmd = Mixlib::ShellOut.new(packer_build(template, builder, options), :timeout => 3600, live_stream: STDOUT)
              packer_cmd.run_command
            end
          when 'workstation', 'workstations'
            bootstrap_aws
            vendor_cookbooks('workstation')
            workstations.each do |name, num|
              template = 'workstation'
              options = {'workstation-number' => num}
              packer_cmd = Mixlib::ShellOut.new(packer_build(template, builder, options), :timeout => 3600, live_stream: STDOUT)
              packer_cmd.run_command
            end
          when 'infranode', 'infranodes'
            vendor_cookbooks('infranodes')
            infranodes.each do |name, num|
              template = 'infranodes'
              options = {'node-name' => name}
              packer_cmd = Mixlib::ShellOut.new(packer_build(template, builder, options), :timeout => 3600, live_stream: STDOUT)
              packer_cmd.run_command
            end
          else
            vendor_cookbooks(template)
            packer_cmd = Mixlib::ShellOut.new(packer_build(template, builder, options), :timeout => 3600, live_stream: STDOUT)
            packer_cmd.run_command
            puts packer_cmd
            puts packer_cmd.stdout
            puts packer_cmd.stderr unless packer_cmd.stderr.empty?
          end
        end
      end
    end
    banner("Build finished in #{duration(time.real)}.")
  end

  private

  def vendor_cookbooks(template)
    base = template.split('.json')[0].tr('-', '_')
    rm = Mixlib::ShellOut.new("rm -rf vendored-cookbooks/#{base} cookbooks/#{base}/Berksfile.lock", live_stream: STDOUT)
    rm.run_command
    puts "Vendoring cookbooks for #{template}"
    vendor = Mixlib::ShellOut.new("berks vendor -q -b cookbooks/#{base}/Berksfile vendored-cookbooks/#{base}", live_stream: STDOUT)
    vendor.run_command
  end

  def packer_build(template, builder, options={})
    # TODO: this is gross and feels gross so maybe we should do it more better
    create_infranodes_json
    case template
    when 'build-node'
      log_name = "build-node-#{options['node-number']}"
    when 'workstation'
      log_name = "workstation-#{options['workstation-number']}"
    when 'infranodes'
      log_name = "infranodes-#{options['node-name']}"
    else
     log_name = template
    end

    case builder
    when 'amazon-ebs'
      if template == 'workstation'
        source_ami = wombat['aws']['source_ami']['windows']
      else
        source_ami = wombat['aws']['source_ami']['ubuntu']
      end
      if ENV['AWS_REGION']
        puts "Region set by environment: #{ENV['AWS_REGION']}"
      else
        banner("$AWS_REGION not set, setting to #{wombat['aws']['region']}")
        ENV['AWS_REGION'] = wombat['aws']['region']
      end
      log_prefix = "aws"
    when 'googlecompute'
      if template == 'workstation'
        source_image = wombat['gce']['source_image']['windows']
      else
        source_image = wombat['gce']['source_image']['ubuntu']
      end
      log_prefix = "gce"
    end
    # TODO: fail if packer isn't found in a graceful way
    cmd = %W(packer build packer/#{template}.json | tee packer/logs/#{log_prefix}-#{log_name}.log)
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
    cmd.insert(2, "--var node-name=#{options['node-name']}") if template =~ /infranodes/
    cmd.insert(2, "--var node-number=#{options['node-number']}") if template =~ /build-node/
    cmd.insert(2, "--var build-nodes=#{wombat['build-nodes']}")
    cmd.insert(2, "--var winrm_password=#{wombat['workstation-passwd']}") if template =~ /workstation/
    cmd.insert(2, "--var workstation-number=#{options['workstation-number']}") if template =~ /workstation/
    cmd.insert(2, "--var workstations=#{wombat['workstations']}")
    cmd.insert(2, "--var aws_source_ami=#{source_ami}")
    cmd.insert(2, "--var gce_source_image=#{source_image}")
    cmd.join(' ')
  end

  def parallel_pack(templates, builder)
    proc_hash = {}
    templates.each do |template_name|
      if template_name == 'infranodes'
        infranodes.each do |name, _rl|
          next if name.empty?
          proc_hash[name] = {
            'template' => 'infranodes',
            'options' => {
              'node-name' => name
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
      vendor_cookbooks(template_name)
    end
    puts proc_hash
    Parallel.map(proc_hash.keys, in_threads: proc_hash.count) do |name|
      cmd = packer_build(proc_hash[name]['template'], builder, proc_hash[name]['options'])
      packer_cmd = Mixlib::ShellOut.new(cmd, :timeout => 3600, live_stream: STDOUT)
      packer_cmd.run_command
    end
  end
end
