# build-node tests

describe file('/home/vagrant/.ssh/authorized_keys') do
  its('content') { file("/tmp/private.pem").content }
end

%w(chef-server delivery compliance).each do |hostname|
  describe file("/etc/chef/trusted_certs/#{hostname}_chordata_biz.crt") do
    its('content') { should eq file("/tmp/#{hostname}.crt").content }
  end
end

describe file('/etc/chef/client.pem') do
  its('content') { file("/tmp/private.pem").content }
end

describe file('/etc/chef/client.rb') do
  its('content') { should match /chef_server_url\s.*'https:\/\/chef-server.chordata.biz\/organizations\/diprotodontia'/ }
  its('content') { should match /client_key\s.*'\/etc\/chef\/client.pem'/}
  its('content') { should match /node_name\s.*'build-node-1'/}
end

describe file('/etc/hosts') do
  its('content') { should match /172.31.54.12\s.*build-node-1 build-node-1.chordata.biz/ }
  its('content') { should match /172.31.54.10\s.*chef-server chef-server.chordata.biz/ }
  its('content') { should match /172.31.54.11\s.*delivery delivery.chordata.biz/ }
end

describe package('chefdk') do
  it { should be_installed }
end

# verify dbuild user

# verify delivery workspace

# verify delivery configs
