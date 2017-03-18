chef_server_url = "https://#{node['demo']['domain_prefix']}chef.#{node['demo']['domain']}/organizations/#{node['demo']['org']}"
conf_d_dir = File.join(home, '.chef', 'config.d')

chef_ingredient 'chefdk' do
  channel node['demo']['versions']['chefdk'].split('-')[0].to_sym
  version node['demo']['versions']['chefdk'].split('-')[1]
  action :install
end

template "#{home}/.chef/knife.rb" do
  source 'knife.rb.erb'
  variables(
    home: home,
    node_name: "workstation-#{node['demo']['workstation-number']}",
    chef_server_url: chef_server_url,
    data_collector_url: "https://#{node['demo']['domain_prefix']}automate.#{node['demo']['domain']}",
    conf_d_dir: conf_d_dir
  )
end

directory conf_d_dir

template File.join(conf_d_dir, 'data_collector.rb') do
  source 'data_collector.rb.erb'
  variables(
    data_collector_url: "https://#{node['demo']['domain_prefix']}automate.#{node['demo']['domain']}"
  )
end
