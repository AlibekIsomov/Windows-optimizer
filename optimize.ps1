# ⚡ Windows 11 Gaming Optimizer Script
# Run this as Admin

Write-Host "`n=== Windows 11 Gaming Optimizer ===`n" -ForegroundColor Cyan

# Check admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ Please run this script as Administrator!" -ForegroundColor Red
    exit
}

# 💡 Enable Ultimate Performance Power Plan
Write-Host "[+] Enabling Ultimate Performance Mode..."
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61

# 🛑 Disable Unwanted Services
$servicesToDisable = @(
    "SysMain",
    "WSearch",               # Windows Search
    "Fax",
    "Spooler",               # Printer
    "RemoteRegistry",
    "RetailDemo",
    "WerSvc",                # Error Reporting
    "BluetoothSupportService"
)

foreach ($svc in $servicesToDisable) {
    Write-Host "[-] Disabling service: $svc"
    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
    Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

# 🎮 Disable Game DVR & Xbox Game Bar
Write-Host "[+] Disabling Game Bar and DVR..."
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\GameBar" /v ShowStartupPanel /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 0 /f

# 🧹 Disable Hibernation
Write-Host "[+] Disabling Hibernation..."
powercfg -h off

# 🪟 Disable Background Apps
Write-Host "[+] Disabling Background Apps..."
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f

# 🎨 Adjust Visual Effects
Write-Host "[+] Setting visual effects to best performance..."
$perfKey = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
reg add $perfKey /v VisualFXSetting /t REG_DWORD /d 2 /f

# ✅ Done
Write-Host "`n✅ Optimization complete! Restart your PC to apply all changes." -ForegroundColor Green
