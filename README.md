# 🔌 PowerShell Shutdown Timer

A lightweight GUI-based PowerShell script to schedule a system shutdown with a cancel option and sleep prevention.

## ✅ Features

- Simple timer input (in minutes)
- Cancel popup before shutdown (15s)
- Prevents sleep, lock, and display-off
- Resets lid-close action after run
- Works as script or EXE

## ⚙️ How to Use

1. Download And Run shutdown.exe file
2. Enter shutdown time
3. Cancel if needed when warned
4. PC shuts down automatically

## 🛠 Convert to EXE

```powershell
Invoke-ps2exe -inputFile "shutdown.ps1" `
              -outputFile "ShutdownTimer.exe" `
              -iconFile "shutdown.ico" `
              -noConsole
```
👨‍💻 Author
Darshana Chinthaka
