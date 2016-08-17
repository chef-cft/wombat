# chef-server tests

describe command('hostname') do
  its('stdout') { should eq "chef-server\n" }
end

describe file('/home/vagrant/.ssh/authorized_keys') do
  its('content') { file("/tmp/public.pub").content }
end

describe package('chef-server-core') do
  it { should be_installed }
  its('version') { should match '12.7.0' }
end

describe package('chef-manage') do
  it { should be_installed }
  its('version') { should match '2.3.0' }
end

describe package('opscode-push-jobs-server') do
  it { should be_installed }
  its('version') { should match '1.1.6' }
end

describe command('chef-server-ctl org-list') do
  its('stdout') { should eq "marsupials\n" }
end

describe command('chef-server-ctl user-list') do
  its('stdout') { should match "workstation" }
  its('stdout') { should match "delivery" }
  its('stdout') { should match "pivotal" }
end

%w(crt key).each do |ext|
  describe file("/var/opt/opscode/nginx/ca/chef.animals.biz.#{ext}") do
    its('content') { should eq file("/tmp/chef-server.#{ext}").content }
  end
end

describe file('/etc/hosts') do
  its('content') { should match /172.31.54.10\s.*chef chef.animals.biz/ }
  its('content') { should match /172.31.54.11\s.*automate automate.animals.biz/ }
  its('content') { should match /172.31.54.12\s.*build-node-1 build-node-1.animals.biz/ }
  its('content') { should match /172.31.54.13\s.*compliance compliance.animals.biz/ }
end
