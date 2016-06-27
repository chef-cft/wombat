# compliance

append_if_no_line "Add loopback => hostname" do
  path "/etc/hosts"
  line "127.0.0.1 #{node['demo']['domain_prefix']}compliance.#{node['demo']['domain']} compliance"
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
  file "/var/opt/chef-compliance/ssl/ca/#{node['demo']['domain_prefix']}compliance.#{node['demo']['domain']}.#{ext}" do
    content lazy { IO.read("/tmp/compliance.#{ext}") }
    action :create
  end
end

include_recipe 'wombat::etc-hosts'

compliance_server "compliance" do
  package_channel node['demo']['versions']['compliance'].split('-')[0].to_sym
  package_version node['demo']['versions']['compliance'].split('-')[1]
  admin_user 'admin'
  admin_pass node['demo']['users']['admin']['password']
  config node['ccc']['config'].to_hash
  action :install
end

template "/etc/chef-compliance/chef-compliance.rb" do
  source 'chef-compliance.rb.erb'
  variables(
    :name => "#{node['demo']['domain_prefix']}compliance.#{node['demo']['domain']}"
  )
end

delete_lines "Remove loopback entry we added earlier" do
  path "/etc/hosts"
  pattern "^127\.0\.0\.1.*localhost.*#{node['demo']['domain_prefix']}compliance\.#{node['demo']['domain']}.*compliance"
end

compliance_user 'workstation' do
  username 'workstation'
  password node['demo']['users']['workstation']['password']
end
