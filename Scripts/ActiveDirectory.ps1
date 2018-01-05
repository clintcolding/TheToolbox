### Get AD User Group Membership ###

$user = 'ccolding'

$groups = Get-ADPrincipalGroupMembership $user

$groups | Select-Object -Property Name, GroupScope, GroupCategory | Sort-Object -Property Name | Format-Table -A

### Remove all AD Group Membership ###

foreach ($group in $groups) {
    if ($group.name -ne "Domain Users") {
        Remove-ADGroupMember -Identity $group.name -Members $user -Confirm:$false
    }
}

### Exchange Mailbox Forward ###

Set-Mailbox -Identity user -DeliverToMailboxAndForward $true -ForwardingSMTPAddress "user@company.com"

Set-Mailbox -Identity user -DeliverToMailboxAndForward $false -ForwardingSmtpAddress $null