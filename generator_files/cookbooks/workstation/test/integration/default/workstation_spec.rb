# workstation tests

describe file('C:\Users\vagrant\.ssh\id_rsa.pub') do
  its('content') { file("/tmp/public.pub").content }
end

describe command('choco list -l cmder') do
  its(:stdout) { should match(/[1-2] packages installed\./) }
end

describe command('choco list -l googlechrome') do
  its(:stdout) { should match(/1 packages installed\./) }
end

describe command('choco list -l atom') do
  its(:stdout) { should match(/1 packages installed\./) }
end

describe command('choco list -l git.install') do
  its(:stdout) { should match(/1 packages installed\./) }
end

describe command('choco list -l gitextensions') do
  its(:stdout) { should match(/1 packages installed\./) }
end

describe command('choco list -l git-credential-manager-for-windows') do
  its(:stdout) { should match(/1 packages installed\./) }
end

describe command('Get-Module -ListAvailable -Name posh-git') do
  its(:stdout) { should match(/Script     0.7.1.0    posh-git/) }
end

describe file('C:\Users\Administrator\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1') do
  its('content') { should match(/Import-Module posh-git/) }
end
