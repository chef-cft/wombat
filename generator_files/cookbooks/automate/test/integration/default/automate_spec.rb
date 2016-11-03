# automate tests

describe command('hostname') do
  its('stdout') { should eq "automate\n" }
end

describe file('/usr/local/bin/jq') do
  it { should exist }
  it { should be_executable }
end

describe file("/home/#{os.name}/.ssh/authorized_keys") do
  its('content') { should include file("/tmp/public.pub").content }
  it { should exist }
end

describe package('delivery') do
  it { should be_installed }
end

describe file('/etc/delivery/automate.pem') do
  its('content') { file("/tmp/private.pem").content }
end

describe file('/var/opt/delivery/license/delivery.license') do
  its('content') { file("/tmp/delivery.license").content }
end

describe file('/etc/delivery/builder_key.pub') do
  its('content') { file("/tmp/public.pub").content }
end

%w(crt key).each do |ext|
  describe file("/var/opt/delivery/nginx/ca/automate.animals.biz.#{ext}") do
    its('content') { should eq file("/tmp/automate.#{ext}").content }
  end
end

describe file('/etc/delivery/delivery.rb') do
  its('content') { should match /delivery_fqdn\s.*"automate.animals.biz"/ }
  its('content') { should match /delivery\['chef_username'\]\s.*=\s.*"automate"/ }
  its('content') { should match /delivery\['chef_private_key'\]\s.*=\s.*"\/etc\/delivery\/automate\.pem"/ }
  its('content') { should match /delivery\['chef_server'\]\s.*"https:\/\/chef.animals.biz\/organizations\/marsupials"/ }
  its('content') { should match /insights\['enable'\]\s.*=\s.*true/ }
end

describe file('/etc/hosts') do
  its('content') { should match /172.31.54.10\s.*chef.animals.biz chef/ }
  its('content') { should match /172.31.54.11\s.*automate.animals.biz automate/ }
  its('content') { should match /172.31.54.12\s.*compliance.animals.biz compliance/ }
  its('content') { should match /172.31.54.51\s.*build-node-1.animals.biz build-node-1/ }
  its('content') { should match /172.31.54.201\s.*workstation-1.animals.biz workstation-1/ }
end

# add tests to verify users and passwords
# delivery-ctl list-users doesn't work
