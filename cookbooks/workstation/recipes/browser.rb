home = Dir.home
chef_server_url = "https://#{node['demo']['domain_prefix']}chef-server.#{node['demo']['domain']}/organizations/#{node['demo']['org']}"
delivery_url = "https://#{node['demo']['domain_prefix']}delivery.#{node['demo']['domain']}/e/#{node['demo']['enterprise']}"
compliance_url = "https://#{node['demo']['domain_prefix']}compliance.#{node['demo']['domain']}"

template "#{home}/bookmarks.html" do
  source 'bookmarks.html.erb'
  action :create
  variables(
    delivery_url: "#{delivery_url}/#/dashboard",
    insights_url: "https://#{node['demo']['domain_prefix']}delivery.#{node['demo']['domain']}/insights",
    chef_server_url: "#{chef_server_url}/nodes",
    compliance_url: "#{compliance_url}/"
  )
end

prefs = 'C:\Program Files (x86)\Google\Chrome\Application\master_preferences'

template prefs do
  source 'master_preferences.json.erb'
  variables(
    homepage: 'https://chef.io/',
    import_bookmarks_from_file: "#{home}/bookmarks.html"
  )
  action :create
end

registry_key 'Set Chrome as default HTTP protocol association' do
  action :create
  key 'HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice'
  values [
    {:name => 'Hash', :type => :string, :data => 'TW2AqyYVQlM='},
    {:name => 'ProgId', :type => :string, :data => 'ChromeHTML'}
  ]
end

registry_key 'Set Chrome as default HTTPS protocol association' do
  action :create
  key 'HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice'
  values [
    {:name => 'Hash', :type => :string, :data => '4N1og3kLvcE='},
    {:name => 'ProgId', :type => :string, :data => 'ChromeHTML'}
  ]
end
