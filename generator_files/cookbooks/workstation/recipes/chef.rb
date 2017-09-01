conf_d_dir = File.join(home, '.chef', 'config.d')

chef_ingredient 'chefdk' do
  channel node['demo']['versions']['chefdk'].split('-')[0].to_sym
  version node['demo']['versions']['chefdk'].split('-')[1]
  platform 'windows'
  platform_version '2016'
  architecture 'x86_64'
  platform_version_compatibility_mode true
  action :install
end

template "#{home}/.chef/knife.rb" do
  source 'knife.rb.erb'
  variables(
    node_name: "workstation-#{node['demo']['workstation-number']}",
    chef_server_url: "https://#{node['demo']['domain_prefix']}chef.#{node['demo']['domain']}/organizations/#{node['demo']['org']}",
    data_collector_url: "https://#{node['demo']['domain_prefix']}automate.#{node['demo']['domain']}"
  )
end

directory conf_d_dir

template File.join(conf_d_dir, 'data_collector.rb') do
  source 'data_collector.rb.erb'
  variables(
    data_collector_url: "https://#{node['demo']['domain_prefix']}automate.#{node['demo']['domain']}"
  )
end
