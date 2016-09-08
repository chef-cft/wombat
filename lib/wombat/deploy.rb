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
    template_file = File.read("cloudformation/#{stack}.json")
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
    @build_nodes = lock['build-nodes'].to_i
    @build_node_ami = {}
    1.upto(@build_nodes) do |i|
      @build_node_ami[i] = lock['amis'][region]['build-node'][i.to_s]
    end
    @infra = {}
    infranodes.each do |name, _rl|
      @infra[name] = lock['amis'][region]['infranodes'][name]
    end
    @workstations = lock['workstations'].to_i
    @workstation_ami = {}
    1.upto(@workstations) do |i|
      @workstation_ami[i] = lock['amis'][region]['workstation'][i.to_s]
    end
    @availability_zone = lock['aws']['az']
    @demo = lock['name']
    @version = lock['version']
    @ttl = lock['ttl']
    rendered_cfn = ERB.new(File.read('cloudformation/cfn.json.erb'), nil, '-').result(binding)
    File.open("cloudformation/#{@demo}.json", 'w') { |file| file.puts rendered_cfn }
    banner("Generate CloudFormation JSON: #{@demo}.json")
  end

  def update_lock(cloud)
    copy = {}
    copy = wombat
    region = copy[cloud]['region']
    banner('Updating wombat.lock')
    copy['amis'] = { region => {} }
    Dir.glob("packer/logs/#{cloud}*.log") do |log|
      instance = log.match('aws-(.*)\.log')[1]
      if instance =~ /build-node/
        copy['amis'][region].store('build-node', {})
        1.upto(wombat['build-nodes'].to_i) do |i|
          copy['amis'][region]['build-node'].store(i.to_s, parse_log("build-node-#{i}", "aws"))
        end
      elsif instance =~ /workstation/
        copy['amis'][region].store('workstation', {})
        1.upto(wombat['workstations'].to_i) do |i|
          copy['amis'][region]['workstation'].store(i.to_s, parse_log("workstation-#{i}", "aws"))
        end
      elsif instance =~ /infranodes/
        copy['amis'][region].store('infranodes', {})
        infranodes.each do |name, _rl|
          copy['amis'][region]['infranodes'].store(name, parse_log("infranodes-#{name}", "aws"))
        end
      else
        copy['amis'][region].store(instance, parse_log(instance, "aws"))
      end
    end
    copy['last_updated'] = Time.now.gmtime.strftime('%Y%m%d%H%M%S')
    File.open('wombat.lock', 'w') do |f|
      f.write(JSON.pretty_generate(copy))
    end
  end
end
