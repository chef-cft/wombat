# delivery tests

describe command('hostname') do
  its('stdout') { should eq "delivery\n" }
end

describe file('/usr/local/bin/jq') do
  it { should exist }
  it { should be_executable }
end

describe file('/home/vagrant/.ssh/authorized_keys') do
  its('content') { file("/tmp/public.pub").content }
end

describe package('chefdk') do
  it { should be_installed }
end

describe package('delivery') do
  it { should be_installed }
end

describe file('/etc/delivery/delivery.pem') do
  its('content') { file("/tmp/private.pem").content }
end

describe file('/var/opt/delivery/license/delivery.license') do
  its('content') { file("/tmp/delivery.license").content }
end

describe file('/etc/delivery/builder_key.pub') do
  its('content') { file("/tmp/public.pub").content }
end

%w(crt key).each do |ext|
  describe file("/var/opt/delivery/nginx/ca/delivery.animals.biz.#{ext}") do
    its('content') { should eq file("/tmp/delivery.#{ext}").content }
  end
end

describe file('/etc/delivery/delivery.rb') do
  its('content') { should match /delivery_fqdn\s.*"delivery.animals.biz"/ }
  its('content') { should match /delivery\['chef_username'\]\s.*=\s.*"delivery"/ }
  its('content') { should match /delivery\['chef_private_key'\]\s.*=\s.*"\/etc\/delivery\/delivery\.pem"/ }
  its('content') { should match /delivery\['chef_server'\]\s.*"https:\/\/chef-server.animals.biz\/organizations\/marsupials"/ }
  its('content') { should match /insights\['enable'\]\s.*=\s.*true/ }
end

describe file('/etc/hosts') do
  its('content') { should match /172.31.54.12\s.*build-node-1 build-node-1.animals.biz/ }
  its('content') { should match /172.31.54.10\s.*chef-server chef-server.animals.biz/ }
  its('content') { should match /172.31.54.11\s.*delivery delivery.animals.biz/ }
end

# add tests to verify users and passwords
# delivery-ctl list-users doesn't work
