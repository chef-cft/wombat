home = Dir.home

%W(
  #{home}/.chef
  #{home}/.chef/trusted_certs
  #{home}/.ssh
).each do |directory|
  directory directory
end

template "#{home}/.ssh/config" do
  source 'ssh_config.erb'
  variables(
    home: home,
    org: node['demo']['org']
  )
end

%w(chef-server delivery compliance).each do |f|
  file "#{home}/.chef/trusted_certs/#{f}_#{node['demo']['domain'].tr('.','_')}.crt" do
    content  lazy { IO.read("C:/Windows/Temp/#{f}.crt") }
    action :create
  end

  powershell_script 'Install certs to Root CA' do
    code <<-EOH
      Import-Certificate -FilePath C:/Windows/Temp/#{f}.crt -CertStoreLocation Cert:/LocalMachine/Root
    EOH
  end
end

%W(#{home}/.chef/private.pem #{home}/.ssh/id_rsa).each do |path|
  file path do
    content lazy { IO.read("C:/Windows/Temp/private.pem") }
    action :create
  end
end
