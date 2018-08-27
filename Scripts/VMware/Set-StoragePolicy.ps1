$vms = Get-VM | Where-Object {$_.Name -match "ops"}
$policyName = "OPS-Policy"

$policy = Get-SpbmStoragePolicy $policyName
foreach ($vm in $vms) {
    Write-Host -ForegroundColor Cyan "[$($vm.Name)]    Validating storage policy"
    foreach ($vhd in ($vm | Get-HardDisk)) {
        if (($config = Get-SpbmEntityConfiguration $vhd).StoragePolicy -notmatch $policy) {
            Write-Host -ForegroundColor Yellow "[$($vm.Name)]    Remediating $($vhd.Name)"
            $config | Set-SpbmEntityConfiguration -StoragePolicy $policy | Out-Null
        }
    }
}
