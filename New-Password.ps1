<#
.Synopsis
   Creates a random password.
.DESCRIPTION
   Generates a random password using ASCII printable characters.
.EXAMPLE
   PS C:\> New-Password -Length 10

   iEDQ5s}xoJ
.EXAMPLE
   PS C:\> New-Password -LettersNumbersOnly

   Z55Yjf1M4rSVNg4OCTaR
#>
function New-Password{

    [CmdletBinding()]
    Param
    (
        [Parameter(Position=0)]
        [int]$Length=20,

        [switch]$LettersNumbersOnly
    )

    Process{
    
        $ascii=$null
    
        if($LettersNumbersOnly){

            for($a=48; $a –le 57; $a++){
                $ascii+=,[char][byte]$a
            }

            for($a=65; $a –le 90; $a++){
                $ascii+=,[char][byte]$a
            }

            for($a=97; $a –le 122; $a++){
                $ascii+=,[char][byte]$a
            }

            for($i=1; $i –le $length; $i++){
                $TempPassword+=($ascii | Get-Random)
            }

            $TempPassword
        
        }

        else{
        
            for($a=33; $a –le 126; $a++){
                $ascii+=,[char][byte]$a
            }

            for($i=1; $i –le $length; $i++){
                $TempPassword+=($ascii | Get-Random)
            }

            $TempPassword

        }
    }
}