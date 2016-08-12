# How to connect to Office 365

#Import module
Import-Module MSOnline

#Get credentials
$cred = Get-Credential -UserName 'admin@MOD173431.onmicrosoft.com' -Message "Enter Office 365 Admin Credentials"

#Establish connection
Connect-MSOLService -Credential $cred

# Are we connected? Let's try to retrieve some users
Get-MsolUser

# Dealing with Users and Licensing

# See commands dealing with users
Get-Command -Noun *User*

# See commands dealing with only Office 365 Users
Get-Command -Name *User* -Module MSOnline

# See all Office 365 Commands
Get-Command -Module MSOnline

# See commands dealing with Office 365 Groups, Licenses, Subscriptions
Get-Command -Name *Group* -Module MSOnline
Get-Command -Name *License* -Module MSOnline
Get-Command -Name *Subscription* -Module MSOnline
Get-Command -Name *Sku* -Module MSOnline

Get-Help Get-MsolUser 
Get-Help Get-MsolUser -Full
Get-Help Get-MsolUser -Examples
Get-Help Get-MsolUser -ShowWindow

# Departments
# 'Engineering', 'Executive Management', 'Finance', 'Legal', 'Operations', 'Research & Development', 'Sales & Marketing'
Get-MsolUser -Department 'Engineering'
Get-MsolUser -Department 'Operations'
Get-MsolUser -Department 'Finance'
Get-MsolUser -Department 'Legal'

# Cities 
# 'Birmingham', 'San Diego', 'Tulsa', 'Bellevue', 'Bloomington', 'Fort Lauderdale', 'Cairo', 'Charlotte', 'Iselin', 'Louisville', 'Overland Park', 'Pittsburgh', 'Seattle', 'Tokyo', 'Waukesha'
Get-MsolUser -City Birmingham | select userprincipalname, displayname, city
Get-MsolUser -City Tulsa | select userprincipalname, displayname, city
Get-MsolUser -City San Diego | select userprincipalname, displayname, city
Get-MsolUser -City 'San Diego' | select userprincipalname, displayname, city
Get-MsolUser -City $null | select userprincipalname, displayname, city
Get-MsolUser | Where-Object {$_.city -eq $null} | select userprincipalname, displayname, city



# Save Birmingham Users to a file
Get-MsolUser -City Birmingham | gm

Get-MsolUser -City Birmingham | select userprincipalname, displayname, title, city, state, isLicensed > c:\scripts\Birmingham_Users.txt
invoke-item C:\scripts\Birmingham_Users.txt

Get-MsolUser -City Birmingham | select userprincipalname, displayname, title, city, state, isLicensed | Format-Table > c:\scripts\Birmingham_Users.txt
invoke-item C:\scripts\Birmingham_Users.txt

Get-MsolUser -City Birmingham | select userprincipalname, displayname, title, city, state, isLicensed | Export-Csv -LiteralPath c:\scripts\Birmingham_Users.txt
invoke-item C:\scripts\Birmingham_Users.txt

Get-MsolUser -City Birmingham | select userprincipalname, displayname, title, city, state, isLicensed | Export-Csv -LiteralPath c:\scripts\Birmingham_Users.txt -Delimiter "`t"
invoke-item C:\scripts\Birmingham_Users.txt

Get-MsolUser -City Birmingham | select userprincipalname, displayname, title, city, state, isLicensed | Export-Csv -LiteralPath c:\scripts\Birmingham_Users.txt -Delimiter "`t" -NoTypeInformation
invoke-item C:\scripts\Birmingham_Users.txt

# Change User Properties

Get-MsolUser -UserPrincipalName 'KatieJ@MOD173431.onmicrosoft.com' 
Get-MsolUser -UserPrincipalName 'KatieJ@MOD173431.onmicrosoft.com' | Set-MsolUser -DisplayName 'Katie Smith' -LastName 'Smith'
Get-MsolUser -UserPrincipalName 'KatieJ@MOD173431.onmicrosoft.com' 

Set-MsolUser -UserPrincipalName 'KatieJ@MOD173431.onmicrosoft.com' -DisplayName 'Katie Jordan' -LastName 'Jordan'
Get-MsolUser -UserPrincipalName 'KatieJ@MOD173431.onmicrosoft.com'

# View Available License Information
Get-MsolAccountSku
$SKU = Get-MsolAccountSku
$SKU
$SKU.servicestatus

New-MsolUser -UserPrincipalName 'rod.stewart@MOD173431.onmicrosoft.com' `
             -DisplayName 'Rod Stewart' -FirstName 'Rod' -LastName 'Stewart' `
             -LicenseAssignment 'MOD173431:ENTERPRISEPREMIUM' -UsageLocation 'US'
# Remove Licenses
$newLicenseOptions = New-MsolLicenseOptions -AccountSkuId MOD173431:ENTERPRISEPREMIUM -DisabledPlans OFFICESUBSCRIPTION, SHAREPOINTWAC, SHAREPOINTENTERPRISE, MCOEV, MCOMEETADV, MCOSTANDARD, LOCKBOX_ENTERPRISE, EXCHANGE_ANALYTICS, EXCHANGE_S_ENTERPRISE
Set-MsolUserLicense -UserPrincipalName 'rod.stewart@MOD173431.onmicrosoft.com' -LicenseOptions $newLicenseOptions
# Reset Licenses
$newLicenseOptions = New-MsolLicenseOptions -AccountSkuId MOD173431:ENTERPRISEPREMIUM
Set-MsolUserLicense -UserPrincipalName 'rod.stewart@MOD173431.onmicrosoft.com' -LicenseOptions $newLicenseOptions

# Remove All Users
Get-MsolUser -MaxResults | Remove-MsolUser -Force
# That was a bad idea, let's get them back
Get-MsolUser -ReturnDeletedUsers -MaxResults 10000 | Restore-MsolUser

# Birmingham Office Closed, let's permanently remove those employees
Get-MsolUser -City Bellevue | Remove-MsolUser -Force
Get-MsolUser -ReturnDeletedUsers | Remove-MsolUser -RemoveFromRecycleBin -Force

# View Groups
Get-MsolGroup

# View a Group
Get-MsolGroup | where displayname -eq 'Engineering'
Get-MsolGroup | Where-Object {$_.displayname -eq 'Engineering'}
# Search with Wildcard
Get-MsolGroup | Where-Object {$_.displayname -like '*IT*'}

# Create a new group
New-MsolGroup -DisplayName "IT BigWigs" -Description "IT Execs"
# Store the new group in a variable so we can easily access its ObjectID
$Group = Get-MsolGroup -GroupType Security | Where-Object {$_.displayname -eq 'IT BigWigs'}
# Verify the group is empty
Get-MsolGroupMember -GroupObjectId $Group.ObjectID
# Store our member in a variable so we can easily access their ObjectID
$member = Get-MsolUser -UserPrincipalName 'rod.stewart@MOD173431.onmicrosoft.com'
# Add our $member to our $group
Add-MsolGroupMember -GroupObjectId $Group.ObjectID -GroupMemberType User -GroupMemberObjectId $member.objectid
# Verify the addition
Get-MsolGroupMember -GroupObjectId $Group.ObjectID
# Remove group and reset demo
Get-MsolGroup -ObjectId $group.ObjectId | Remove-MsolGroup -Force

# Remove user Rod Stewart and reset demo
Get-MsolUser -UserPrincipalName 'rod.stewart@MOD173431.onmicrosoft.com' | Remove-MsolUser -Force
# Permanently delete user
Get-MsolUser -ReturnDeletedUsers -UserPrincipalName 'rod.stewart@MOD173431.onmicrosoft.com' | 
Remove-MsolUser -Force -RemoveFromRecycleBin

Get-Command *MSol*