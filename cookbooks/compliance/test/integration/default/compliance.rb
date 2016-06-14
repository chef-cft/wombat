# compliance tests

describe command('hostname') do
  its('stdout') { should eq "compliance\n" }
end

describe file('/home/vagrant/.ssh/authorized_keys') do
  its('content') { file("/tmp/public.pub").content }
end

describe package('chef-compliance') do
  it { should be_installed }
end

%w(crt key).each do |ext|
  describe file("/var/opt/chef-compliance/ssl/ca/compliance.chordata.biz.#{ext}") do
    its('content') { should eq file("/tmp/compliance.#{ext}").content }
  end
end

describe file('/etc/hosts') do
  its('content') { should match /172.31.54.10\s.*chef-server chef-server.chordata.biz/ }
  its('content') { should match /172.31.54.11\s.*delivery delivery.chordata.biz/ }
  its('content') { should match /172.31.54.12\s.*build-node-1 build-node-1.chordata.biz/ }
  its('content') { should match /172.31.54.13\s.*compliance compliance.chordata.biz/ }
end
