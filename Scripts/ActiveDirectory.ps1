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

### Get AD Users Created 2017 ###

$users = Get-ADUser -Filter * -SearchBase "OU=Tampa Users,OU=Tampa,OU=Sites,DC=A1,DC=local" -Properties whenCreated

foreach ($user in $users) {
    if ($user.whenCreated -ge "1/1/2017" -and $user.whenCreated -le "12/31/2017") {

        $Prop = [ordered] @{
            'User' = $user.Name
            'CreatedOn' = $user.whenCreated
        }

        $Obj = New-Object -TypeName PSObject -Property $Prop

        Write-Output $Obj
    } 
}