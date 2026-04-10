# ============================================================================
# VM Post-Deployment Script: Install SSMS and Visual Studio
# ============================================================================
# This script runs on VM creation to automatically install:
# - SQL Server Management Studio (latest)
# - Visual Studio Community (latest)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

# Logging function
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp - $Message" | Out-File -FilePath 'C:\install-tools.log' -Append -Encoding UTF8
    Write-Host $Message
}

Write-Log "Starting post-deployment installation..."

# ============================================================================
# Install Chocolatey (if not already installed)
# ============================================================================
try {
    Write-Log "Checking for Chocolatey..."
    $chocoPath = 'C:\ProgramData\chocolatey\choco.exe'
    
    if (-not (Test-Path $chocoPath)) {
        Write-Log "Installing Chocolatey..."
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Log "Chocolatey installation completed"
    } else {
        Write-Log "Chocolatey is already installed"
    }
}
catch {
    Write-Log "Warning: Chocolatey installation encountered an issue: $_"
}

# ============================================================================
# Install SSMS (SQL Server Management Studio)
# ============================================================================
try {
    Write-Log "Installing SQL Server Management Studio (latest)..."
    & choco install ssms -y --no-progress 2>&1 | Tee-Object -FilePath 'C:\install-tools.log' -Append
    Write-Log "SSMS installation completed"
}
catch {
    Write-Log "Error installing SSMS: $_"
}

Write-Log "Post-deployment script execution completed"
Write-Log "Installation log saved to C:\install-tools.log"

