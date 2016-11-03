home = Dir.home
chef_server_url = "https://#{node['demo']['domain_prefix']}chef.#{node['demo']['domain']}/organizations/#{node['demo']['org']}"
automate_url = "https://#{node['demo']['domain_prefix']}automate.#{node['demo']['domain']}/e/#{node['demo']['enterprise']}"
compliance_url = "https://#{node['demo']['domain_prefix']}compliance.#{node['demo']['domain']}"

template "#{home}/bookmarks.html" do
  source 'bookmarks.html.erb'
  action :create
  variables(
    automate_url: "#{automate_url}/#/dashboard",
    viz_url: "https://#{node['demo']['domain_prefix']}automate.#{node['demo']['domain']}/viz",
    chef_server_url: "#{chef_server_url}/nodes",
    compliance_url: "#{compliance_url}/",
    tutorial_url: node['demo']['tutorial_url']
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

# Enable ClearType for Chrome 52+
registry_key "HKEY_CURRENT_USER\\Control Panel\\Desktop" do
  values [{
      :name => "FontSmoothing",
      :type => :string,
      :data => 2
  },{
      :name => "FontSmoothingType",
      :type => :dword,
      :data => 2
  }]
  action :create
end
