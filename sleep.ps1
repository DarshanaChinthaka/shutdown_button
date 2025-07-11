# Set screen turn-off timeout (on AC power) to 5 minutes
powercfg /change monitor-timeout-ac 5

# Set sleep timeout (on AC power) to 5 minutes
powercfg /change standby-timeout-ac 5

# Set screen turn-off timeout (on battery) to 5 minutes
powercfg /change monitor-timeout-dc 5

# Set sleep timeout (on battery) to 5 minutes
powercfg /change standby-timeout-dc 5

Write-Host "Sleep & screen-off timers set to 5 minutes for both AC and Battery." -ForegroundColor Green
