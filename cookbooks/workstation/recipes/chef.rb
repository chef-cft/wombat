home = Dir.home
chef_server_url = "https://chef-server.#{node['demo']['domain']}/organizations/#{node['demo']['org']}"
conf_d_dir = File.join(home, '.chef', 'config.d')

chef_ingredient 'chefdk' do
  version node['demo']['versions']['chefdk']
  action :install
end

template "#{home}/.chef/knife.rb" do
  source 'knife.rb.erb'
  variables(
    home: home,
    chef_server_url: chef_server_url,
    data_collector_url: "https://delivery.#{node['demo']['domain']}",
    conf_d_dir: conf_d_dir
  )
end

directory conf_d_dir

template File.join(conf_d_dir, 'data_collector.rb') do
  source 'data_collector.rb.erb'
  variables(
    data_collector_url: "https://delivery.#{node['demo']['domain']}"
  )
end
