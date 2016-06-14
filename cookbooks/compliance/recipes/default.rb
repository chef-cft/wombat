# compliance

append_if_no_line "Add loopback => hostname" do
  path "/etc/hosts"
  line "127.0.0.1 compliance.#{node['demo']['domain']} compliance"
end

execute 'set hostname' do
  command 'hostnamectl set-hostname compliance'
  action :run
end

append_if_no_line "Add certificate to authorized_keys" do
  path "/home/#{node['demo']['admin-user']}/.ssh/authorized_keys"
  line lazy { IO.read('/tmp/public.pub') }
end

directory '/var/opt/chef-compliance'
directory '/var/opt/chef-compliance/ssl'
directory '/var/opt/chef-compliance/ssl/ca'


%w(crt key).each do |ext|
  file "/var/opt/chef-compliance/ssl/ca/compliance.#{node['demo']['domain']}.#{ext}" do
    content lazy { IO.read("/tmp/compliance.#{ext}") }
    action :create
  end
end

compliance_server "compliance" do
  package_version node['demo']['versions']['compliance']
  package_channel :stable
  admin_user 'admin'
  admin_pass node['demo']['users']['admin']['password']
  config node['ccc']['config'].to_hash
  action :install
end

include_recipe 'wombat::etc-hosts'

delete_lines "Remove loopback entry we added earlier" do
  path "/etc/hosts"
  pattern "^127\.0\.0\.1.*localhost.*compliance\.#{node['demo']['domain']}.*compliance"
end

compliance_user 'workstation' do
  username 'admin'
  password node['demo']['users']['admin']['password']
end
