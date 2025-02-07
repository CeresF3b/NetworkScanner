This PowerShell script scans the local network to identify active devices and open ports. It performs the following tasks:

Retrieve Local IP Address: Uses ipconfig to get the local IP address and extracts the IPv4 address.
Split IP Address into Octets: Divides the IP address into octets to determine the network prefix.
Initialize Variables: Sets up arrays for found devices, active IPs, and port scan results.
Scan Hosts on the Network: Checks the range of possible host addresses (1-254) for active devices using Test-Connection.
Display Active Devices: Lists the active devices found on the network.
Scan Ports on Active Devices: Checks common ports (22, 80, 135, 139, 443, 445, 3389) on each active device.
Display Open Ports: Lists the open ports found on the active devices.
Prevent Script from Closing Immediately: Waits for user input before closing the PowerShell window.
Usage
Run the script in PowerShell with administrative privileges. It will scan the local network for active devices and open ports, displaying the results in the console.
