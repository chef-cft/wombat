# compliance

compliance_server "compliance" do
  package_version node['demo']['versions']['compliance']
  package_channel node['ccc']['package_channel'].to_sym
  admin_user 'admin'
  admin_pass node['demo']['users']['admin']['password']
  config node['ccc']['config'].to_hash
  action node['ccc']['action'].to_sym
end

# compliance_user 'admin' do
#   username 'admin'
#   password node['demo']['users']['admin']['password']
# end
