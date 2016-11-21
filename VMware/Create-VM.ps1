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
function Create-VM
{
    [CmdletBinding(DefaultParameterSetName='ManualConfig')]

    Param
    (
        # Configuration file location.
        [Parameter(ParameterSetName='AutoConfig',
                   Mandatory=$true)]
        [string]$ConfigFile,
         
        # Desired VM name.
        [Parameter(ParameterSetName='ManualConfig')]
        [string]$VMName=(Read-Host -Prompt "Desired VM name?"),

        # Desired VM Host placement.
        [Parameter(HelpMessage="150ESX01, 100ESX02, 100ESX03")]
        [ValidateSet('150ESX01','100ESX02','100ESX03')]
        [string]$VMHost=(Read-Host -Prompt "Desired VM host placement?"),
        
        # Desired datastore placement.
        [ValidateSet('Operations','Database','File','Application','E1VD1','DR')]
        [string]$Datastore=(Read-Host -Prompt "Desired datastore?"),
                
        # Size of virtual disk in GB.
        [int]$DiskGB=(Read-Host -Prompt "Disk size in GB?"),
                
        # Virtual disk format.
        [ValidateSet('EagerZeroedThick','Thick','Thin','Thick2GB','Thin2GB')]
        [string]$DiskFormat=(Read-Host -Prompt "Desired disk format?"),
                
        # SCSI Controller type.
        [ValidateSet('ParaVirtual','VirtualBusLogic','VirtualLsiLogic','VirtualLsiLogicSAS')]
        [string]$SCSIType=(Read-Host -Prompt "SCSI controller type?"),
                
        # Number of virtual CPUs.
        [int]$NumCPU=(Read-Host -Prompt "Number of virtual CPUs?"),
                
        # Amount of virtual memory.
        [int]$MemGB=(Read-Host -Prompt "Virtual memory in GB?"),
                
        # Desired folder location.
        [ValidateSet('Tampa VMs','Lakeland VMs')]
        [string]$Location=(Read-Host -Prompt "Desired folder location?"),
                
        # Connected network.
        [ValidateSet('VM Network','DMZ')]
        [string]$Network=(Read-Host -Prompt "Desired virtual network?"),
                        
        # Network adapter type.
        [ValidateSet('e1000','e1000e','EnhancedVmxnet','Flexible','Vmxnet','Vmxnet3')]
        [string]$NetAdapterType=(Read-Host -Prompt "Network adapter type?"),
                
        # Path to ISO image for CDROM.
        [string]$ISOPath=(Read-Host -Prompt "Attached ISO path?"),
                
        # Path to Floppy image.
        [string]$FloppyPath=(Read-Host -Prompt "Attached floppy name?"),
                
        # VIServer.
        [Parameter(ParameterSetName='AutoConfig',
                   Mandatory=$true)]
        [string]$VIServer=(Read-Host -Prompt "vCenter server?"),

        # Number of VMs to create.
        [int]$VMCount=1
    )

    Begin
    {
        Add-PSSnapin VMware.VimAutomation.Core
        Write-Verbose "Connecting to $VIServer..."
        Connect-VIServer $VIServer | Out-Null
    }
    Process
    {       
            if ($ConfigFile){
         
                $ConfigData=Get-Content $ConfigFile
                $Config=@{}

                for($i=1; $i -le $vmcount; $i++){

                    foreach($Entry in $ConfigData){
                        $Config.set_item($Entry.substring(0,$Entry.indexof("=")), $Entry.substring($Entry.indexof("=")+1))
                        $Object = New-Object PSObject -Property $Config

                        if($vmcount -gt 1){
                        $Object.vmname += $i.ToString("00")
                        }
                    }

                    $VerboseVM=$Object.VMName

                    Write-Verbose "Creating VM $VerboseVM..."
                    New-VM -Name $Object.VMName -VMHost $Object.VMHost -Datastore $Object.Datastore -DiskGB $Object.DiskGB -DiskStorageFormat $Object.DiskFormat -Location $Object.Location -MemoryGB $Object.MemGB -NumCpu $Object.NumCPU -NetworkName $Object.Network | Out-Null

                    if($Object.SCSIType){
                        Write-Verbose "Setting SCSI Controller on $VerboseVM..."
                        Get-ScsiController -VM $Object.VMName | Set-ScsiController -Type $Object.SCSIType -WarningAction SilentlyContinue | Out-Null 
                    }

                    if($Object.NetAdapterType){
                        Write-Verbose "Setting Network Adapter on $VerboseVM..."
                        Get-NetworkAdapter -VM $Object.VMName | Set-NetworkAdapter -Type $Object.NetAdapterType -Confirm:$false -WarningAction SilentlyContinue | Out-Null
                    }
        
                    if($Object.ISOPath){
                        Write-Verbose "Mounting CD Image on $VerboseVM..."
                        New-CDDrive -VM $Object.VMName -IsoPath $Object.ISOPath -StartConnected -WarningAction SilentlyContinue | Out-Null
                    }
        
                    if($Object.FloppyPath){
                        Write-Verbose "Mounting Floppy Image on $VerboseVM..."
                        New-FloppyDrive -VM $Object.VMName -FloppyImagePath $Object.FloppyPath -StartConnected -WarningAction SilentlyContinue | Out-Null
                    }
                }
                
            }

            else{
                
                New-VM -Name $VMName -VMHost $VMHost -Datastore $Datastore -DiskGB $DiskGB -DiskStorageFormat $DiskFormat -Location $Location -MemoryGB $MemGB -NumCpu $NumCPU -NetworkName $Network | Out-Null

                if($SCSIType){
                    Write-Verbose "Setting SCSI Controller on $VMName..."
                    Get-ScsiController -VM $VMName | Set-ScsiController -Type $SCSIType -WarningAction SilentlyContinue | Out-Null 
                }

                if($NetAdapterType){
                    Write-Verbose "Setting Network Adapter on $VMName..."
                    Get-NetworkAdapter -VM $VMName | Set-NetworkAdapter -Type $NetAdapterType -Confirm:$false -WarningAction SilentlyContinue | Out-Null
                }
        
                if($ISOPath){
                    Write-Verbose "Mounting CD Image on $VMName..."
                    New-CDDrive -VM $VMName -IsoPath $ISOPath -StartConnected -WarningAction SilentlyContinue | Out-Null
                }
        
                if($FloppyPath){
                    Write-Verbose "Mounting Floppy Image on $VMName..."
                    New-FloppyDrive -VM $VMName -FloppyImagePath $FloppyPath -StartConnected -WarningAction SilentlyContinue | Out-Null
                }
            }
    }
    End
    {
    }
}