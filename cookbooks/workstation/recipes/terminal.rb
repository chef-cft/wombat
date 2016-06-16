cookbook_file 'C:\Program Files\ConEmu\ConEmu.xml' do
  source 'conemu.xml'
  sensitive true
  action :create
end
