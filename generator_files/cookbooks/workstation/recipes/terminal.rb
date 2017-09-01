cookbook_file 'C:\tools\cmder\config\ConEmu.xml' do
  source 'cmder.xml'
  sensitive true
  action :create
end

windows_shortcut "#{home}/Desktop/cmder.lnk" do
  target 'C:\\tools\\cmder\\Cmder.exe'
  description 'Launch Notepad'
  iconlocation 'C:\\tools\\cmder\\cmder.exe,0'
end
