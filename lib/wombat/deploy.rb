require 'wombat/common'
require 'aws-sdk'

class DeployRunner
  include Common

  attr_reader :stack, :cloud

  def initialize(opts)
    @stack = opts.stack
    @cloud = opts.cloud.nil? ? "aws" : opts.cloud
  end

  def start
    case cloud
    when 'aws'
      update_lock(cloud)
      create_template
      create_stack(stack)
    end
  end

  private

  def create_stack(stack)
    template_file = File.read("#{stack_dir}/#{stack}.json")
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
    banner('Creating template...')
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
    rendered_cfn = ERB.new(File.read('templates/cfn.json.erb'), nil, '-').result(binding)
    File.open("#{stack_dir}/#{@demo}.json", 'w') { |file| file.puts rendered_cfn }
    banner("Generate CloudFormation JSON: #{@demo}.json")
  end

  def logs
    Dir.glob("#{log_dir}/#{cloud}*.log").reject { |l| !l.match(wombat['linux']) }
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
        copy['amis'][region].store('build-node', {})
        1.upto(wombat['build-nodes']['count'].to_i) do |i|
          copy['amis'][region]['build-node'].store(i.to_s, parse_log(log, cloud))
        end
      when /workstation/
        copy['amis'][region].store('workstation', {})
        1.upto(wombat['workstations']['count'].to_i) do |i|
          copy['amis'][region]['workstation'].store(i.to_s, parse_log(log, cloud))
        end
      when /infranodes/
        copy['amis'][region].store('infranodes', {})
        infranodes.each do |name, _rl|
          copy['amis'][region]['infranodes'].store(name, parse_log(log, cloud))
        end
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
