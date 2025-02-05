# Ottieni l'indirizzo IP locale
$ipconfig = ipconfig
$ipAddressMatch = $ipconfig | Select-String -Pattern 'IPv4'
$localIP = ($ipAddressMatch | Select-Object -First 1).ToString().Split()[-1]

# Suddividi l'indirizzo IP in ottetti
$octets = $localIP.Split('.')
$networkPrefix = "$($octets[0]).$($octets[1]).$($octets[2])"

# Inizializza le variabili
$devicesFound = @()
$activeIPs = @()
$portScanResults = @()
$totalHosts = 254  # Numero di host da scansionare nell'intervallo 1-254

# Intervallo degli host da scansionare
$hostRange = 1..$totalHosts

# Inizia la scansione degli host sulla rete
Write-Host "`n[*] Inizio scansione degli host sulla rete $networkPrefix.0/24..."

# Barra di progresso
$progressCount = 0

foreach ($i in $hostRange) {
    $progressPercent = [int](($i / $totalHosts) * 100)
    Write-Progress -Activity "Scansione degli host..." -Status "Percentuale completata: $progressPercent%" -PercentComplete $progressPercent

    $currentIP = "$networkPrefix.$i"

    # Verifica se l'host è attivo
    if (Test-Connection -ComputerName $currentIP -Count 1 -Quiet -ErrorAction SilentlyContinue) {
        # Tenta di ottenere il nome host
        try {
            $hostEntry = [System.Net.Dns]::GetHostEntry($currentIP)
            $hostname = $hostEntry.HostName
        } catch {
            $hostname = "Non disponibile"
        }

        # Salva le informazioni sul dispositivo
        $devicesFound += [PSCustomObject]@{
            IP       = $currentIP
            HostName = $hostname
        }

        # Aggiungi l'IP alla lista degli IP attivi
        $activeIPs += $currentIP
    }
    $progressCount++
}

# Cancella la barra di progresso
Write-Progress -Activity "Scansione completata" -Completed

# Verifica se sono stati trovati dispositivi attivi
if ($devicesFound.Count -gt 0) {
    Write-Host "`n[*] Dispositivi attivi trovati sulla rete $networkPrefix.0/24:" -ForegroundColor Cyan

    # Visualizza i risultati in formato tabellare
    $devicesFound | Sort-Object IP | Format-Table -AutoSize
} else {
    Write-Host "[*] Nessun dispositivo attivo trovato sulla rete." -ForegroundColor Yellow
}

# Definisci le porte da scansionare (porte comuni)
$portsToScan = @(22, 80, 135, 139, 443, 445, 3389)

# Inizia la scansione delle porte sugli host attivi
Write-Host "`n[*] Inizio scansione delle porte sui dispositivi attivi..." -ForegroundColor Cyan

foreach ($device in $devicesFound) {
    $currentIP = $device.IP
    Write-Host "[*] Scansione delle porte su $currentIP ($($device.HostName))..."

    foreach ($port in $portsToScan) {
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            
            # Imposta il timeout di connessione
            $asyncResult = $tcpClient.BeginConnect($currentIP, $port, $null, $null)
            $waitSuccess = $asyncResult.AsyncWaitHandle.WaitOne(100, $false)  # Timeout di 100ms

            if ($waitSuccess -and $tcpClient.Connected) {
                Write-Host "[+] Porta $port aperta su $currentIP" -ForegroundColor Green
                
                # Salva il risultato della scansione delle porte
                $portScanResults += [PSCustomObject]@{
                    IP       = $currentIP
                    HostName = $device.HostName
                    Port     = $port
                }
                $tcpClient.EndConnect($asyncResult)
            }

            $tcpClient.Close()
        } catch {
            # Ignora eventuali errori di connessione
        }
    }
}

Write-Host "`n[+] Scansione delle porte completata!" -ForegroundColor Green

# Mostra i risultati della scansione delle porte
if ($portScanResults.Count -gt 0) {
    Write-Host "`n[*] Porte aperte trovate sui dispositivi:" -ForegroundColor Cyan
    $portScanResults | Sort-Object IP,Port | Format-Table -AutoSize
} else {
    Write-Host "[*] Nessuna porta aperta trovata sui dispositivi attivi." -ForegroundColor Yellow
}

# Evita che la finestra di PowerShell si chiuda immediatamente
Write-Host "`nPremi Invio per terminare lo script..."
[void][System.Console]::ReadLine()
