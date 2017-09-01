powershell_script 'Disable Windows Defender Realtime Monitoring' do
  code 'Set-MpPreference -DisableRealtimeMonitoring 1'
end

include_recipe 'chocolatey::default'

node['demo']['pkgs'].each do |pkg|
  chocolatey_package pkg do
    options '--allow-empty-checksums'
  end
end

chocolatey_package 'GoogleChrome' do
  options '--ignore-checksum'
end

include_recipe 'workstation::certs-keys'
include_recipe 'workstation::terminal'
include_recipe 'workstation::browser'
include_recipe 'workstation::editor'
include_recipe 'workstation::chef'
include_recipe 'workstation::profile'
include_recipe 'wombat::etc-hosts'
include_recipe 'workstation::dotnet'
