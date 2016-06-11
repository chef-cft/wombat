
powershell_script 'Install PSGet' do
  code <<-EOH
    (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
  EOH
end

powershell_script 'Install posh-git' do
  code <<-EOH
    Install-Module posh-git
  EOH
end
