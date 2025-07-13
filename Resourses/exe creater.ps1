Invoke-ps2exe `
  -inputFile "Resourses\shutdown.ps1" `
  -outputFile "shutdown.exe" `
  -iconFile "Resourses\shutdown.ico" `
  -noConsole `
  -requireAdmin
