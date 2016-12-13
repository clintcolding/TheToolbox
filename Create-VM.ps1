<#
.Synopsis
   Creates a VMware virtual machine based on preset values.
.DESCRIPTION
   Creates a VMware virtual machine based on environmental validated values.
.EXAMPLE
   PS C:\> Create-VM -VMName TESTVM1


   Name               : TESTVM1
   NumCpu             : 1
   MemoryGB           : 2
   VMHost             : 100esx03.a1.local
   Folder             : Tampa VMs
   DiskGB             : 42.209745041094720363616943359
   ScsiControllerType : ParaVirtual
   IsoPath            : [E1VD1] ISOs/WinSvrDataCtr2012.ISO
   FloppyPath         : [] /vmimages/floppies/pvscsi-Windows2008.flp

   
   Creates a VM named TESTVM1 with default values.
#>
function Create-VM
{
    [CmdletBinding()]

    Param
    (
        # Desired VM name.
        [Parameter(Mandatory=$true)]
        [string]$VMName,

        # Desired VM Host placement.
        [ValidateSet('150ESX01.a1.local','100ESX02.a1.local','100ESX03.a1.local')]
        [string]$VMHost='100ESX03.a1.local',
        
        # Desired datastore placement.
        [ValidateSet('Operations','Database','File','Application','E1VD1','DR')]
        [string]$Datastore='E1VD1',
                
        # Size of virtual disk in GB.
        [int]$DiskGB='40',
                
        # Virtual disk format.
        [ValidateSet('EagerZeroedThick','Thick','Thin','Thick2GB','Thin2GB')]
        [string]$DiskFormat='Thin',
                
        # SCSI Controller type.
        [ValidateSet('ParaVirtual','VirtualBusLogic','VirtualLsiLogic','VirtualLsiLogicSAS')]
        [string]$SCSIType='ParaVirtual',
                
        # Number of virtual CPUs.
        [int]$NumCPU=1,
                
        # Amount of virtual memory.
        [int]$MemGB=2,
                
        # Desired folder location.
        [ValidateSet('Tampa VMs','Lakeland VMs')]
        [string]$Location='Tampa VMs',
                
        # Connected network.
        [ValidateSet('VM Network','DMZ')]
        [string]$Network='VM Network',
                        
        # Network adapter type.
        [ValidateSet('e1000','e1000e','EnhancedVmxnet','Flexible','Vmxnet','Vmxnet3')]
        [string]$NetAdapterType='Vmxnet3',
                
        # Path to ISO image for CDROM.
        [string]$ISOPath='[E1VD1] ISOs/WinSvrDataCtr2012.ISO',
                
        # Path to Floppy image.
        [string]$FloppyPath='[] /vmimages/floppies/pvscsi-Windows2008.flp',
                
        # VIServer.
        [string]$VIServer='100VC01'
    )

    Begin
    {
        Add-PSSnapin VMware.VimAutomation.Core
        Write-Verbose "Connecting to $VIServer..."
        Connect-VIServer $VIServer -WarningAction SilentlyContinue | Out-Null
    }
    Process
    {                       
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

        $VMDetails = Get-VM $VMName | Select-Object Name,NumCpu,MemoryGB,VMHost,Folder,ProvisionedSpaceGB
        $SCSIDetails = Get-ScsiController -VM $VMName | Select-Object Type
        $ISODetails = Get-CDDrive -VM $VMName
        $FloppyDetails = Get-FloppyDrive -VM $VMName

        $VM = [ordered] @{
            Name = $VMDetails.Name
            NumCpu = $VMDetails.NumCpu
            MemoryGB = $VMDetails.MemoryGB
            VMHost = $VMDetails.VMHost
            Folder = $VMDetails.Folder
            DiskGB = $VMDetails.ProvisionedSpaceGB
            ScsiControllerType = $SCSIDetails.Type
            IsoPath = $ISODetails.IsoPath
            FloppyPath = $FloppyDetails.FloppyImagePath
        }

        $Obj = New-Object -TypeName PSObject -Property $VM
                     
        Write-Output $Obj
    }
    End
    {
    }
}