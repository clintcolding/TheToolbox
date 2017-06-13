<#
.Synopsis
   Tests and corrects the status of a service.
.DESCRIPTION
   Determines if a service is running or stopped. If stopped, Test-Service will attempt to start.
.EXAMPLE
   C:\> Test-Service -ComputerName DC01,DC02,DC03 -Service DNS -Verbose
   VERBOSE: Testing DNS service status.
   VERBOSE: DNS service is running on DC01
   VERBOSE: DNS service is running on DC02
   WARNING: DNS service is stopped on DC03. Starting service...
   VERBOSE: DNS service is running on DC03
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

                        if ($Status.Status -eq 'Stopped') {

                        Write-Verbose "Unable to start $Service on $Server" }

                }
        }
    }
    End
    {
    }
}