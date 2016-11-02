# chef-server tests

describe command('hostname') do
  its('stdout') { should eq "chef\n" }
end

describe file("/home/#{os.name}/.ssh/authorized_keys") do
  its('content') { should include file("/tmp/public.pub").content }
  it { should exist }
end

describe package('chef-server-core') do
  it { should be_installed }
  its('version') { should match '12.8.0' }
end

describe package('chef-manage') do
  it { should be_installed }
  its('version') { should match '2.4.3' }
end

version = os.debian? ? '2.1.0' : '1.1.6'

describe package('opscode-push-jobs-server') do
  it { should be_installed }
  its('version') { should match version }
end

describe command('chef-server-ctl org-list') do
  its('stdout') { should eq "marsupials\n" }
end

describe command('chef-server-ctl user-list') do
  its('stdout') { should match "workstation-1" }
  its('stdout') { should match "automate" }
  its('stdout') { should match "pivotal" }
end

%w(crt key).each do |ext|
  describe file("/var/opt/opscode/nginx/ca/chef.animals.biz.#{ext}") do
    its('content') { should eq file("/tmp/chef.#{ext}").content }
  end
end

describe file('/etc/hosts') do
  its('content') { should match /172.31.54.10\s.*chef.animals.biz chef/ }
  its('content') { should match /172.31.54.11\s.*automate.animals.biz automate/ }
  its('content') { should match /172.31.54.12\s.*compliance.animals.biz compliance/ }
  its('content') { should match /172.31.54.51\s.*build-node-1.animals.biz build-node-1/ }
end
