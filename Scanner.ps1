# Network Scanner - Remote Execution Version with IRM | IEX
# Author: CeresF3b
# Usage: irm https://raw.githubusercontent.com/CeresF3b/NetworkScanner/main/Scanner.ps1 | iex

# Get local IP address
$ipconfig = ipconfig
$ipAddressMatch = $ipconfig | Select-String -Pattern 'IPv4'
$localIP = ($ipAddressMatch | Select-Object -First 1).ToString().Split()[-1]

# Split IP address into octets
$octets = $localIP.Split('.')
$networkPrefix = "$($octets[0]).$($octets[1]).$($octets[2])"

# Initialize variables
$devicesFound = @()
$activeIPs = @()
$portScanResults = @()
$totalHosts = 254  # Number of hosts to scan in range 1-254

# Host range to scan
$hostRange = 1..$totalHosts

# Start scanning hosts on the network
Write-Host "`n[*] Starting host scan on network $networkPrefix.0/24..." -ForegroundColor Cyan

# Progress bar initialization
$progressCount = 0

foreach ($i in $hostRange) {
    $progressPercent = [int](($i / $totalHosts) * 100)
    Write-Progress -Activity "Scanning hosts..." -Status "Progress: $progressPercent%" -PercentComplete $progressPercent

    $currentIP = "$networkPrefix.$i"

    # Check if host is active
    if (Test-Connection -ComputerName $currentIP -Count 1 -Quiet -ErrorAction SilentlyContinue) {
        # Try to get hostname
        try {
            $hostEntry = [System.Net.Dns]::GetHostEntry($currentIP)
            $hostname = $hostEntry.HostName
        } catch {
            $hostname = "Not available"
        }

        # Save device information
        $devicesFound += [PSCustomObject]@{
            IP       = $currentIP
            HostName = $hostname
        }

        # Add IP to active IPs list
        $activeIPs += $currentIP
    }
    # $progressCount++ # This was likely a leftover from PC Fixer, not used here in the loop's original intent for network scanner
}

# Clear progress bar
Write-Progress -Activity "Scan completed" -Completed

# Check if active devices were found
if ($devicesFound.Count -gt 0) {
    Write-Host "`n[*] Active devices found on network $networkPrefix.0/24:" -ForegroundColor Cyan
    # Display results in table format
    $devicesFound | Sort-Object IP | Format-Table -AutoSize
} else {
    Write-Host "[*] No active devices found on the network." -ForegroundColor Yellow
}

# Function to get service name for common ports
function Get-PortService {
    param (
        [int]$PortNumber
    )

    $portServices = @{
        22   = "SSH"
        80   = "HTTP"
        135  = "RPC"
        139  = "NetBIOS"
        443  = "HTTPS"
        445  = "SMB"
        3389 = "RDP"
    }

    if ($portServices.ContainsKey($PortNumber)) {
        return $portServices[$PortNumber]
    } else {
        return "Unknown"
    }
}

# Define ports to scan (common ports)
$portsToScan = @(22, 80, 135, 139, 443, 445, 3389)

# Start port scanning on active hosts
Write-Host "`n[*] Starting port scan on active devices..." -ForegroundColor Cyan

foreach ($device in $devicesFound) {
    $currentIP = $device.IP
    Write-Host "[*] Scanning ports on $currentIP ($($device.HostName))..."

    foreach ($port in $portsToScan) {
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient

            # Set connection timeout
            $asyncResult = $tcpClient.BeginConnect($currentIP, $port, $null, $null)
            $waitSuccess = $asyncResult.AsyncWaitHandle.WaitOne(100, $false)  # 100ms timeout

            if ($waitSuccess -and $tcpClient.Connected) {
                Write-Host "[+] Port $port open on $currentIP" -ForegroundColor Green

                # Save port scan result
                $portScanResults += [PSCustomObject]@{
                    IP       = $currentIP
                    HostName = $device.HostName
                    Port     = $port
                    Service  = Get-PortService -PortNumber $port
                }
                $tcpClient.EndConnect($asyncResult)
            }

            $tcpClient.Close()
        } catch {
            # Ignore connection errors
        }
    }
}

Write-Host "`n[+] Port scan completed!" -ForegroundColor Green

# Show port scan results
if ($portScanResults.Count -gt 0) {
    Write-Host "`n[*] Open ports found on devices:" -ForegroundColor Cyan
    $portScanResults | Sort-Object IP,Port | Format-Table -AutoSize
} else {
    Write-Host "[*] No open ports found on active devices." -ForegroundColor Yellow
}

# Note: Final pause removed to allow execution with IRM | IEX
Write-Host "`n[*] Scan completed!" -ForegroundColor Green
