execute 'DrainNGenQueue' do
  command 'ngen.exe executeQueuedItems'
  cwd 'C:\Windows\Microsoft.NET\Framework\v4.0.30319'
end

execute 'DrainNGenQueue64' do
  command 'ngen.exe executeQueuedItems'
  cwd 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319'
end

windows_task '\Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319' do
  action :run
end

windows_task '\Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64' do
  action :run
end
