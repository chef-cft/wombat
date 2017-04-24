include_recipe 'chocolatey::default'

node['demo']['pkgs'].each do |pkg|
  chocolatey_package pkg do
    options '--allow-empty-checksums'
  end
end

chocolatey_package 'GoogleChrome' do
  options '--ignorechecksum'
  version '57.0.2987.13301'
end

include_recipe 'workstation::certs-keys'
include_recipe 'workstation::terminal'
include_recipe 'workstation::browser'
include_recipe 'workstation::editor'
include_recipe 'workstation::chef'
include_recipe 'workstation::profile'
include_recipe 'wombat::etc-hosts'
include_recipe 'workstation::dotnet'
