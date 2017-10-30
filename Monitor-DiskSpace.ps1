$volume = Get-WmiObject -ComputerName 100MAIL01 Win32_Volume

Foreach($drive in $volume){
    If ($drive.drivetype -eq 3 -and $drive.label -ne "System Reserved" -and $drive.label -ne "Recovery"){
        [int]$freepct = ($drive.freespace / $drive.capacity)*100
        write-output $drive.name $freepct
    }
}