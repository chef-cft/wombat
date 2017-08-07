# workstation tests

control 'wombat-listenports' do
  title 'RDP is listening on port 3389'
  describe port(3389) do
    it { should be_listening }
    its('processes') { should include 'TermService' }
  end
end

home = 'C:\\Users\\Default'

control 'wombat-configs' do
  title 'Required configs are in place'
  describe file("#{home}\\.ssh\\id_rsa.pub") do
    its('content') { file('/tmp/public.pub').content }
  end
  describe file("#{home}\\.chef\\knife.rb") do
    it { should be_file }
  end
  describe file("#{home}\\.chef\\private.pem") do
    its('content') { file('/tmp/private.pem').content }
  end
  describe file("#{home}\\.chef\\config.d\\data_collector.rb") do
    its('content') { should match('93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506') }
  end
end

control 'wombat-packages' do
  title 'Required packages are installed'
  describe command('choco list cmder --exact --local-only --limit-output') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match('cmder|') }
  end
  describe command('choco list googlechrome --exact --local-only --limit-output') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match('googlechrome|') }
  end
  describe command('choco list atom --exact --local-only --limit-output') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match('atom|') }
  end
  describe command('choco list git.install --exact --local-only --limit-output') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match('git.install|') }
  end
  describe command('choco list gitextensions --exact --local-only --limit-output') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match('gitextensions|') }
  end
  describe command('choco list  --exact --local-only --limit-output') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match('git-credential-manager-for-windows|') }
  end
  describe command('choco list putty --exact --local-only --limit-output') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match('putty|') }
  end
end

control 'wombat-powershell-modules' do
  title 'Required PowerShell modules are installed'
  describe command('(Get-Module -ListAvailable -Name posh-git).Guid') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match('74c9fd30-734b-4c89-a8ae-7727ad21d1d5') }
  end
  describe command('(Get-Module -ListAvailable -Name PSReadLine).Guid') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match('5714753b-2afd-4492-a5fd-01d9e2cff8b5') }
  end
  describe file('C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1') do
    its('content') { should match('Import-Module posh-git') }
  end
  describe file('C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1') do
    its('content') { should match('Import-Module PSReadLine') }
  end
end
