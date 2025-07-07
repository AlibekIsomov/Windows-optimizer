# -----------------------------
# Windows Gaming Optimizer GUI
# Need to work on this this is just a (not working) DEMO
# -----------------------------

Add-Type -AssemblyName PresentationFramework

function Log($msg) {
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logBox.Dispatcher.Invoke([action]{
        $logBox.AppendText("[$timestamp] $msg`n")
        $logBox.ScrollToEnd()
    })
}

function Set-LoadingCursor {
    $window.Cursor = [System.Windows.Input.Cursors]::Wait
}

function Set-NormalCursor {
    $window.Cursor = [System.Windows.Input.Cursors]::Arrow
}

function Clean-Temporary-Files {
    Set-LoadingCursor
    Log "Cleaning temporary files and shader caches..."
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\NVIDIA\GLCache" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\AMD\DxCache" -Recurse -Force -ErrorAction SilentlyContinue
    Log "Temp and shader cache cleanup complete."
    Set-NormalCursor
}

function Disable-Useless-Services {
    Set-LoadingCursor
    $servicesToDisable = @(
        "SysMain", "WSearch", "Fax", "Spooler",
        "RemoteRegistry", "RetailDemo", "WerSvc",
        "MapsBroker", "DiagTrack", "dmwappushservice"
    )
    Log "Disabling unnecessary Windows services..."
    foreach ($service in $servicesToDisable) {
        try {
            Stop-Service -Name $service -Force -ErrorAction Stop
            Set-Service -Name $service -StartupType Disabled
            Log "Disabled $service"
        } catch {
            $errorMessage = $_.Exception.Message
            Log "Could not disable $($service): $($errorMessage)"
        }
    }
    Log "Disabling GameDVR and Game Bar..."
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKCU\Software\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d 0 /f | Out-Null
    Log "GameDVR and Xbox Game Bar disabled."
    Set-NormalCursor
}

function GPU-Tweaks {
    Set-LoadingCursor
    $gpuInfo = Get-WmiObject win32_VideoController | Select-Object -ExpandProperty Name
    foreach ($gpu in $gpuInfo) {
        Log "Detected GPU: $gpu"
    }
    Log "Use NVIDIA/AMD Control Panel to set max performance, disable V-Sync, and enable GPU scheduling."
    Set-NormalCursor
}

function Create-Backup {
    Set-LoadingCursor
    Log "Creating restore point..."
    Checkpoint-Computer -Description "GamingOptimize_Backup_$(Get-Date -Format yyyyMMdd_HHmm)" -RestorePointType "MODIFY_SETTINGS"
    Log "System restore point created."
    Set-NormalCursor
}

function Enable-Ultimate-Performance {
    Set-LoadingCursor
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    Log "Ultimate Performance power plan enabled."
    Set-NormalCursor
}

$xaml = @"
<Window xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
        Title='Win11 Gaming Optimizer Pro' Height='600' Width='480' ResizeMode='NoResize' Background='#1E1E1E'>
    <StackPanel Margin='20' VerticalAlignment='Top'>
        <TextBlock Text='Windows Gaming Optimizer' FontSize='24' FontWeight='Bold' Foreground='White' HorizontalAlignment='Center' Margin='0,0,0,10' />
        <WrapPanel HorizontalAlignment='Center' Margin='0,10,0,10'>
            <Button Name='btnClean' Content='Clean Temp Files' Width='210' Height='40' Margin='5' />
            <Button Name='btnDisable' Content='Disable Useless Services' Width='210' Height='40' Margin='5' />
            <Button Name='btnGPU' Content='GPU Info &amp; Tips' Width='210' Height='40' Margin='5' />
            <Button Name='btnBackup' Content='Create Backup Point' Width='210' Height='40' Margin='5' />
            <Button Name='btnPerf' Content='Enable Ultimate Performance' Width='210' Height='40' Margin='5' />
        </WrapPanel>
        <TextBlock Text='Logs:' FontSize='16' FontWeight='Bold' Foreground='White' Margin='0,10,0,5' />
        <TextBox Name='logBox' Height='200' Background='Black' Foreground='Lime' FontFamily='Consolas' FontSize='13' TextWrapping='Wrap' IsReadOnly='True' VerticalScrollBarVisibility='Auto'/>
        <Button Name='btnExit' Content='Exit' Height='35' Width='100' HorizontalAlignment='Center' Margin='0,20,0,0' Background='DarkRed' Foreground='White' FontWeight='Bold' />
    </StackPanel>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader ([xml]$xaml))
$window = [Windows.Markup.XamlReader]::Load($reader)

$btnClean   = $window.FindName("btnClean")
$btnDisable = $window.FindName("btnDisable")
$btnGPU     = $window.FindName("btnGPU")
$btnBackup  = $window.FindName("btnBackup")
$btnPerf    = $window.FindName("btnPerf")
$btnExit    = $window.FindName("btnExit")
$logBox     = $window.FindName("logBox")

$btnClean.Add_Click({ Clean-Temporary-Files })
$btnDisable.Add_Click({ Disable-Useless-Services })
$btnGPU.Add_Click({ GPU-Tweaks })
$btnBackup.Add_Click({ Create-Backup })
$btnPerf.Add_Click({ Enable-Ultimate-Performance })
$btnExit.Add_Click({ $window.Close() })

$window.ShowDialog() | Out-Null