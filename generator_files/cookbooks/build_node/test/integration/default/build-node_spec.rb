# build-node tests

describe file("/home/#{os.name}/.ssh/authorized_keys") do
  its('content') { should include file("/tmp/public.pub").content }
  it { should exist }
end

%w(chef automate compliance).each do |hostname|
  describe file("/etc/chef/trusted_certs/#{hostname}_animals_biz.crt") do
    its('content') { should eq file("/tmp/#{hostname}.crt").content }
  end
end

describe file('/etc/chef/client.pem') do
  its('content') { file("/tmp/private.pem").content }
end

describe file('/etc/chef/client.rb') do
  its('content') { should match /chef_server_url\s.*'https:\/\/chef.animals.biz\/organizations\/marsupials'/ }
  its('content') { should match /client_key\s.*'\/etc\/chef\/client.pem'/}
  its('content') { should match /node_name\s.*'build-node-1'/}
end

describe file('/etc/hosts') do
  its('content') { should match /172.31.54.10\s.*chef.animals.biz chef/ }
  its('content') { should match /172.31.54.11\s.*automate.animals.biz automate/ }
  its('content') { should match /172.31.54.12\s.*compliance.animals.biz compliance/ }
  its('content') { should match /172.31.54.51\s.*build-node-1.animals.biz build-node-1/ }
  its('content') { should match /172.31.54.201\s.*workstation-1.animals.biz workstation-1/ }
end

describe package('chefdk') do
  it { should be_installed }
end

# verify dbuild user

# verify delivery workspace

# verify delivery configs
