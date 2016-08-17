# Retrieve all users from AD, Filtered with Where-Object, Delete disabled users
Get-ADUser -Filter * | where-object {$_.enabled -eq $false}  | Remove-ADUser -WhatIf

# Or use the filter parameter of Get-ADUser to filter objects instead of where-object
Get-ADUser -Filter {Enabled -eq $false} | Remove-ADUser -WhatIf