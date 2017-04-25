# Exchange Mailbox Forward #

Set-Mailbox -Identity user -DeliverToMailboxAndForward $true -ForwardingSMTPAddress "user@company.com"
    
Set-Mailbox -Identity user -DeliverToMailboxAndForward $false -ForwardingSmtpAddress $null