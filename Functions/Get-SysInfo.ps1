function Get-Sysinfo{

    [CmdletBinding()]

    Param(
        

        [Alias("Name")]
        [string[]]$computername
)

    Process{

        foreach($computer in $computername){

            $Asset = Get-WmiObject Win32_BIOS -ComputerName $computer
            $CPU = Get-WmiObject Win32_Processor -ComputerName $computer
            $OS = Get-WmiObject Win32_OperatingSystem -ComputerName $computer
            $System = Get-WmiObject Win32_ComputerSystem -ComputerName $computer

            $x = [ordered]@{

                  'ComputerName' = $OS.PSComputerName
                  'Description'  = $OS.Description
                  'OS'           = $OS.Caption
                  'Asset Tag'    = if($Asset.SerialNumber -like "*VMware*"){'VMware'}
                                   else{$Asset.SerialNumber}
                  'CPU'          = ($CPU.NumberOfCores | Measure-Object -Sum).Sum
                  'Memory'       = [math]::Round($System.TotalPhysicalMemory / 1GB)
                  'Manufacturer' = $System.Manufacturer
                  'Model'        = $System.Model      
      
                  }

            $Obj=New-Object -TypeName PSObject -Property $x
            Write-Output $Obj
        }
    }
}