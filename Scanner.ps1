<#
PC Fixer - PowerShell Script
Created by CeresF3B
#>

# Function to display the main menu
function Show-Menu {
    Clear-Host
    Write-Host "-----------------------------------------" -ForegroundColor Cyan
    Write-Host "|             PC FIXER                |" -ForegroundColor Cyan
    Write-Host "|        Created by CeresF3B          |" -ForegroundColor Cyan
    Write-Host "-----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Select an operation:" -ForegroundColor Yellow
    Write-Host "1. Clean temporary files" -ForegroundColor White
    Write-Host "2. System repairs" -ForegroundColor White
    Write-Host "3. Reset network configurations" -ForegroundColor White
    Write-Host "4. Generate battery report" -ForegroundColor White
    Write-Host "5. Update system with winget" -ForegroundColor White
    Write-Host "6. Run all operations" -ForegroundColor Magenta
    Write-Host "Q. Exit" -ForegroundColor Red
    Write-Host ""
}

# Function to clean temporary files
function Clean-TempFiles {
    Write-Host "[*] Cleaning temporary files..." -ForegroundColor Yellow
    
    # Cleaning standard temporary files
    Write-Host "[*] Cleaning standard temporary files..." -ForegroundColor Yellow
    Remove-Item -Path "$env:TEMP\*" -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Prefetch\*" -Force -Recurse -ErrorAction SilentlyContinue
    
    # Cleaning additional temporary files
    Write-Host "[*] Cleaning additional temporary files..." -ForegroundColor Yellow
    Remove-Item -Path "$env:WINDIR\Downloaded Program Files\*" -Force -Recurse -ErrorAction SilentlyContinue
    
    # Cleaning Microsoft Defender Antivirus files
    Write-Host "[*] Cleaning Microsoft Defender Antivirus files..." -ForegroundColor Yellow
    Remove-Item -Path "C:\ProgramData\Microsoft\Windows Defender\Scans\History\*" -Force -Recurse -ErrorAction SilentlyContinue
    
    # Cleaning Windows Update log files
    Write-Host "[*] Cleaning Windows Update log files..." -ForegroundColor Yellow
    Remove-Item -Path "C:\Windows\Logs\WindowsUpdate\*" -Force -Recurse -ErrorAction SilentlyContinue
    
    # Cleaning Internet temporary files
    Write-Host "[*] Cleaning Internet temporary files..." -ForegroundColor Yellow
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*" -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\WebCache\*" -Force -Recurse -ErrorAction SilentlyContinue
    
    # Cleaning DirectX shader cache
    Write-Host "[*] Cleaning DirectX shader cache..." -ForegroundColor Yellow
    Remove-Item -Path "$env:LOCALAPPDATA\D3DSCache\*" -Force -Recurse -ErrorAction SilentlyContinue
    
    # Cleaning delivery optimization files
    Write-Host "[*] Cleaning delivery optimization files..." -ForegroundColor Yellow
    Remove-Item -Path "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache\*" -Force -Recurse -ErrorAction SilentlyContinue
    
    # Cleaning driver packages
    Write-Host "[*] Cleaning driver packages..." -ForegroundColor Yellow
    DISM.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase /NoRestart
    
    # Cleaning thumbnails
    Write-Host "[*] Cleaning thumbnails..." -ForegroundColor Yellow
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue
    
    # Cleaning Windows error reports
    Write-Host "[*] Cleaning Windows error reports..." -ForegroundColor Yellow
    Remove-Item -Path "C:\Windows\WER\*" -Force -Recurse -ErrorAction SilentlyContinue
    
    # Cleaning Recycle Bin (optional)
    Write-Host "[*] Do you want to empty the Recycle Bin? (Y/N)" -ForegroundColor Yellow
    $cleanRecycleBin = Read-Host
    if ($cleanRecycleBin -eq "Y" -or $cleanRecycleBin -eq "y") {
        Write-Host "[*] Cleaning Recycle Bin..." -ForegroundColor Yellow
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Host "[+] Recycle Bin emptied successfully!" -ForegroundColor Green
    } else {
        Write-Host "[*] Skipping Recycle Bin cleanup." -ForegroundColor Yellow
    }
    
    Write-Host "[+] Advanced cleaning completed!" -ForegroundColor Green
}

# Function for system repairs
function Repair-System {
    Write-Host "[*] Starting system repairs..." -ForegroundColor Yellow
    
    Write-Host "[*] Running SFC /scannow..." -ForegroundColor Yellow
    sfc /scannow
    
    Write-Host "[*] Running DISM /CheckHealth..." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /CheckHealth
    
    Write-Host "[*] Running DISM /ScanHealth..." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /ScanHealth
    
    Write-Host "[*] Running DISM /RestoreHealth..." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /RestoreHealth
    
    Write-Host "[+] System repairs completed!" -ForegroundColor Green
}

# Function for network reset
function Reset-NetworkConfig {
    Write-Host "[*] Resetting network configurations..." -ForegroundColor Yellow
    ipconfig /flushdns
    netsh winsock reset
    netsh int ip reset
    Write-Host "[+] Network reset completed!" -ForegroundColor Green
}

# Function to generate battery report
function Generate-BatteryReport {
    Write-Host "[*] Checking device type..." -ForegroundColor Yellow
    
    # Check if the device has a battery (laptop) or not (desktop)
    $batteryStatus = Get-WmiObject -Class Win32_Battery -ErrorAction SilentlyContinue
    
    if ($batteryStatus) {
        # Device is a laptop
        Write-Host "[*] Laptop detected. Generating battery report..." -ForegroundColor Yellow
        powercfg /batteryreport /output "$env:USERPROFILE\Desktop\BatteryReport.html"
        Write-Host "[+] Battery report successfully generated on Desktop!" -ForegroundColor Green
    } else {
        # Device is a desktop
        Write-Host "[!] Desktop PC detected. Battery report cannot be generated." -ForegroundColor Red
        Write-Host "[!] This feature is only available for laptops with batteries." -ForegroundColor Red
    }
}

# Function to update system using winget
function Update-System {
    Write-Host "[*] Checking for system updates using winget..." -ForegroundColor Yellow
    
    # Check if winget is installed
    try {
        $wingetCheck = Get-Command winget -ErrorAction Stop
        Write-Host "[*] Winget is installed. Proceeding with updates..." -ForegroundColor Yellow
        
        # Run winget upgrade --all
        Write-Host "[*] Running winget upgrade --all..." -ForegroundColor Yellow
        winget upgrade --all
        
        Write-Host "[+] System update completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Winget is not installed or not available in PATH." -ForegroundColor Red
        Write-Host "[!] Please install winget or add it to your PATH to use this feature." -ForegroundColor Red
    }
}

# Function to run all operations
function Run-AllOperations {
    # For automated operation, we'll skip Recycle Bin cleanup by default
    # This is handled inside the Clean-TempFiles function with user prompt
    Clean-TempFiles
    Repair-System
    Reset-NetworkConfig
    Generate-BatteryReport
    Update-System
}

# Function to exit the program
function Exit-Program {
    Write-Host ""
    Write-Host "[+] All operations completed successfully!" -ForegroundColor Green
    Write-Host "[+] Thank you for using PC Fixer!" -ForegroundColor Green
    Write-Host "[+] Created by CeresF3B" -ForegroundColor Cyan
    
    # Save exit message
    $exitMessage = "Thank you for using PC Fixer! Created by CeresF3B"
    $exitMessage | Out-File -FilePath "$env:TEMP\PCFixerExitMessage.txt"
    
    # Countdown timer before automatic exit
    Write-Host ""
    $countdown = 5
    while ($countdown -gt 0) {
        Write-Host "[*] PowerShell will close automatically in $countdown seconds..." -ForegroundColor Yellow -NoNewline
        Start-Sleep -Seconds 1
        Write-Host "`r" -NoNewline
        $countdown--
    }
    
    # Exit PowerShell
    exit
}

# Main program loop
do {
    Show-Menu
    $choice = Read-Host "Enter your choice"
    
    switch ($choice) {
        "1" { Clean-TempFiles; pause }
        "2" { Repair-System; pause }
        "3" { Reset-NetworkConfig; pause }
        "4" { Generate-BatteryReport; pause }
        "5" { Update-System; pause }
        "6" { Run-AllOperations; pause }
        "Q" { Exit-Program }
        "q" { Exit-Program }
        default { Write-Host "[!] Invalid choice. Try again." -ForegroundColor Red; pause }
    }
} while ($true)
