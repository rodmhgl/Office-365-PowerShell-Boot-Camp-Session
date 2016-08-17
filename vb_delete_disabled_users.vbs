On Error Resume Next

Const ADS_UF_ACCOUNTDISABLE = 2
 
Set objConnection = CreateObject("ADODB.Connection")
Set oRootDSE = GetObject("LDAP://rootDSE")
strDomain = oRootDSE.Get("DefaultNamingContext")
objConnection.Open "Provider=ADsDSOObject;"
Set objCommand = CreateObject("ADODB.Command")
objCommand.ActiveConnection = objConnection
objCommand.CommandText = _
    "<LDAP://" & strDomain & ">;(objectCategory=User)" & _
        ";userAccountControl,distinguishedName,cn;subtree"  
Set objRecordSet = objCommand.Execute
 
intCounter = 0
Do Until objRecordset.EOF
    intUAC=objRecordset.Fields("userAccountControl")
    If intUAC AND ADS_UF_ACCOUNTDISABLE Then
        'Delete the account
        'First check if this is a built-in account and skip if it is
        Select Case objRecordset.Fields("cn")
        'Add any other accoutns you don't want deleted to the list below
        'Seperate by commas.
        Case "krbtgt","Guest","SUPPORT_388945a0"
            'Do Nothing
        Case Else
            userDN = objRecordset.Fields("distinguishedName")
            userCN = "cn=" & Trim(objRecordset.Fields("cn"))
            strOU = Mid(userDN,InStr(1,userDN,",")+1,Len(userDN))
            Set objOU = GetObject("LDAP://" & strOU)
            If Err.Number <> 0 Then
                WScript.Echo Err.Number,Err.Description
                Err.Clear
            End If
            
            objOU.Delete "user", userCN
            If Err.Number <> 0 Then
                WScript.Echo userCN,Err.Number,Err.Description
                Err.Clear
            End If
            intCounter = intCounter + 1
        End Select
    End If
    objRecordset.MoveNext
Loop
 
WScript.Echo VbCrLf & "A total of " & intCounter & " accounts were deleted."
 
objConnection.Close