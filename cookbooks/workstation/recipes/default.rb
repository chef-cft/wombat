include_recipe 'chocolatey'

home = Dir.home
%W(
  #{home}/.chef
  #{home}/.chef/trusted_certs
  #{home}/.ssh
).each do |directory|
  directory directory
end

template "#{home}/.ssh/config" do
  source 'ssh_config.erb'
  variables(
    home: home,
    org: node['demo']['org']
  )
end

node['demo']['pkgs'].each do |pkg|
  chocolatey pkg
end

include_recipe 'workstation::certs-keys'
include_recipe 'workstation::chef'
include_recipe 'workstation::chrome'
include_recipe 'workstation::psreadline'
include_recipe 'workstation::poshgit'
include_recipe 'workstation::profile'
include_recipe 'workstation::terminal'
include_recipe 'wombat::etc-hosts'
