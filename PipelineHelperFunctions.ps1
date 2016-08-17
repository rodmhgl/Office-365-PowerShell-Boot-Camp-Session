Function Get-InputType { 
    [cmdletbinding()]
    param([string]$command)
    try { Get-Help $command | select-object -ExpandProperty inputtypes }
    catch { Write-Error -Exception $_.exception } 
}

Function Search-ReturnValue { 
    [cmdletbinding()]
    param([string]$ReturnValue)
    try { Get-Help * | Where-Object { $_.returnvalues.returnvalue.type.name -eq $ReturnValue } }
    catch [System.NullReferenceException] { } 
    catch { Write-Error -Exception $_.exception } 
}

Get-InputType Stop-service
Search-ReturnValue -ReturnValue "System.ServiceProcess.ServiceController"

Get-InputType Remove-ADGroup
Search-ReturnValue -ReturnValue "Microsoft.ActiveDirectory.Management.ADGroup"