# Script Name: IP Diagnostic Tool (Interactive)

$path = $PSScriptRoot
$inputFile = "$path\list.txt"
$deadFile = "$path\dead_ips.txt"

function Run-IPCheck {
    param($InputPath, $OutputPath)
    
    $success = 0
    $fail = 0

    if (Test-Path $OutputPath) { Remove-Item $OutputPath -Force }

    if (Test-Path $InputPath) {
        $lines = Get-Content $InputPath
        Write-Host "`n--- STARTING IP CHECK: $(Get-Date -Format 'HH:mm:ss') ---" -ForegroundColor Cyan
        Write-Host "------------------------------------------------"

        foreach ($line in $lines) {
            $line = $line.Trim()
            if ($line) {
                $parts = $line -split '\s+'
                $target = $parts[-1]

                $details = Test-NetConnection -ComputerName $target -WarningAction SilentlyContinue
                $resolvedIP = if ($details.RemoteAddress) { "[$($details.RemoteAddress)]" } else { "[No IP]" }

                if ($details.PingSucceeded) {
                    $success++
                    $ms = $details.PingReplyDetails.RoundtripTime
                    Write-Host "[ONLINE]  $target $resolvedIP - Response: $($ms)ms" -ForegroundColor Green
                } else {
                    $fail++
                    $errorReason = "Request Timed Out"
                    if (-not $details.RemoteAddress) { $errorReason = "Unknown Host (DNS Failure)" }
                    
                    Write-Host "[OFFLINE] $target $resolvedIP - Error: $errorReason" -ForegroundColor Red
                    "$line - $resolvedIP - $errorReason" | Out-File -FilePath $OutputPath -Append
                }
            }
        }

        Write-Host "------------------------------------------------"
        Write-Host "TEST SUMMARY"
        Write-Host "Total Successful:   $success" -ForegroundColor Green
        Write-Host "Total Unsuccessful: $fail" -ForegroundColor Red
        Write-Host "------------------------------------------------"
    }
    return @($success, $fail)
}

# --- Main Program Loop ---
do {
    $results = Run-IPCheck -InputPath $inputFile -OutputPath $deadFile

    Write-Host "OPTIONS: [y] Run again | [yy] Run continuously | [n] Stop" -ForegroundColor Cyan
    $choice = Read-Host "Select an option"

    if ($choice -eq "yy") {
        Write-Host "`nContinuous mode active." -ForegroundColor Yellow
        Write-Host ">> PRESS 'Q' TO STOP CONTINUOUS MODE AND RETURN TO MENU <<" -ForegroundColor White -BackgroundColor DarkRed
        
        while ($true) {
            # Check if 'q' was pressed
            if ([console]::KeyAvailable) {
                $key = [console]::ReadKey($true)
                if ($key.Key -eq 'Q') { 
                    Write-Host "`nStopping continuous mode..." -ForegroundColor Yellow
                    break 
                }
            }

            $null = Run-IPCheck -InputPath $inputFile -OutputPath $deadFile
            
            Write-Host "Next scan in 5 seconds... (Press 'Q' to stop)" -ForegroundColor Gray
            
            # Wait 5 seconds, but check for 'Q' every 100ms so it feels responsive
            for ($i = 0; $i -lt 50; $i++) {
                if ([console]::KeyAvailable) {
                    $key = [console]::ReadKey($true)
                    if ($key.Key -eq 'Q') { break }
                }
                Start-Sleep -Milliseconds 100
            }
        }
        # After breaking the while loop, it will loop back to the 'y/yy/n' choice
        $choice = "menu" 
    }

} while ($choice -eq "y" -or $choice -eq "menu")

Write-Host "Script stopped. Goodbye!"
Start-Sleep -Seconds 2