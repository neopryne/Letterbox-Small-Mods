@echo off
setlocal

REM Call the PowerShell script
powershell -NoProfile -ExecutionPolicy Bypass -File "Build.ps1"

endlocal