# Import ActiveDirectory module required for New-ADUser
Import-Module ActiveDirectory

# Set parameters for RandomUser.Me
# https://randomuser.me/documentation
$Format = "csv"
$Results = "50"
$Nat = "US"
$Exc = "gender,registered,dob,picture,nat"
# This seed can be changed - https://randomuser.me/documentation#seeds
$Seed = "poshdev"

# Using one default password will make it easier to log on as our users
# We use ConvertTo-SecureString to convert the plaintext string and pass it to New-ADUser
# As New-ADUser expects a SecureString type (Get-Help New-ADUser)
$DefaultPassword = ConvertTo-SecureString -String "P@ssw0rd1" -AsPlainText -Force

# The OU to create our new users in
$Path = "ou=CreatedUsers,dc=poshdev,dc=local"

# Create Randomuser.me request using above variables
$RandomUserMe = "https://randomuser.me/api/?format=$Format&results=$Results&nat=$Nat&exc=$Exc&seed=$seed"

# Use Invoke-RestMethod to connect to RandomUser.Me and retrieve CSV
# Store this CSV in the $user object
$User = Invoke-RestMethod -Uri $RandomUserMe | ConvertFrom-Csv

# Foreach line in our $User object
foreach ($u in $User) { 
    # Create a new user
    New-ADUser -Path $Path `
               -AccountPassword $DefaultPassword `
               -GivenName $u.'name.first' `
               -Surname $u.'name.last' `
               -PostalCode $u.'location.postcode' `
               -StreetAddress $u.'location.street' `
               -City  $u.'location.city' `
               -State $u.'location.state' `
               -EmailAddress $u.email `
               -HomePhone $u.phone `
               -MobilePhone  $u.cell `
               -Name $u.'login.username' `
               -EmployeeID $u.'id.value' `
               -Enabled $true `
               -CannotChangePassword $true `
               -PasswordNeverExpires $true 
}