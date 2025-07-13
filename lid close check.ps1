# WMI event query for lid close (power event 4 = lid close)
$query = "SELECT * FROM Win32_PowerManagementEvent WHERE EventType = 4"

# Create event watcher
$watcher = New-Object System.Management.ManagementEventWatcher $query

Write-Host "Waiting for laptop lid close event..."

while ($true) {
    $event = $watcher.WaitForNextEvent()
    Write-Host "Laptop lid closed detected at $(Get-Date)"
    # මෙතනට ඔබට ලැප්ටොප් lid close event එකට assign කරන්න අවශ්‍ය code එක දාන්න
}
