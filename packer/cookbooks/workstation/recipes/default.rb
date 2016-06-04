include_recipe 'chocolatey'

home = Dir.home
%W(
  #{home}/.chef
  #{home}/.chef/trusted_certs
  #{home}/.ssh
).each do |directory|
  directory directory
end

%w(chef-server delivery compliance).each do |f|
  file "#{home}/.chef/trusted_certs/#{f}_#{node['demo']['domain'].tr('.','_')}.crt" do
    content IO.read("C:/Windows/Temp/#{f}.crt")
    action :create
  end
  
  powershell_script 'Install certs to Root CA' do
    code <<-EOH
      Import-Certificate -FilePath C:/Windows/Temp/#{f}.crt -CertStoreLocation Cert:/LocalMachine/Root
    EOH
  end
end

%W(#{home}/.chef/private.pem #{home}/.ssh/id_rsa).each do |path|
  file path do
    content IO.read("C:/Windows/Temp/private.pem")
    action :create
  end
end

template "#{home}/.chef/knife.rb" do
  source 'knife.rb.erb'
  variables(
    home: home,
    chef_server_url: node['demo']['chef_server_url'],
  )
end

template "#{home}/.ssh/config" do
  source 'ssh_config.erb'
  variables(
    home: home,
    org: node['demo']['org']
  )
end

node['demo']['hosts'].each do |hostname, ipaddress|
  hostsfile_entry ipaddress do
    hostname  hostname
    aliases   ["#{hostname}.#{node['demo']['domain']}"]
    action    :create
  end
end

node['demo']['pkgs'].each do |pkg|
  chocolatey pkg
end

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

template "#{home}/bookmarks.html" do
  source 'bookmarks.html.erb'
  action :create
  variables(
    delivery_url: "#{node['demo']['delivery_url']}/#/dashboard",
    chef_server_url: "#{node['demo']['chef_server_url']}/nodes"
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

include_recipe 'workstation::psreadline'
include_recipe 'workstation::poshgit'

# PowerShell AllUsersAllHosts profile
profile = "#{home}/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"

template profile do
  source 'ise_profile.ps1.erb'
  variables(
    home: home
  )
end
