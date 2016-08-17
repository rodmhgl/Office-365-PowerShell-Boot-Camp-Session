# Domain NetBIOS name
$Domain = "poshdev" 
# Name for our share
$ShareName = "HomeDrives$"
# This group will be granted Full Access to the share
$ShareGroup = "$Domain\Domain Users"
# Description for our share
$ShareDescription = "User Home Drives"
# NTFS Path to our share
$SharePath = "C:\ShareFolder"
# OU to start our user search
$SearchBase = "OU=CreatedUsers,DC=poshdev,DC=local"
# UNC path to our user shares
$Server = "\\poshdevdc\$ShareName"

# If the share does not exist, we will need to create it
If (-Not (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue)) {
    Write-Warning "Share Not Found, Will Have to Create Share"
    # Before we can create the share, we need to verify that the folder exists
    If (Test-Path -Path $SharePath) {
        Write-Verbose "Path Found, Creating Share"
        # The folder exists, let's create the share
        New-SmbShare -Name $ShareName -FullAccess $ShareGroup -Description $ShareDescription -Path $SharePath | out-null 
    } else { 
        Write-Warning "Path Not Found, Creating Path"
        # The folder did not exist, let's create it
        New-Item -Path $SharePath -ItemType Directory | out-null 
        Write-Verbose "Path Created, Creating Share"
        # Now we can create the share
        New-SmbShare -Name $ShareName -FullAccess $ShareGroup -Description $ShareDescription -Path $SharePath | out-null 
    }
} else {
    # Share already exists - we'll assume the path does
    # This is bad practice, for production we would want to verify that 
    # the share exists _and_ points to the correct path
    Write-Verbose "Path and Share Already Exist"
}

# Let's connect to AD and store the SAMAccountName of users who do not have a populated homedirectory in $UserList
# Note that Get-ADUser doesn't return the HomeDirectory attribute by default, we have to specify it in -Properties
$UserList = Get-ADUser -SearchBase $SearchBase -filter {Enabled -eq $true} -Properties HomeDirectory | 
            Where {$_.HomeDirectory -eq $null} | 
            ForEach-Object {$_.SamAccountName}

# If our userlist isn't empty
if ($Userlist -ne $null) {
    ForEach ($User in $UserList) {
        # Set our home folder path
        $HomeFolderPath = "$Server\$User"
        # Create home folder for user
        if (-Not (Test-Path $HomeFolderPath)) {
            New-Item -Path $HomeFolderPath -itemtype Directory -force | Out-Null
            Write-Verbose  "Created: $Server\$User"
        }
        # Create an ACE to apply to the folder ACL
        $Acl = Get-Acl -Path $HomeFolderPath
        $Ace = New-Object System.Security.AccessControl.FileSystemAccessRule("$Domain\$User", "Modify, ChangePermissions", "ContainerInherit,ObjectInherit", "None", "Allow")
        $Acl.AddAccessRule($Ace)
        # Apply the ACL we created
        Set-Acl -Path $HomeFolderPath -AclObject $Acl

        # Connect home folder in AD as disk H:
        Set-ADUser -Identity $User -HomeDrive "H:" -HomeDirectory $HomeFolderPath
        Write-Verbose "Set home drive for user: $User"
    }
} else { Write-Verbose "All homedrives are present." }