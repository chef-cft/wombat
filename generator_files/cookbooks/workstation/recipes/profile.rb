modules = "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\Modules"

posh_git_ps = "Install-Module posh-git -Destination #{modules}"

powershell_script 'Install PSGet' do
  code <<-EOH
    (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
  EOH
end

powershell_script 'Install posh-git' do
  code posh_git_ps
end

remote_file "#{home}/PSReadline.zip" do
  source 'https://github.com/lzybkr/PSReadLine/releases/download/Latest/PSReadline.zip'
  action :create
end

directory "#{modules}/PSReadLine" do
  action :create
  recursive true
end

powershell_script 'Extract PSReadline' do
  code <<-EOH
  [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
  [System.IO.Compression.ZipFile]::ExtractToDirectory('#{home}/PSReadLine.zip', '#{modules}/PSReadLine')
  EOH
  not_if { File.exist?("#{modules}/PSReadLine/PSReadline.dll") }
end

# PowerShell AllUsersAllHosts profile
profile = "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\profile.ps1"

template profile do
  source 'ise_profile.ps1.erb'
  variables(
    home: home
  )
end
