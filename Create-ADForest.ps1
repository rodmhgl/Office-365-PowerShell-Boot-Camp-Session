# Import required module 
Import-Module ServerManager
# Verify AD-Domain-Services is not currently installed
Get-WindowsFeature | Where-Object Installed

# Install the required features to create a new forest, along with their management tools
Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools

# Install a new active directory forest configuration
Install-ADDSForest -DomainName 'poshdev.local' -SkipPreChecks -InstallDns -NoRebootOnCompletion

# Restart computer to complete installation
Restart-Computer