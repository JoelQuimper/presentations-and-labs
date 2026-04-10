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
# Log Execution Context for Debugging
# ============================================================================
Write-Log "=== Execution Context ==="
Write-Log "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Log "Current User: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
Write-Log "Is Administrator: $(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))"
Write-Log "Current Directory: $(Get-Location)"
Write-Log "Execution Policy (Process): $(Get-ExecutionPolicy -Scope Process)"
Write-Log "Execution Policy (CurrentUser): $(Get-ExecutionPolicy -Scope CurrentUser)"
Write-Log "Execution Policy (LocalMachine): $(Get-ExecutionPolicy -Scope LocalMachine)"
Write-Log "OS: $([System.Runtime.InteropServices.RuntimeInformation]::OSDescription)"
Write-Log "=== End Context ==="
try {
    Write-Log "Checking for Chocolatey..."
    $chocoPath = 'C:\ProgramData\chocolatey\choco.exe'
    
    if (-not (Test-Path $chocoPath)) {
        Write-Log "Installing Chocolatey..."
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
    & 'C:\ProgramData\chocolatey\choco.exe' install ssms -y --no-progress 2>&1 | Tee-Object -FilePath 'C:\install-tools.log' -Append
    Write-Log "SSMS installation completed"
}
catch {
    Write-Log "Error installing SSMS: $_"
}

# ============================================================================
# Install Git
# ============================================================================
try {
    Write-Log "Installing Git for Windows (latest)..."
    & 'C:\ProgramData\chocolatey\choco.exe' install git -y --no-progress 2>&1 | Tee-Object -FilePath 'C:\install-tools.log' -Append
    Write-Log "Git installation completed"
}
catch {
    Write-Log "Error installing Git: $_"
}

# ============================================================================
# Clone Repository
# ============================================================================
try {
    Write-Log "Cloning presentations-and-labs repository..."
    & 'C:\Program Files\Git\cmd\git.exe' clone https://github.com/JoelQuimper/presentations-and-labs.git 'C:\repos\presentations-and-labs' 2>&1 | Tee-Object -FilePath 'C:\install-tools.log' -Append
    Write-Log "Repository cloned to C:\repos\presentations-and-labs"
}
catch {
    Write-Log "Error cloning repository: $_"
}

Write-Log "Post-deployment script execution completed"
Write-Log "Installation log saved to C:\install-tools.log"

