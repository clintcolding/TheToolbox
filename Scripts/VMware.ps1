### Find VMs that have outdated VM Tools ###

foreach ($vm in Get-VM) {
    if ($vm.PowerState -eq 'PoweredOn'){
        if ($vm.ExtensionData.Guest.ToolsStatus -eq 'toolsOld') {
            $vm.name
        }
    }
}

### Extend VMware VM Hard Disk ###

Get-HardDisk -VM 100MAIL01 | Select-Object CapacityGB,Name

Get-HardDisk -VM 100MAIL01 -Name "Hard disk 1" | Set-HardDisk -CapacityGB 300 -ResizeGuestPartition

### Install VMTools on Windows Core ###

cd d:\
.\setup64.exe /S /v "/qn REBOOT=Y"

### Compare VM Guest OS to Installed OS ###

$ComputerName = "100mail01"

$vmdetails = (Get-VM -Name $ComputerName).ExtensionData.Config.GuestID

$osdetails = Get-WmiObject -ComputerName $ComputerName -Class win32_operatingsystem | select Caption,OSArchitecture

if ($osdetails.Caption -like "*2008*" -and $osdetails.OSArchitecture -eq "64-bit") {
    if ($vmdetails -eq "windows7Server64Guest") {
        Write-Host "VM Guest OS is correctly configured."
    }
}

if ($osdetails.Caption -like "*2012*" -and $osdetails.OSArchitecture -eq "64-bit") {
    if ($vmdetails -eq "windows8Server64Guest") {
        Write-Host "VM Guest OS is correctly configured."
    }
}