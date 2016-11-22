Function New-TempPassword{

    Param(
        [int]$length=20)

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