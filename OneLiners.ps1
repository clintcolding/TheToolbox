### Exchange Mailbox Forward ###

Set-Mailbox -Identity user -DeliverToMailboxAndForward $true -ForwardingSMTPAddress "user@company.com"
    
Set-Mailbox -Identity user -DeliverToMailboxAndForward $false -ForwardingSmtpAddress $null

### Get Hostname from IP ###

$path = Import-Csv c:\bin\iplist.txt

foreach ($entry in $path) {
    $Hostname = Resolve-DnsName $entry.ip

    $Prop = [ordered] @{
        'Hostname' = $Hostname.NameHost
        'IP'       = $entry.ip
    }
    
    $Obj = New-Object -TypeName PSObject -Property $Prop

    Write-Output $Obj
}

### Extend VMware VM Hard Disk ###

Get-HardDisk -VM 100WSUS01 | Set-HardDisk -CapacityGB 400 -ResizeGuestPartition

### Get AD User Group Membership ###

$user = 'ccolding'

Get-ADPrincipalGroupMembership $user | Select-Object -Property Name, GroupScope, GroupCategory | Sort-Object -Property Name | FT -A