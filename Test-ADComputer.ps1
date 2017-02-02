<#
.Synopsis
   Returns online/offline status of AD computers.
.DESCRIPTION
   Returns online/offline status of AD computers based on Test-Connection results.
.EXAMPLE
   PS C:\> Test-ADComputer -Filter *

   ComputerName Status
   ------------ ------
   DC01         Online
   DEV01        Online
   DEV02        Online

   Returns the status of all AD computers.
.EXAMPLE
   PS C:\> Test-ADComputer -Filter * | where {$_.status -eq 'Offline'}

   ComputerName Status
   ------------ ------
   DC02         Offline
   DEV03        Offline
   DEV04        Offline

   Only returns AD computers with the status of Offline.
#>
function Test-ADComputer
{
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory=$true)]
        $Filter
    )

    Begin
    {
        $Computers = Get-ADComputer -Filter $Filter
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