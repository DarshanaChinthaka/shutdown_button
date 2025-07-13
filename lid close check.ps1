# Get the current Lid close action (plugged in) setting
$lidCloseRaw = powercfg /query SCHEME_CURRENT SUB_BUTTONS LIDACTION | Select-String "Power Setting Index" | Select-Object -First 1

# Extract the value (in hex, like 0x00000001)
$hexValue = ($lidCloseRaw -split ':')[1].Trim()

# Convert hex to integer
$lidClose = [convert]::ToInt32($hexValue, 16)

# Output value for testing (optional)
Write-Host "Lid Close Action (Plugged in): $lidClose"
