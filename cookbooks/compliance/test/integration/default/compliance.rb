# compliance tests

describe command('hostname') do
  its('stdout') { should eq "compliance\n" }
end

describe file("/home/#{os.name}/.ssh/authorized_keys") do
  its('content') { should include file("/tmp/public.pub").content }
  it { should exist }
end

describe package('chef-compliance') do
  it { should be_installed }
end

%w(crt key).each do |ext|
  describe file("/var/opt/chef-compliance/ssl/ca/compliance.animals.biz.#{ext}") do
    its('content') { should eq file("/tmp/compliance.#{ext}").content }
  end
end

describe file('/etc/hosts') do
  its('content') { should match /172.31.54.10\s.*chef.animals.biz chef/ }
  its('content') { should match /172.31.54.11\s.*automate.animals.biz automate/ }
  its('content') { should match /172.31.54.12\s.*compliance.animals.biz compliance/ }
  its('content') { should match /172.31.54.51\s.*build-node-1.animals.biz build-node-1/ }
  its('content') { should match /172.31.54.201\s.*workstation-1.animals.biz workstation-1/ }
end
