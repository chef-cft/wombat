# Build all the things in a vagrant box
require 'securerandom'

include_recipe 'apt'

chef_ingredient 'chefdk' do
  channel node['demo']['versions']['chefdk'].split('-')[0].to_sym
  version node['demo']['versions']['chefdk'].split('-')[1]
end

gem_package 'parallel' do
  action :install
end

workspace_dir = "/tmp/wombat-#{SecureRandom.hex(8)}"
output_dir = "/tmp/wombat/output"
aws_settings = node['wombat']['packer']['aws']
azure_settings = node['wombat']['packer']['azure']

execute 'create workspace for wombat' do
  command "cp -rf /tmp/wombat #{workspace_dir}"
  creates workspace_dir
end

config_hash = {
    "name" => "wombat",
    "domain" => node['demo']['domain'],
    "enterprise" => node['demo']['enterprise'],
    "org" => node['demo']['org'],
    "build-nodes" => node['demo']['build-nodes'].to_s,
    "infranodes" => node['demo']['infranodes'].to_h,
    "version" => '0.0.12'.to_f,
    "products" => node['demo']['versions'].to_h,
    "aws" => {
        "region" => aws_settings['region'],
        "az" => "#{aws_settings['region']}a",
        "keypair" => aws_settings['keypair'],
        "source_ami" => aws_settings['source_ami'].to_h
    },
}

file File.join(workspace_dir, 'wombat.yml') do
  content config_hash.to_yaml
end

execute 'clean packer/logs dir' do
  command 'rm -rf packer/logs/*'
  cwd workspace_dir
  live_stream true
  not_if do
    Dir.glob("#{workspace_dir}/packer/logs/*.log").empty?
  end
end

execute 'clean certs and keys' do
  command 'rm -rf packer/keys/*'
  cwd workspace_dir
  live_stream true
  not_if do
    Dir.glob("#{workspace_dir}/packer/keys/*").empty?
  end
end

execute 'generate certs and keys' do
  command 'rake keys:create'
  cwd workspace_dir
  live_stream true
end

execute 'build amis with rake' do
  command 'rake packer:build_amis_parallel'
  cwd workspace_dir
  live_stream true
  environment(
      'AWS_REGION' => aws_settings['region'],
      'AWS_SECRET_ACCESS_KEY' => aws_settings['secret_key'],
      'AWS_ACCESS_KEY_ID' => aws_settings['access_key'],
      'AZURE_TENANT_ID' => azure_settings['tenant_id'],
      'AZURE_CLIENT_ID' => azure_settings['client_id'],
      'AZURE_CLIENT_SECRET' => azure_settings['client_secret'],
      'AZURE_SUBSCRIPTION_ID' => azure_settings['subscription_id'],
      'AZURE_RESOURCE_GROUP' => azure_settings['resource_group'],
      'AZURE_STORAGE_ACCOUNT' => azure_settings['storage_account']
  )
end

execute 'update lock file' do
  command 'rake update_lock && cat wombat.lock'
  cwd workspace_dir
  live_stream true
end

execute 'create cfn template' do
  command 'rake cfn:create_template'
  cwd workspace_dir
  live_stream true
end

directory output_dir

file File.join(output_dir, 'wombat.lock') do
  content IO.read(File.join(workspace_dir, 'wombat.lock'))
end

file File.join(output_dir, 'cfn_template.json') do
  content IO.read(File.join(workspace_dir, 'cloudformation', 'wombat.json'))
end