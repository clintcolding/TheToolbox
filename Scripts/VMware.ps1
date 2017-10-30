### Find VMs that have outdated VM Tools ###

foreach ($vm in Get-VM) {
    if ($vm.PowerState -eq 'PoweredOn'){
        if ($vm.ExtensionData.Guest.ToolsStatus -eq 'toolsOld') {
            $vm.name
        }
    }
}

### Extend VMware VM Hard Disk ###

Get-HardDisk -VM 100WSUS01 | Set-HardDisk -CapacityGB 400 -ResizeGuestPartition