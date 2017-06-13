<#
.Synopsis
   Tests and corrects the status of a service.
.DESCRIPTION
   Determines if a service is running or stopped. If stopped, Test-Service will attempt to start.
.EXAMPLE
    C:\> Test-Service -ComputerName DC01,DC02,DC03 -Service DNS -Verbose
   VERBOSE: [DC01]    Testing DNS service
   VERBOSE: [DC01]    PASSED
   VERBOSE: [DC02]    Testing DNS service
   VERBOSE: [DC02]    PASSED
   VERBOSE: [DC03]    Testing DNS service
   WARNING: [DC03]    FAILED
   WARNING: [DC03]    Starting DNS service
   VERBOSE: [DC03]    PASSED
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
        
        foreach ($Server in $ComputerName) {
    
            Write-Verbose "[$Server]    Testing $Service service"
                
            $Status = Get-Service -ComputerName $Server -Name $Service

            if ($Status.Status -eq 'Running') {

                Write-Verbose "[$Server]    PASSED" }

            if ($Status.Status -eq 'Stopped') {

                Write-Warning "[$Server]    FAILED"

                Write-Warning "[$Server]    Starting $Service service"
                    
                Invoke-Command -ComputerName $Server -ScriptBlock {param($svc) Start-Service $svc} -ArgumentList $Service
                    
                $Status = Get-Service -ComputerName $Server -Name $Service

                    if ($Status.Status -eq 'Running') {

                    Write-Verbose "[$Server]    PASSED" }

                    if ($Status.Status -eq 'Stopped') {

                    Write-Warning "[$Server]    FAILED" }

            }
        }
    }
    End
    {
    }
}