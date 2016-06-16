cookbook_file 'C:\Program Files\ConEmu\ConEmu.xml' do
  source 'conemu.xml'
  sensitive true
  action :create
end

cookbook_file 'C:\tools\cmder\config\ConEmu.xml' do
  source 'cmder.xml'
  sensitive true
  action :create
end
