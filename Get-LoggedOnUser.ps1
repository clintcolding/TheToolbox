<#
.Synopsis
   Returns the logged on user account.
.DESCRIPTION
   Returns the logged on user account.
.EXAMPLE
   PS C:\> Get-LoggedOnUser localhost

   ComputerName LoggedOnUser
   ------------ ------------
   localhost    ccolding 
.EXAMPLE
   PS C:\> Get-ADComputer -Filter 'OperatingSystem -like "*server*"' | Get-LoggedOnUser

   ComputerName LoggedOnUser
   ------------ ------------
   DC01         ccolding         
   TS01         ccolding
#>
function Get-LoggedOnUser
{
    [CmdletBinding()]

    Param
    (
        [Alias("ComputerName")]
        [Parameter(ValueFromPipelineByPropertyName=$true,  
                   Position=0)]
        [string[]]$Name = 'localhost'
    )

    Begin
    {
    }
    Process
    {
        foreach($Computer in $Name){

            if ( (Test-Connection $Computer -Count 2 -Quiet) -eq 'True' ) {
        
                $LoggedOnUser = Get-WMIObject -ComputerName $Computer -Class Win32_ComputerSystem | Select-Object Username

                $Prop = [ordered] @{
                    'ComputerName' = $Computer
                    'LoggedOnUser' = $LoggedOnUser.Username
                }
        
                $Obj = New-Object -TypeName PSObject -Property $Prop

                Write-Output $Obj
            }
        }
    }
    End
    {
    }
}