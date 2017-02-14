<#
.Synopsis
   Updates the UserPrincipleName for a selection of AD users.
.DESCRIPTION
   Updates the UserPrincipleName for a selection of AD users.
.EXAMPLE
   PS C:\> Update-UPN -SearchBase "DC=Contoso, DC=local" -UPN contoso.com
   ccolding@contoso.com

   Updates AD user ccolding's UPN to ccolding@contoso.com

.PARAMETER UPN
   Specifies the UserPrincipleName you wish to set for the selected users.
.PARAMETER FILTER
   Specifies a query string that retrieves Active Directory objects.
.PARAMETER SEARCHBASE
   Specifies an Active Directory path to search under. 
#>
function Update-UPN
{
    [CmdletBinding(SupportsShouldProcess=$true)]

    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$UPN,

        [string]$Filter = "*",

        [string]$SearchBase
    )

    Begin
    {
    }
    Process
    {
        if($SearchBase){
        
            $Users = Get-ADUser -Filter $Filter -SearchBase $SearchBase

                Foreach($User in $Users){

                    $NewUPN = $User.SamAccountName + "@" + $UPN

                    $User | Set-ADUser -UserPrincipalName $NewUPN

                    $User.UserPrincipalName

                }
        
        }

        else{

            $Users = Get-ADUser -Filter $Filter

                Foreach($User in $Users){

                    $NewUPN = $User.SamAccountName + "@" + $UPN

                    $User | Set-ADUser -UserPrincipalName $NewUPN

                    $User.UserPrincipalName

                }

        }
    }
    End
    {
    }
}