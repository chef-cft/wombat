home = Dir.home

remote_file "#{home}/PSReadline.zip" do
  source 'https://github.com/lzybkr/PSReadLine/releases/download/Latest/PSReadline.zip'
  action :create
end

modules = "#{home}/Documents/WindowsPowerShell/modules"

directory "#{modules}/PSReadLine" do
  action :create
  recursive true
end

powershell_script 'Extract PSReadline' do
  code <<-EOH
  [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
  [System.IO.Compression.ZipFile]::ExtractToDirectory('#{home}/PSReadLine.zip', '#{modules}/PSReadLine')
  EOH
end
