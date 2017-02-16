<#
.Synopsis
   Extracts images from a Word document.
.DESCRIPTION
   Extracts all images from a .docx Word document and saves them in the root folder.
.EXAMPLE
   PS C:\> Extract-Image C:\Users\ccolding\Desktop\MyNewFolder\MyDoc.docx
#>
function Extract-Image
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
        $Dir      = dir $Path
        $FileName = $Path.Substring($Path.LastIndexOf("\") +1)
        $Name     = $Filename.Substring(0,$FileName.IndexOf("."))
    }
    Process
    {
        Set-Location $Dir.directory
        New-Item -ItemType Directory -Name ExtractImage | Out-Null
        Copy-Item -Path $Path -Destination .\ExtractImage
        Rename-Item .\ExtractImage\$FileName Copy.zip
        Expand-Archive .\ExtractImage\Copy.zip -DestinationPath .\ExtractImage

        $Images = Get-ChildItem .\ExtractImage\word\media

            foreach ($Image in $Images) {
            
                $NewName = ($Image.Name).Replace("image","$Name")
                Copy-Item $Image.fullname .\
                Rename-Item $Image $NewName
            
                }

        Remove-Item .\ExtractImage -Recurse -Force
    }
    End
    {
    }
}