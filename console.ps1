while ($true) {
    $CPU = (Get-WmiObject Win32_Processor).LoadPercentage
    $os = Get-Ciminstance Win32_OperatingSystem
    $pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100)
    $RAM = 100 - $pctFree
    
    Write-Host -NoNewLine "`rCPU Usage: $CPU%   RAM Usage: $RAM%"
    Start-Sleep -Milliseconds 3000
}