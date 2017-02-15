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
function Extract-Images
{
    [CmdletBinding()]

    Param
    (
        # Path to Word document
        [Parameter(Mandatory=$true,
                   Position=0)]
        $Path
    )

    Begin
    {
        $Dir = dir $Path

        $FileName = $Path.Substring($Path.LastIndexOf("\") +1)
    }
    Process
    {
        Set-Location $Dir.directory

        New-Item -ItemType Directory -Name ExtractImage

        Copy-Item -Path $Path -Destination .\ExtractImage

        Rename-Item .\ExtractImage\$FileName Copy.zip

        Expand-Archive .\ExtractImage\Copy.zip -DestinationPath .\ExtractImage

        $Images = Get-ChildItem .\ExtractImage\word\media

        foreach ($Image in $Images) {
            Copy-Item $Image.fullname .\}

        Remove-Item .\ExtractImage -Recurse -Force
    }
    End
    {
    }
}