<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Test-ADComputer
{
    [CmdletBinding()]

    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Filter,

        $ComputerName
    )

    Begin
    {
        $Computers = Get-ADComputer -Filter *
    }
    Process
    {
        foreach ($Computer in $Computers) {
            $Test = Test-Connection -ComputerName $Computer.Name -Count 2 -Quiet
    
            if ($Test -eq $false){
                $Prop = [ordered] @{
                    'ComputerName' = $Computer.Name
                    'Status'       = "Offline"
                }
            }

            if ($Test -eq $true){
                $Prop = [ordered] @{
                    'ComputerName' = $Computer.Name
                    'Status'       = "Online"
                }
            }

        $Obj = New-Object -TypeName PSObject -Property $Prop

            Write-Output $Obj
        }
    }
    End
    {
    }
}