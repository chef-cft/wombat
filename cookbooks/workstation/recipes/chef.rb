home = Dir.home

# chef-ingredient was timing out / being weird
powershell_script 'Install ChefDK' do
  code <<-EOH
    . { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -channel current -project chefdk
  EOH
end

chef_ingredient 'delivery-cli' do
  version :latest
  action :install
  platform_version_compatibility_mode true
end

template "#{home}/.chef/knife.rb" do
  source 'knife.rb.erb'
  variables(
    home: home,
    chef_server_url: node['demo']['chef_server_url'],
  )
end
