<#
.Synopsis
   Removes automapped Exchange 2013 mailboxes from Outlook.
.DESCRIPTION
   Removes automapped Exchange 2013 mailboxes from Outlook while preserving the underlying access rights.
.EXAMPLE
   Remove-AutoMapping -Identity scollins -User ccolding

   Removes the automapped mailbox of scollins for ccolding.
.PARAMETER Identity
   The automapped mailbox you're removing.
.PARAMETER User
   The user you're removing the automapped mailbox from.
#>
function Remove-AutoMapping
{
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string[]]$Identity,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]$User
    )

    Begin
    {
    }
    Process
    {
        foreach($Mailbox in $Identity){

            $AccessRights = Get-MailboxPermission -Identity $Mailbox | where {$_.User -like "*$User*" -and $_.IsInherited -like "False" -and $_.Deny -like "False"}
            
                if($AccessRights -ne $null){

                    Add-MailboxPermission -Identity $Mailbox -User $User -AccessRights $AccessRights.AccessRights -AutoMapping $false

                }

                else{
                    
                    Add-MailboxPermission -Identity $Mailbox -User $User -AccessRights ReadPermission -AutoMapping $false

                    Remove-MailboxPermission -Identity $Mailbox -User $User -AccessRights ReadPermission -Confirm:$false
                
                }
        }
    }
    End
    {
    }
}