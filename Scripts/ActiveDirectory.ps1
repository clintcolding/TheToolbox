### Get AD User Group Membership ###

$user = 'ccolding'

Get-ADPrincipalGroupMembership $user | Select-Object -Property Name, GroupScope, GroupCategory | Sort-Object -Property Name | Format-Table -A

### Exchange Mailbox Forward ###

Set-Mailbox -Identity user -DeliverToMailboxAndForward $true -ForwardingSMTPAddress "user@company.com"

Set-Mailbox -Identity user -DeliverToMailboxAndForward $false -ForwardingSmtpAddress $null