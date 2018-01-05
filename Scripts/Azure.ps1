### Connect to Office 365

$UserCredential = Get-Credential
Connect-AzureAD -Credential $UserCredential
