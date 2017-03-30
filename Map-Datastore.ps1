<#
.Synopsis
   Maps a VMware datastore to a PSDrive.
.DESCRIPTION
   Maps a VMware datastore to a PSDrive allowing for directory search, file upload/downloads, etc.
.PARAMETER Datastore
   The name of the datastore you wish to map.
.PARAMETER Drive
   The drive name to map the datastore to. Default is ds.
.EXAMPLE
   Map-Datastore -Datastore datastore1

   This example maps datastore1 to ds:\.
.EXAMPLE
   Get-Datastore Application | Map-Datastore -Drive App

   This example maps the Application datastore to App:\.
#>
function Map-Datastore
{
    [CmdletBinding()]
    Param
    (
        # The name of the datastore you wish to map.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        $Datastore,

        # The drive name to map the datastore to.
        [Parameter(Mandatory=$true,
                   Position=1)]
        $Drive = 'ds'
    )

    Begin
    {
    }
    Process
    {
        # Get specified datastore.
        try{
            $DS = Get-Datastore $Datastore}
        catch{
            Write-Warning "Can't find datastore $Datastore."
            break}
        # Create a PSDrive for datastore using specified drive name.
        try{
            New-PSDrive -Location $DS -Name $Drive -PSProvider VimDatastore -root "\" -Scope Global -ErrorAction Stop -ErrorVariable $PSDError}
        catch{
            Write-Error $PSDError
            break}
        # Set the location to newly created PSDrive.
        Set-Location $Drive":\"
    }
    End
    {
    }
}