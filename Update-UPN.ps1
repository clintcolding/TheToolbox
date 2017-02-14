<#
.Synopsis
   Updates the UserPrincipleName for a selection of AD users.
.DESCRIPTION
   Updates the UserPrincipleName for a selection of AD users.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
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

                }
        
        }

        else{

            $Users = Get-ADUser -Filter $Filter

                Foreach($User in $Users){

                    $NewUPN = $User.SamAccountName + "@" + $UPN

                    $User | Set-ADUser -UserPrincipalName $NewUPN

                }

        }
    }
    End
    {
    }
}