# default attributes

default['demo']['org'] = 'diprotodontia'
default['demo']['domain'] = 'chordata.biz'
default['demo']['chef_server_url'] = "https://chef-server.#{node['demo']['domain']}/organizations/#{node['demo']['org']}"
default['demo']['delivery_url'] = "https://delivery.#{node['demo']['domain']}/e/#{node['demo']['org']}"

default['demo']['hosts'] = {
  'chef-server' => '172.31.54.10',
  'delivery' => '172.31.54.11',
  'build-node-1' => '172.31.54.12'
}

default['demo']['pkgs'] = %w(
  cmder
  conemu
  googlechrome
  visualstudiocode
  atom
  git
  gitextensions
  git-credential-manager-for-windows
  slack
)
