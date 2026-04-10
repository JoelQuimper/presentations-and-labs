# ============================================================================
# VM Development Tools Installation Script - Phase 2 (Long-running setup)
# ============================================================================
# This script runs on VM reboot (via scheduled task) to install:
# - SQL Server Management Studio (SSMS)
# - Visual Studio Community Edition
#
# Note: This script is scheduled as a task to run at startup after Phase 1 completes

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

# Logging function
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp - $Message" | Out-File -FilePath 'C:\install-development-tools.log' -Append -Encoding UTF8
    Write-Host $Message
}

Write-Log "Starting development tools installation (Phase 2)..."

# ============================================================================
# Log Execution Context for Debugging
# ============================================================================
Write-Log "=== Execution Context ==="
Write-Log "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Log "Current User: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
Write-Log "Is Administrator: $(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))"
Write-Log "Current Directory: $(Get-Location)"
Write-Log "Execution Policy (Process): $(Get-ExecutionPolicy -Scope Process)"
Write-Log "Execution Policy (LocalMachine): $(Get-ExecutionPolicy -Scope LocalMachine)"
Write-Log "OS: $([System.Runtime.InteropServices.RuntimeInformation]::OSDescription)"
Write-Log "=== End Context ==="

# ============================================================================
# Verify Chocolatey is Available
# ============================================================================
try {
    Write-Log "Checking for Chocolatey..."
    $chocoPath = 'C:\ProgramData\chocolatey\choco.exe'
    
    if (-not (Test-Path $chocoPath)) {
        Write-Log "Installing Chocolatey..."
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Log "Chocolatey installation completed"
    } else {
        Write-Log "Chocolatey is available"
    }
}
catch {
    Write-Log "Warning: Chocolatey check encountered an issue: $_"
}

# ============================================================================
# Install SQL Server Management Studio (SSMS)
# ============================================================================
try {
    Write-Log "Installing SQL Server Management Studio (SSMS)..."
    Write-Log "This may take 5-10 minutes..."
    & 'C:\ProgramData\chocolatey\choco.exe' install ssms -y --no-progress 2>&1 | Tee-Object -FilePath 'C:\install-development-tools.log' -Append
    Write-Log "SSMS installation completed successfully"
}
catch {
    Write-Log "Error installing SSMS: $_"
}

# ============================================================================
# Install Visual Studio Community Edition
# ============================================================================
try {
    Write-Log "Installing Visual Studio Community Edition..."
    Write-Log "This may take 15-25 minutes and will require significant disk space..."
    & 'C:\ProgramData\chocolatey\choco.exe' install visualstudio2022community -y --no-progress 2>&1 | Tee-Object -FilePath 'C:\install-development-tools.log' -Append
    Write-Log "Visual Studio installation completed successfully"
}
catch {
    Write-Log "Error installing Visual Studio: $_"
}

# ============================================================================
# Installation Complete
# ============================================================================
Write-Log "Phase 2 development tools installation completed"
Write-Log "Installation log saved to C:\install-development-tools.log"
Write-Log "You can now use SSMS and Visual Studio on this VM"

# ============================================================================
# Remove Scheduled Task (Optional - clean up after successful execution)
# ============================================================================
try {
    Write-Log "Removing scheduled task 'Install-Development-Tools'..."
    Unregister-ScheduledTask -TaskName 'Install-Development-Tools' -Confirm:$false -ErrorAction SilentlyContinue
    Write-Log "Scheduled task removed"
}
catch {
    Write-Log "Note: Could not remove scheduled task: $_"
}

Write-Log "Phase 2 script execution finished"
