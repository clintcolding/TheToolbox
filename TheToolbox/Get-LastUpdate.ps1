<#
.Synopsis
   Gets the last update installed on a computer.
.DESCRIPTION
   Returns the last time a computer was patched. Includes ComputerName, Description, HotFixID and InstalledOn data.
.EXAMPLE
   Get-LastUpdate

   ComputerName Description HotFixID  InstalledOn
   ------------ ----------- --------  -----------
   localhost    Update      KB2693643 4/27/2016

   Gets the last update from localhost.
.EXAMPLE
   Get-LastUpdate -ComputerName (gc C:\bin\serverlist.txt)

   Gets last update from a list of computers.
#>
function Get-LastUpdate
{
    [CmdletBinding(DefaultParameterSetName='None',
                   SupportsShouldProcess=$true)]
    Param
    (
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,  
                   Position=0)]
        [string[]]$ComputerName='localhost'
    )

    Begin
    {
    }
    Process
    {
       foreach($Computer in $ComputerName){
            
            Try{
                $hotfix=Get-HotFix -ComputerName $Computer | Sort-Object InstalledOn -Descending -ErrorAction Stop | Select-Object -First 1
                
                foreach($update in $hotfix){
                    $Prop=[ordered]@{
                                'ComputerName'=$Computer
                                'Description'=$hotfix.description
                                'HotFixID'=$hotfix.hotfixid
                                'InstalledOn'=($hotfix.installedon).ToString("d")
                    }
      
                         $Obj=New-Object -TypeName PSObject -Property $Prop
                     
                         Write-Output $Obj
                 }
            }
            Catch{
                Write-Warning "Unable to find updates on $Computer."
            }
       }
    }
    End
    {
    }
}