# SleepTimeoutSwapRestore.ps1
# Swap AC/DC sleep timeout hex values and restore

Write-Host "`n🔄 Reading current AC/DC sleep timeout values..."

# --- Read AC value (first match) ---
$rawSleepAC = powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE |
    Select-String "Power Setting Index" | Select-Object -First 1
$hexSleepAC = if ($rawSleepAC -match "0x([0-9A-Fa-f]+)") {
    "0x$($matches[1])"
} else {
    Write-Host "❌ Couldn't find AC hex value!" -ForegroundColor Red
    "0x0000000A"
}

# --- Read DC value (last match) ---
$rawSleepDC = powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE |
    Select-String "Power Setting Index" | Select-Object -Last 1
$hexSleepDC = if ($rawSleepDC -match "0x([0-9A-Fa-f]+)") {
    "0x$($matches[1])"
} else {
    Write-Host "❌ Couldn't find DC hex value!" -ForegroundColor Red
    "0x0000000A"
}

Write-Host "✅ Original AC Sleep Timeout: $hexSleepAC"
Write-Host "✅ Original DC Sleep Timeout: $hexSleepDC"

# --- Swap & Restore ---
Write-Host "`n🔁 Swapping values and restoring..."

# Apply DC value to AC
powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 10

# Apply AC value to DC
powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 12

# Apply changes
powercfg /S SCHEME_CURRENT

Write-Host "`n🟢 Successfully swapped and restored sleep timeouts!"
Write-Host "    → AC now uses: $hexSleepDC"
Write-Host "    → DC now uses: $hexSleepAC"
