atom_pkg = "#{ENV['ProgramW6432']}\\Atom x64"
atom_home = "#{home}\\.atom"

[atom_pkg,
 atom_home].each do |d|
  directory d do
    action :create
  end
end

windows_zipfile ENV['ProgramW6432'] do
  source 'https://atom.io/download/windows_x64_zip'
  action :unzip
  not_if { ::File.exist?("#{atom_pkg}\\atom.exe") }
end

windows_path "#{atom_pkg}\\resources\\cli" do
  action :add
end

["#{ENV['ALLUSERSPROFILE']}\\Microsoft\\Windows\\Start Menu\\Programs\\Atom.lnk",
 "#{ENV['PUBLIC']}\\Desktop\\Atom.lnk"].each do |p|
  windows_shortcut p do
    target "#{atom_pkg}\\atom.exe"
    description 'Launch Atom Editor'
    action :create
  end
end

cookbook_file "#{atom_home}\\config.cson" do
  source 'atom.config.cson'
  action :create
end

cookbook_file "#{atom_home}\\apm-bootstrap.list" do
  source 'atom.apm.list'
  action :create
end

execute 'install Atom packages' do
  command "apm.cmd install --packages-file #{atom_home}\\apm-bootstrap.list"
  cwd "#{atom_pkg}\\resources\\app\\apm\\bin"
  environment ({ 'ATOM_HOME' => atom_home })
  action :run
  not_if { File.exist?("#{atom_home}\\packages\\language-chef\\README.md") }
end
