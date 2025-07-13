class AdminChecker {
    static [bool] IsAdmin() {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
}

# 🛑 Relaunch as Admin if not already
if (-not [AdminChecker]::IsAdmin()) {
    Write-Host "🔐 Not running as Administrator. Relaunching..."

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb = "runas"
    [System.Diagnostics.Process]::Start($psi) | Out-Null
    exit
}

# ✅ Code below ONLY runs in Administrator mode
Write-Host "✅ Running as Administrator. Continuing script..."

# --- Your actual admin-only logic here ---
Start-Sleep -Seconds 5
Write-Host "🛠️ Doing something that requires admin..."
