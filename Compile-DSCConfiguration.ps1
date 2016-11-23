<#
.SYNOPSIS
   Compiles your DSC configuration MOFs and copies them to your pull server.
.DESCRIPTION
   Compile-DSCConfig takes your DSC configuration MOF file, 
   renames it using the Configuration ID of the specified server, 
   copies the renamed MOF file to your pull server, 
   and then generates a checksum file.
.EXAMPLE
   Compile-DSCConfig -ComputerName S3 -Source C:\DSC\my.mof -PullServer PullServer

   This example takes my.mof and renames it the Configuration ID of S3. It then copies the MOF file to PullServer and generates a checksum file.
#>
function Compile-DSCConfiguration
{
    [CmdletBinding(SupportsShouldProcess=$true)]

    Param
    (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true, 
                   Position=0)]
        [String]$ComputerName,

        [Parameter(Mandatory=$true)]
        [String]$Source,

        [Parameter(Mandatory=$true)]        
        [String]$PullServer
    )

    Begin
    {
    }
    Process
    {            
        Write-Verbose "Collecting Configuration ID for $ComputerName."
        $GUID = Get-DscLocalConfigurationManager -CimSession $ComputerName | Select-Object -ExpandProperty ConfigurationID

        Write-Verbose "Creating destination for $GUID.mof on $PullServer."
        $Destination = "\\$PullServer\C$\Program Files\WindowsPowerShell\DscService\Configuration\$GUID.mof"

        Write-Verbose "Copying $GUID.mof from $Source to $Destination."
        Copy-Item -Path $Source -Destination $Destination

        Write-Verbose "Generating $GUID.mof.checksum."
        New-DSCChecksum $Destination -Force
        
        dir "\\$PullServer\C$\Program Files\WindowsPowerShell\DscService\Configuration"
    }
    End
    {
    }
}