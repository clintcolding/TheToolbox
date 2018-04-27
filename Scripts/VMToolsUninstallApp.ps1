$app = "Microsoft Web Deploy 3.5"
$winun = "admin"
$winpw = "password"

$script = @'
$uninstall64 = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match $app } | select UninstallString
if ($uninstall64) {
    $uninstall64 = $uninstall64.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
    $uninstall64 = $uninstall64.Trim()
    start-process "msiexec.exe" -arg "/X $uninstall64 /qb" -Wait
}
'@

$vms = Get-VM
foreach ($vm in $vms) {
    $vm | Invoke-VMScript -GuestUser $winun -GuestPassword $winpw -ScriptText $script -WarningAction SilentlyContinue
}
