run_home = Dir.home
directory "#{home}/.atom"

cookbook_file "#{home}/.atom/config.cson" do
  source 'atom.config.cson'
  action :create
end

cookbook_file "#{home}/.atom/apm-bootstrap.list" do
  source 'atom.apm.list'
  action :create
end

execute 'install Atom packages' do
  command "#{run_home}/AppData/Local/atom/bin/apm install --packages-file #{home}/.atom/apm-bootstrap.list"
  action :run
  not_if { File.exist?("#{home}/.atom/packages/language-chef/README.md") }
end
