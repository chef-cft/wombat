# compliance

apt_update 'packages' do
  action :update
  only_if { node['platform_family'] == 'debian' }
end

append_if_no_line "Add temporary hostsfile entry: #{node['ipaddress']}" do
  path "/etc/hosts"
  line "#{node['ipaddress']} #{node['demo']['domain_prefix']}compliance.#{node['demo']['domain']} compliance"
end

execute 'set hostname' do
  command 'hostnamectl set-hostname compliance'
  action :run
end

directory '/var/opt/chef-compliance'
directory '/var/opt/chef-compliance/ssl'
directory '/var/opt/chef-compliance/ssl/ca'


%w(crt key).each do |ext|
  file "/var/opt/chef-compliance/ssl/ca/#{node['demo']['domain_prefix']}compliance.#{node['demo']['domain']}.#{ext}" do
    content lazy { IO.read("/tmp/compliance.#{ext}") }
    action :create
    sensitive true
  end
end

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

1.upto(node['demo']['workstations'].to_i) do |i|
  compliance_user "workstation-#{i}" do
    username "workstation-#{i}"
    password node['demo']['users']["workstation-#{i}"]['password']
  end
end

delete_lines "Remove temporary hostfile entry we added earlier" do
  path "/etc/hosts"
  pattern "^#{node['ipaddress']}.*#{node['demo']['domain_prefix']}compliance\.#{node['demo']['domain']}.*compliance"
end
