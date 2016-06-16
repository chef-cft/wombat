home = Dir.home
# PowerShell AllUsersAllHosts profile
profile = "#{home}/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"

template profile do
  source 'ise_profile.ps1.erb'
  variables(
    home: home
  )
end
