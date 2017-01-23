<#
.Synopsis
   Gathers system information.
.DESCRIPTION
   Returns local or remote system information. Designed to be used with Get-ADComputer.
.EXAMPLE
   PS C:\Windows\system32> Get-ADComputer -Filter 'OperatingSystem -like "*server*"' | Get-SysInfo | ft

   ComputerName Description     OS                                         Asset Tag CPU Memory Manufacturer Model 
   ------------ -----------     --                                         --------- --- ------ ------------ ----- 
   DC01         Primary DC      Microsoft Windows Server 2008 R2 Standard  VMware      1      4 VMware, Inc. VMw...
   TS01         Terminal Server Microsoft Windows Server 2008 R2 Standard  VMware      2     12 VMware, Inc. VMw...

   Builds server list from AD and then gathers system info.
.EXAMPLE
   PS C:\Windows\system32> Get-SysInfo

   ComputerName : 100IT001
   Description  : Clint Colding
   OS           : Microsoft Windows 10 Pro
   Asset Tag    : H3CXXXX
   CPU          : 2
   Memory       : 8
   Manufacturer : Dell Inc.
   Model        : Latitude E5440

   Gathers localhost system info.
#>
function Get-SysInfo{

    [CmdletBinding()]

    Param(
        
        [Alias("ComputerName")]
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]$Name='localhost'
)

    Process{
        
        try{
            foreach($Computer in $Name){

                $Asset = Get-WmiObject Win32_BIOS -ComputerName $Computer -ErrorAction Stop -ErrorVariable AssetError
                $CPU = Get-WmiObject Win32_Processor -ComputerName $Computer -ErrorAction Stop -ErrorVariable CPUError
                $OS = Get-WmiObject Win32_OperatingSystem -ComputerName $Computer -ErrorAction Stop -ErrorVariable OSError
                $System = Get-WmiObject Win32_ComputerSystem -ComputerName $Computer -ErrorAction Stop -ErrorVariable SysError

                $Prop = [ordered]@{

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

                $Obj = New-Object -TypeName PSObject -Property $Prop

                Write-Output $Obj
            }
        }

        catch [System.Runtime.InteropServices.COMException]{
            Write-Warning "Could not connect to $Computer."    
        }
        
        catch{
            Write-Error $AssetError
            Write-Error $CPUError
            Write-Error $OSError
            Write-Error $SysError
        }
    }
}