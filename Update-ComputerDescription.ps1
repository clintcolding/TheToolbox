<#
.Synopsis
   Updates the description of specified remote computers.
.DESCRIPTION
   The Update-ComputerDescription cmdlet updates the description of the specified computers, either one at a time or from CSV.
.EXAMPLE
   PS C:\> Update-ComputerDescription -ComputerName localhost -Description Test
   This example updates the description of the local computer to Test.
.EXAMPLE
   Update-ComputerDescription -Path C:\updatedesc.csv
   This example utilizes a CSV file to update the specified computers and descriptions.

   CSV file format should appear as:

   computername,description
   mypc,mydescription
#>
function Update-ComputerDescription
{
    [CmdletBinding(DefaultParameterSetName='singlePC',
                  SupportsShouldProcess=$true)]
    Param
    (
        # Computer whose description you wish to update.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   Position=0,
                   HelpMessage='Computer you wish to update description on.',
                   ParameterSetName='singlePC')]
        [ValidateNotNull()]
        [String]$ComputerName,

        # Desired computer description. 
        [Parameter(Mandatory=$true,
                   Position=1,
                   HelpMessage='Desired computer description.',
                   ParameterSetName='singlePC')]
        [ValidateNotNull()]
        [string]$Description,

        # Optional path to CSV file containing specified ComputerName,Description.
        [Parameter(Mandatory=$true,
                   ParameterSetName='fromCSV')]
        [ValidateNotNull()]
        [string]$Path
    )

    Begin
    {
    }
    Process
    {  
        try{
            if($Path){
                $Data = Import-Csv $Path

                foreach($Entry in $Data){
                $ComputerName = $($Entry.computername)
                $Description = $($Entry.description)
        
                Update-ComputerDescription -ComputerName $ComputerName -Description $Description
                }
            }
            else{
                $OSObj = Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName -ErrorAction Stop
                $OSObj.Description = $Description
                $OSObj.put() | Out-Null
        
                Write-Host "Description of $ComputerName updated to $Description"
            }
        }

        catch [System.Runtime.InteropServices.COMException]{
                Write-Error "Could not connect to $ComputerName."
        }

        catch {}
    }
    End
    {
    }
}