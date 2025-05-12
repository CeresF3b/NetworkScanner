# 🔍 Network Scanner

[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## 📋 Description

This is a network scanner that allows you to identify active devices on your local network and check which common ports are open on these devices.

## ✨ Features

- 🖥️ **Device Discovery**: Automatically finds all active devices on your local network
- 🚪 **Port Scanning**: Checks for common open ports (SSH, HTTP, RPC, NetBIOS, HTTPS, SMB, RDP)
- 📊 **Clean Visualization**: Displays results in an easy-to-read table format
- 🔄 **Progress Tracking**: Shows real-time scanning progress

## 🚀 How to Use

### Remote Execution (Recommended)

Run this command in PowerShell to download and execute the script directly in memory:

```powershell
irm https://raw.githubusercontent.com/CeresF3b/NetworkScanner/main/Scanner.ps1 | iex
```
### Local Execution

Alternatively, you can:

1. Download the script
2. Run it in PowerShell with administrative privileges
3. The script will automatically detect your network and start scanning
4. View the list of discovered devices
5. Examine open ports on each active device

## 📋 Requirements

- Windows operating system
- PowerShell 5.1 or higher
- Administrative privileges (for complete network scanning)

## ⚠️ Notes

- Run the script with administrative privileges for optimal results
- The scan is designed for home networks or small business networks
- The script has been optimized for remote execution via `irm | iex`
- Always ensure you have permission before scanning any network

## 📜 License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0). See the LICENSE file for details.
