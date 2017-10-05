#
# Script to set environment variables for the SPN
# This is used by the `kitchen-azurerm` driver to allow access to Azure for
# running Test Kitchen tests
#
# The values that need to be written are passed as arguments to the script
# The script then makes these permenant machine level environment variables
#
# The permenant env vars set are
# - AZURE_CLIENT_ID
# - AZURE_CLIENT_SECRET
# - AZURE_TENANT_ID
#
# NOTE: The environment variables will not be created if the necessary value has not been
#       set as a packer environment variable when this script runs

# Create a hashtable of the environment variables to create, and the name of the vars
# that have been passed to the script

param (
    [string]
    # clientid for azure
    $clientid = [String]::Empty,

    [string]
    # secret associate with the specified client id
    $clientsecret = [String]::Empty,

    [string]
    # tenantid to be used
    $tenantid = [String]::Empty,

    [string]
    # name of hte event log source to create
    $evtsrc = "PackerBuild",

    [switch]
    # do not set the environment variables
    $noset
)

# Create a hash table of the environment variables and the associate variable in the script
$vars = @{
    "AZURE_CLIENT_ID" = "clientid"
    "AZURE_CLIENT_SECRET" = "clientsecret"
    "AZURE_TENANT_ID" = "tenantid"
}

# Determine if running as an admin user
$IsAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")

# Create the event log source so that items can be logged against it
if ($IsAdmin) {
    New-EventLog -Source $evtsrc -LogName Application
}

# Iterate around the vars
$loop = 1
foreach ($name in $vars.keys) {
    
    # Get the value of the associate variable passed to the function
    $value = Get-Variable -Name $vars.$name -ValueOnly

    # if the value is null write to the event log, if not set the env var
    if ([String]::IsNullOrWhiteSpace($value)) {

        # Determine the message that needs to be output
        $msg = "Unable to set {0} environment variable as the supplied value is null" -f $name

        if ($IsAdmin) {
            Write-EventLog -LogName Application `
                        -Source $evtsrc `
                        -EntryType Information `
                        -EventId (1000 + $loop) `
                        -Message $msg
        } else {
            Write-Output $msg
        }
    } else {
        if (!$noset) {
            [Environment]::SetEnvironmentVariable($name, $value, "Machine")
        } else {
            Write-Output ("Environment variable '{0}' would be set to: {1}" -f $name, $value)
        }
    }

    $loop += 1
}
