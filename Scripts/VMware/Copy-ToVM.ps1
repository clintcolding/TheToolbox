$vms = Get-VM | where {$_.Name -match "ops"}
$source = "C:\Users\ccolding.ts\Downloads\NDP471-KB4054856-x86-x64-AllOS.exe"
$dest = "D:\Temp"
$cred = Import-Clixml ".\TheToolbox\Credentials\win-template-cred.xml"

$job = New-Object -typename System.Diagnostics.Stopwatch
$job.Start()

foreach ($vm in $vms) {
    Copy-VMGuestFile -VM $vm -Source $source -Destination $dest -LocalToGuest -GuestCredential $cred
}

$job.stop()
Write-Output "Job took $($job.elapsed.tostring())"
