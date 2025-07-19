Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing  

# Ensure the script runs with elevated privileges
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class SleepBlocker {
    [DllImport("kernel32.dll")]
    public static extern uint SetThreadExecutionState(uint esFlags);
}
"@

# Workaround: use [uint32]::Parse with unsigned decimal value strings
$ES_CONTINUOUS = [uint32]::Parse("2147483648")
$ES_SYSTEM_REQUIRED = [uint32]::Parse("1")
$ES_DISPLAY_REQUIRED = [uint32]::Parse("2") 

# Combine flags to prevent sleep + lock (display off)
$flags = $ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED  -bor $ES_DISPLAY_REQUIRED
[SleepBlocker]::SetThreadExecutionState($flags) | Out-Null


function Show-TimerInput {
    [System.Media.SystemSounds]::Hand.Play()

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Shutdown Timer"
    $form.Size = New-Object System.Drawing.Size(320, 180)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = "WhiteSmoke"
    $form.TopMost = $true
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $true   

    # Icon
    $iconPath = ".\Resourses\shutdown.ico"
    if (Test-Path $iconPath) {
        $form.Icon = New-Object System.Drawing.Icon($iconPath)
    }

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Enter Shutdown Timer (in minutes):"
    $label.Location = New-Object System.Drawing.Point(20, 20)
    $label.Size = New-Object System.Drawing.Size(260, 20)
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $form.Controls.Add($label)

    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Location = New-Object System.Drawing.Point(20, 50)
    $textbox.Size = New-Object System.Drawing.Size(260, 25)
    $textbox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $form.Controls.Add($textbox)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "Start"
    $okButton.Location = New-Object System.Drawing.Point(110, 90)
    $okButton.Size = New-Object System.Drawing.Size(80, 30)
    $okButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $okButton.BackColor = "#0078D7"
    $okButton.ForeColor = "White"
    $okButton.FlatStyle = "Flat"
    $okButton.Add_Click({
            $form.DialogResult = "OK"

            # 🔁 AC Power - Set lid close action to 'Sleep'
            powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0

            # 🔁 Battery Power - Set lid close action to 'Sleep'
            powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0

            # 🔄 Apply changes
            powercfg /S SCHEME_CURRENT
            
            

            $form.Close()
        })
    $form.Controls.Add($okButton)
    $form.AcceptButton = $okButton

    # Watermark
    $watermark = New-Object System.Windows.Forms.Label
    $watermark.Text = "Project By Darshana"
    $watermark.Location = New-Object System.Drawing.Point(210, 120)
    $watermark.Size = New-Object System.Drawing.Size(150, 15)
    $watermark.Font = New-Object System.Drawing.Font("Segoe UI", 7.5, [System.Drawing.FontStyle]::Italic)
    $watermark.ForeColor = "Gray"
    $form.Controls.Add($watermark)

    $result = $form.ShowDialog()
    if ($result -eq "OK") {
        if ([string]::IsNullOrWhiteSpace($textbox.Text)) {
            shutdown /s /t 0
            return
        }
        return [int]$textbox.Text
    }
    else {
        return $null
    }
}

function Show-CancelPopup {
    # Restore sleep
    [SleepBlocker]::SetThreadExecutionState($ES_CONTINUOUS) | Out-Null

    

    # 🔁 AC Power - Set lid close action to 'Sleep'
    powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1

    # 🔁 Battery Power - Set lid close action to 'Sleep'
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1

    # 🔄 Apply changes
    powercfg /S SCHEME_CURRENT
            
    
    

    [System.Media.SystemSounds]::Hand.Play()

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Cancel Shutdown?"
    $form.Size = New-Object System.Drawing.Size(300, 160)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = "White"
    $form.TopMost = $true
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $true

    # Icon
    $iconPath = ".\Resources\shutdown.ico"
    if (Test-Path $iconPath) {
        $form.Icon = New-Object System.Drawing.Icon($iconPath)
    }

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "System will shut down in 15 seconds."
    $label.Location = New-Object System.Drawing.Point(30, 20)
    $label.Size = New-Object System.Drawing.Size(240, 30)
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $form.Controls.Add($label)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = "Cancel Shutdown"
    $cancelButton.Location = New-Object System.Drawing.Point(85, 70)
    $cancelButton.Size = New-Object System.Drawing.Size(130, 30)
    $cancelButton.BackColor = "#E81123"
    $cancelButton.ForeColor = "White"
    $cancelButton.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $cancelButton.FlatStyle = "Flat"
    $cancelButton.Add_Click({
            $global:cancelled = $true
            $form.Close()
        })
    $form.Controls.Add($cancelButton)
    $form.AcceptButton = $cancelButton

    $global:cancelled = $false
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 15000
    $timer.Add_Tick({
            $timer.Stop()
            $form.Close()
        })
    $timer.Start()

    [System.Windows.Forms.Application]::Run($form)
}

# -------- MAIN PROGRAM --------
$minutes = Show-TimerInput
if ($minutes -eq $null -or $minutes -le 0) { return }

$shutdownTime = ($minutes * 60) - 15
if ($shutdownTime -lt 0) { $shutdownTime = 0 }


# --- Show countdown timer window ---
$timerForm = New-Object System.Windows.Forms.Form
$timerForm.Text = "Shutdown Countdown"
$timerForm.Size = New-Object System.Drawing.Size(300, 120)
$timerForm.StartPosition = "CenterScreen"
$timerForm.BackColor = "White"
$timerForm.TopMost = $true
$timerForm.FormBorderStyle = 'FixedDialog'
$timerForm.MaximizeBox = $false
$timerForm.MinimizeBox = $true

$timerLabel = New-Object System.Windows.Forms.Label
$timerLabel.Text = "Shutdown in: $($shutdownTime) seconds"
$timerLabel.Location = New-Object System.Drawing.Point(40, 30)
$timerLabel.Size = New-Object System.Drawing.Size(220, 30)
$timerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$timerLabel.TextAlign = 'MiddleCenter'
$timerForm.Controls.Add($timerLabel)

$script:countdown = $shutdownTime
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    $script:countdown--
    $timerLabel.Text = "Shutdown in: $($script:countdown) seconds"
    if ($script:countdown -le 0) {
        $timer.Stop()
        $timerForm.Close()
    }
})
$timer.Start()
[void]$timerForm.ShowDialog()

# --- After countdown, show cancel popup ---
Show-CancelPopup

if (-not $global:cancelled) {
    Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
    shutdown /s /f /t 0
}

