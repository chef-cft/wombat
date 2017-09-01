powershell_script 'Install NuGet' do
  code 'Install-PackageProvider nuget -Force'
end

powershell_script 'Install posh-git' do
  code 'Install-Module -Name posh-git -AllowClobber -Force -Scope AllUsers'
end

# PowerShell AllUsersAllHosts profile
profile = 'C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\profile.ps1'

cookbook_file profile do
  source 'ise_profile.ps1'
end
