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
                Write-Verbose "Shutting down guest OS..."
                Shutdown-VMGuest -VM $VM -Confirm:$false | Out-Null
            }

            ## If VM is powered off, upgrade VM version, else delay 10 seconds and try again.

            $RetryCount = 0

            while ($true) {
                
                if ((Get-VM $VM).PowerState -eq 'PoweredOff') {
                    Write-Verbose "Upgrading $VM to VM version v13..."
                    Set-VM -VM $VM -Version v13 -Confirm:$false | Out-Null
                    break
                }
                else {
                    if ($RetryCount -gt 10) {
                        Write-Warning "Failed to power off $VM"
                        break
                    }
                    else {
                        $RetryCount++
                        Write-Verbose "Waiting for $VM to power off..."
                        Start-Sleep -Seconds 15
                    }
                }
            }
        }

        ## Confirm VM Version upgrade was successful

        if ((Get-VM $VM).Version -eq "v13" -and (Get-VM $VM).PowerState -eq 'PoweredOff') {
            Write-Verbose "Powering on $VM..."
            Start-VM -VM $VM | Out-Null
        }
        elseif ((Get-VM $VM).Version -ne "v13") {
            Write-Warning "Failed to upgrade $VM to v13!"
            break
        }

        ## Once VM guest is online confirm VM Tool update is needed, if so, Update-Tools

        $RetryCount = 0

        while ($true) {

            if ((Get-VM $VM).ExtensionData.Guest.ToolsStatus -eq 'toolsOld') {
                Start-Sleep -Seconds 15
                Write-Verbose "Updating VM Tools on $VM..."
                Update-Tools -VM $VM -warn | Out-Null
                break
            }

            if ((Get-VM $VM).ExtensionData.Guest.ToolsStatus -eq 'toolsOk') {
                Write-Message "VM Tools already current!"
                break
            }

            else {
                if ($RetryCount -gt 10) {
                    Write-Warning "VM Tools not running on $VM!"
                    break
                }
                else {
                    $RetryCount++
                    Write-Verbose "Waiting for guest OS..."
                    Start-Sleep -Seconds 15
                }
            }
        }
    }
    End{}
}