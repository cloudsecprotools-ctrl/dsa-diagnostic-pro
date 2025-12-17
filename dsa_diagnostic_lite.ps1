<#
# |============================================================|
# | Lightweight Trend Micro DSA diagnostic (Lite) - Windows    |
# | Author: CloudSecProTools                                   |
# | Email: cloudsecprotools@gmail.com                          |
# | Version: 1.0.0                                             |
# |============================================================|
####################################################################################################
#                                     Render-String (Open-Source Components Only)                  #
#                                          Copyright (C) 2025 CloudSecProTools                     #
####################################################################################################
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software    #
# and associated documentation files (the “Software”), to deal in the Software without restriction,#
# including without limitation the rights to use, copy, modify, merge, publish, distribute,        #
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is    #
# furnished to do so, subject to the following conditions:                                         #
#                                                                                                  #
# The above copyright notice and this permission notice shall be included in all copies or         #
# substantial portions of the Software.                                                            #
#                                                                                                  #
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING    #
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND       #
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,     #
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.          #
####################################################################################################

####################################################################################################
#                                       Commercial / Full Version Notice                           #
# The complete version of Render-String, including advanced features and full functionality, is    #
# proprietary and not included in this MIT-licensed release.                                       #
#                                                                                                  #
# - The full version is not publicly shared or redistributable.                                    #
# - Access to the full version requires a paid commercial license.                                 #
# - No warranty, guarantee, or support is provided for either the commercial or open-source        #
#   portions unless explicitly stated in a written contract.                                       #
#                                                                                                  #
# Use of the full version without a valid commercial license is strictly prohibited.               #
####################################################################################################
#
.SYNOPSIS
  dsa_diagnostic_lite.ps1 - Lite Trend Micro DSA diagnostic (read-only)

.DESCRIPTION
  Collects basic Trend Micro Deep Security Agent information and logs for troubleshooting.
  Safe: no activation/uninstall or destructive actions.

.EXAMPLE
  PowerShell -ExecutionPolicy Bypass -File .\dsa_diagnostic_lite.ps1 -OutputDir "C:\Temp\dsa-lite"
#>

[CmdletBinding()]
param(
  [string]$OutputDir = "$(Join-Path -Path $env:TEMP -ChildPath ('dsa-diagnostic-lite-' + (Get-Date -Format yyyyMMdd-HHmmss)))",
  [int]$MaxZipMB = 200,
  [switch]$Quiet
)

function Write-Log {
  param($Message)
  if (-not $Quiet) { Write-Host $Message }
}

# Create output dir
if (-not (Test-Path -Path $OutputDir)) {
  New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}
Write-Log "Diagnostic output: $OutputDir"

# System info
Write-Log "Collecting system information..."
Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture, BuildNumber | Out-File (Join-Path $OutputDir "os_info.txt") -Encoding utf8
hostname | Out-File (Join-Path $OutputDir "hostname.txt") -Encoding utf8
systeminfo | Out-File (Join-Path $OutputDir "systeminfo.txt") -Encoding utf8

# Find Trend Micro diag folder (known location) and list files
$possibleDiag = "C:\ProgramData\Trend Micro\Deep Security Agent\diag"
if (Test-Path -Path $possibleDiag) {
  Write-Log "Found diag folder: $possibleDiag"
  Get-ChildItem -Path $possibleDiag -Recurse -File | Select-Object FullName, Length, LastWriteTime | Out-File (Join-Path $OutputDir "diag_files_list.txt")
  # Copy small files (avoid huge logs)
  $destLogs = Join-Path $OutputDir "diag_copy"
  New-Item -ItemType Directory -Path $destLogs -Force | Out-Null
  Get-ChildItem -Path $possibleDiag -File -Recurse | Where-Object { $_.Length -lt 10MB } | ForEach-Object {
    $rel = $_.FullName.Substring($possibleDiag.Length).TrimStart('\')
    $target = Join-Path $destLogs $rel
    New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
    Copy-Item -Path $_.FullName -Destination $target -Force
  }
} else {
  Write-Log "Diag folder not found at $possibleDiag. Searching for Trend Micro related folders..."
  Get-ChildItem -Path C:\ -Directory -ErrorAction SilentlyContinue -Recurse -Depth 2 | Where-Object { $_.Name -match "Trend|Deep|DSA|Deep Security" } | Select-Object FullName | Out-File (Join-Path $OutputDir "trend_dirs_search.txt")
}

# Services - find Trend/Deep Security/DSA services
Write-Log "Collecting services related to Trend/Deep Security..."
Get-Service | Where-Object { $_.DisplayName -match "Trend|Deep" -or $_.Name -match "dsa|ds_agent|deep" } | Select-Object Name, DisplayName, Status | Out-File (Join-Path $OutputDir "trend_services.txt")

# Processes
Write-Log "Collecting process list..."
Get-Process | Where-Object { $_.ProcessName -match "trend|deep|dsa|ds_agent" } | Select-Object ProcessName, Id, CPU, WS | Out-File (Join-Path $OutputDir "trend_processes.txt")

# Event logs - Application & System filtered for Trend/Deep
Write-Log "Collecting recent event logs containing Trend/Deep..."
Get-WinEvent -LogName Application -MaxEvents 500 | Where-Object { $_.Message -match "Trend|Deep|DSA" } | Select-Object TimeCreated, Id, LevelDisplayName, Message | Out-File (Join-Path $OutputDir "event_application_trend.txt")
Get-WinEvent -LogName System -MaxEvents 500 | Where-Object { $_.Message -match "Trend|Deep|DSA" } | Select-Object TimeCreated, Id, LevelDisplayName, Message | Out-File (Join-Path $OutputDir "event_system_trend.txt")

# Check for dsa_control utility
$dsaControl = (Get-Command dsa_control -ErrorAction SilentlyContinue).Source
if ($null -ne $dsaControl) {
  Write-Log "dsa_control found at $dsaControl. NOTE: dsa_control -d can generate diag files; not executed by Lite script."
  "$dsaControl" | Out-File (Join-Path $OutputDir "dsa_control_path.txt")
} else {
  Write-Log "dsa_control not found in PATH. Will not run diag generation."
}

# Check local port 4118
Write-Log "Checking local connectivity to port 4118..."
try {
  $tcp = New-Object Net.Sockets.TcpClient
  $async = $tcp.BeginConnect("127.0.0.1", 4118, $null, $null)
  $wait = $async.AsyncWaitHandle.WaitOne(1500)
  if ($wait -and $tcp.Connected) {
    "Port 4118: open" | Out-File (Join-Path $OutputDir "port4118_check.txt")
    $tcp.Close()
  } else {
    "Port 4118: closed or not responding" | Out-File (Join-Path $OutputDir "port4118_check.txt")
  }
} catch {
  "Port 4118: check failed - $_" | Out-File (Join-Path $OutputDir "port4118_check.txt")
}

# Save disk summary
Get-PSDrive -PSProvider FileSystem | Select-Object Name, Used, Free, @{Name='UsedGB';Expression={[math]::Round(($_.Used/1GB),2)}}, @{Name='FreeGB';Expression={[math]::Round(($_.Free/1GB),2)}} | Out-File (Join-Path $OutputDir "disk_summary.txt")

# Package the output (zip)
Write-Log "Creating zip archive of diagnostic output..."
$zipPath = "${OutputDir}.zip"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($OutputDir, $zipPath)
$sizeMB = [math]::Round((Get-Item $zipPath).Length/1MB,2)
Write-Log "Archive created: $zipPath (${sizeMB} MB)"
if ($sizeMB -gt $MaxZipMB) {
  Write-Log "Warning: Archive exceeds configured MaxZipMB ($MaxZipMB)."
}

Write-Log "Lite diagnostic complete. Inspect files in $OutputDir and the archive $zipPath."
Write-Log "To run deeper diagnostics (ODS tests, DSM checks, advanced logs), upgrade to the Pro tool."
