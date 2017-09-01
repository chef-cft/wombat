$LaunchConfigFile = "C:\ProgramData\Amazon\EC2-Windows\Launch\Config\LaunchConfig.json"
$UnattendFile = "C:\ProgramData\Amazon\EC2-Windows\Launch\Sysprep\Unattend.xml"

# EC2Launch should not set the `Administrator` user password to a random string
(Get-Content $LaunchConfigFile -Verbose).Replace("Random", "DoNothing") | Set-Content $LaunchConfigFile -Verbose

# Do not utilize the CopyProfile feature of the specialize step
# We do not want the `Administrator` user profile to overwrite the `Default` user profile
(Get-Content $UnattendFile -Verbose).Replace("<CopyProfile>true</CopyProfile>", "<CopyProfile>false</CopyProfile>") | Set-Content $UnattendFile -Verbose
