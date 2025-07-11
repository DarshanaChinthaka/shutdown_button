Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # 🔐 Prevent system sleep while shutdown timer is active
 powercfg /requestsoverride process "shutdown.exe" system display
  #  exit
}



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
    $iconPath = "shutdown.ico"
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
    } else {
        return $null
    }
}

function Show-CancelPopup {
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
    $iconPath = "shutdown.ico"
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

Start-Sleep -Seconds $shutdownTime
Show-CancelPopup

if (-not $global:cancelled) {
    Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
    shutdown /s /t 0
}

If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    #  clear override when done
 powercfg /requestsoverride process "shutdown.exe"

   # exit
}


