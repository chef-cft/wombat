default['wombat']['packer']['aws'].tap do |a|
  a['region'] = "us-west-2"
  a['secret_key'] = "xxxxx"
  a['access_key'] = "xxxxx"
  a['keypair'] = "xxxxx"
  a['source_ami']['ubuntu'] = "ami-8c4cb0ec"
  a['source_ami']['windows'] = "ami-1712d877"
end

default['wombat']['packer']['azure'].tap do |az|
  az['client_id'] = "xxxxx"
  az['tenant_id'] = "xxxxx"
  az['client_secret'] = "xxxxx"
  az['subscription_id'] = "xxxxx"
  az['storage_account'] = "xxxxx"
  az['resource_group'] = "xxxxx"
end

