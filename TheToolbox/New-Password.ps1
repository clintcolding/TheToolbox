<#
.Synopsis
   Creates a random password.
.DESCRIPTION
   Generates a random password using ASCII printable characters.
.EXAMPLE
   PS C:\> New-Password -Length 10

   iEDQ5s}xoJ
#>
function New-Password{

    [CmdletBinding()]
    Param
    (
        [Parameter(Position=0)]
        [int]$Length=20
    )

    Process{
    
        $ascii=$null
    
        for($a=33; $a –le 126; $a++){
            $ascii+=,[char][byte]$a
        }

        for($i=1; $i –le $length; $i++){
            $TempPassword+=($ascii | Get-Random)
        }

        $TempPassword
    }
}