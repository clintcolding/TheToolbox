<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
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
function Test-Service
{
    [CmdletBinding()]

    Param
    (

    [Parameter(Mandatory=$true)]
    [String[]]$ComputerName,

    [Parameter(Mandatory=$true)]
    [String[]]$Service

    )

    Begin
    {
    }
    Process
    {
        Write-Verbose "Testing $Service service status."
            
            foreach ($Server in $ComputerName) {
    
                $Status = Get-Service -ComputerName $Server -Name $Service

                if ($Status.Status -eq 'Running') {

                    Write-Verbose "$Service service is running on $Server" }

                if ($Status.Status -eq 'Stopped') {

                    Write-Warning "$Service service is stopped on $Server. Starting service..."
                    
                    Invoke-Command -ComputerName $Server -ScriptBlock {param($svc) Start-Service $svc} -ArgumentList $Service
                    
                    $Status = Get-Service -ComputerName $Server -Name $Service

                    if ($Status.Status -eq 'Running') {

                    Write-Verbose "$Service service is running on $Server" }

                }
        }
    }
    End
    {
    }
}