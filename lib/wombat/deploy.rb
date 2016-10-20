require 'wombat/common'
require 'aws-sdk'

class DeployRunner
  include Common

  attr_reader :stack, :cloud, :lock_opt, :template_opt

  def initialize(opts)
    @stack = opts.stack
    @cloud = opts.cloud.nil? ? "aws" : opts.cloud
    @lock_opt = opts.update_lock
    @template_opt = opts.create_template
  end

  def start
    case cloud
    when 'aws'
      update_lock(cloud) if lock_opt
      create_template if template_opt
      create_stack(stack)
    end
  end

  private

  def create_stack(stack)
    template_file = File.read("#{conf['stack_dir']}/#{@demo}.json")
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

  def create_template
    region = lock['aws']['region']
    @chef_server_ami = lock['amis'][region]['chef-server']
    @automate_ami = lock['amis'][region]['automate']
    @compliance_ami = lock['amis'][region]['compliance']
    @build_nodes = lock['build-nodes']['count'].to_i
    @build_node_ami = {}
    1.upto(@build_nodes) do |i|
      @build_node_ami[i] = lock['amis'][region]['build-node'][i.to_s]
    end
    @infra = {}
    infranodes.each do |name, _rl|
      @infra[name] = lock['amis'][region]['infranodes'][name]
    end
    @workstations = lock['workstations']['count'].to_i
    @workstation_ami = {}
    1.upto(@workstations) do |i|
      @workstation_ami[i] = lock['amis'][region]['workstation'][i.to_s]
    end
    @availability_zone = lock['aws']['az']
    @demo = lock['name']
    @version = lock['version']
    @ttl = lock['ttl']
    rendered_cfn = ERB.new(File.read("#{conf['template_dir']}/cfn.json.erb"), nil, '-').result(binding)
    File.open("#{conf['stack_dir']}/#{@demo}.json", 'w') { |file| file.puts rendered_cfn }
    banner("Generated: #{conf['stack_dir']}/#{@demo}.json")
  end

  def logs
    Dir.glob("#{conf['log_dir']}/#{cloud}*.log").reject { |l| !l.match(wombat['linux']) }
  end

  def update_lock(cloud)
    banner('Updating wombat.lock')

    copy = {}
    copy = wombat
    region = copy[cloud]['region']
    linux = copy['linux']
    copy['amis'] = { region => {} }
    logs.each do |log|
      case log
      when /build-node/
        copy['amis'][region]['build-node'] ||= {}
        num = log.split('-')[3]
        copy['amis'][region]['build-node'].store(num, parse_log(log, cloud))
      when /workstation/
        copy['amis'][region]['workstation'] ||= {}
        num = log.split('-')[2]
        copy['amis'][region]['workstation'].store(num, parse_log(log, cloud))
      when /infranodes/
        copy['amis'][region]['infranodes'] ||= {}
        name = log.split('-')[2]
        copy['amis'][region]['infranodes'].store(name, parse_log(log, cloud))
      else
        instance = log.match("#{cloud}-(.*)-(.*)\.log")[1]
        copy['amis'][region].store(instance, parse_log(log, cloud))
      end
    end
    copy['last_updated'] = Time.now.gmtime.strftime('%Y%m%d%H%M%S')
    File.open('wombat.lock', 'w') do |f|
      f.write(JSON.pretty_generate(copy))
    end
  end
end
