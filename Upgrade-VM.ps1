$VM = 'testvm'

## Confirm VM exists

if (!(Get-VM $VM -ErrorAction SilentlyContinue)) {
    Write-Warning "$VM not found!"
}

## If VM is powered on, shutdown VM Guest OS

if ((Get-VM $VM).PowerState -eq 'PoweredOn') {
    Shutdown-VMGuest -VM $VM -Confirm:$false
}

## If VM is powered off, upgrade VM version, else delay 10 seconds and try again.

$RetryCount = 0

while ($true) {
    
    if ((Get-VM $VM).PowerState -eq 'PoweredOff') {
        Set-VM -VM $VM -Version v13 -Confirm:$false
        break
    }
    else {
        if ($RetryCount -gt 10) {
            Write-Warning "Failed to power off $VM"
            break
        }
        else {
            $RetryCount++
            Write-Host "Attempt $RetryCount"
            Start-Sleep -Seconds 15
        }
    }
}

if ((Get-VM $VM).Version -eq "v13") {
    Start-VM -VM $VM
}

$RetryCount = 0

while ($true) {

    if (Test-Connection $VM -Count 2) {
        Update-Tools -VM $VM
        break
    }
    else {
        if ($RetryCount -gt 10) {
            Write-Warning "Unable to connect to $VM"
            break
        }
        else {
            $RetryCount++
            Write-Host "Attempt $RetryCount"
            Start-Sleep -Seconds 15
        }
    }
}