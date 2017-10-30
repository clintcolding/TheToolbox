function Upgrade-VM
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Position=0)]
        [String[]]$VM
    )
    Begin{}

    Process{

        ## Confirm VM exists

        if (!(Get-VM $VM -ErrorAction SilentlyContinue)) {
            Write-Warning "$VM not found!"
        }

        ## Determine if VM version needs to be upgraded

        if ((Get-VM $VM).Version -ne "v13") {
        
            ## Shutdown VM Guest OS if needed

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
        }

        ## Confirm VM Version upgrade was successful

        if ((Get-VM $VM).Version -eq "v13" -and (Get-VM $VM).PowerState -eq 'PoweredOff') {
            Start-VM -VM $VM
        }
        elseif ((Get-VM $VM).Version -ne "v13") {
            Write-Warning "Failed to upgrade $VM to v13!"
            break
        }

        ## Once VM guest is online confirm VM Tool update is needed, if so, Update-Tools

        $RetryCount = 0

        while ($true) {

            if ((Test-Connection $VM -Count 2) -and (Get-VM $VM).ExtensionData.Guest.ToolsStatus -eq 'toolsOld') {
                Update-Tools -VM $VM
                break
            }

            if ((Test-Connection $VM -Count 2) -and (Get-VM $VM).ExtensionData.Guest.ToolsStatus -eq 'toolsOk') {
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
    }
    End{}
}