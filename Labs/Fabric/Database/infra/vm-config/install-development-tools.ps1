# ============================================================================
# VM Development Tools Installation Script - Phase 2 (Long-running setup)
# ============================================================================
# This script runs on VM reboot (via scheduled task) to install:
# - SQL Server Management Studio (SSMS)
#
# Note: This script is scheduled as a task to run at startup after Phase 1 completes

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

# Create Logs directory if it doesn't exist
$logsDir = 'C:\Logs'
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
}

$logFile = 'C:\Logs\install-development-tools.log'

# Logging function
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp - $Message" | Out-File -FilePath $logFile -Append -Encoding UTF8
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
# Validate Chocolatey is Available
# ============================================================================
Write-Log "Validating Chocolatey is available..."
$chocoPath = 'C:\ProgramData\chocolatey\choco.exe'

if (-not (Test-Path $chocoPath)) {
    Write-Log "ERROR: Chocolatey is not installed. Phase 1 (initialize-vm.ps1) should have installed it."
    throw "Chocolatey not found at $chocoPath - Phase 1 initialization may have failed"
}
Write-Log "Chocolatey is available"

# ============================================================================
# Validate Repository is Cloned
# ============================================================================
Write-Log "Validating repository is cloned..."
$repoPath = 'C:\repos\presentations-and-labs'

if (-not (Test-Path $repoPath)) {
    Write-Log "ERROR: Repository not found at $repoPath. Phase 1 (initialize-vm.ps1) should have cloned it."
    throw "Repository not found at $repoPath - Phase 1 initialization may have failed"
}
Write-Log "Repository is available at $repoPath"

# ============================================================================
# Install SQL Server Management Studio (SSMS)
# ============================================================================
try {
    Write-Log "Installing SQL Server Management Studio (SSMS)..."
    Write-Log "This may take 5-10 minutes..."
    & 'C:\ProgramData\chocolatey\choco.exe' install ssms -y --no-progress 2>&1 | Tee-Object -FilePath $logFile -Append
    Write-Log "SSMS installation completed successfully"
}
catch {
    Write-Log "Error installing SSMS: $_"
}

# ============================================================================
# Installation Complete
# ============================================================================
Write-Log "Phase 2 development tools installation completed"
Write-Log "Installation log saved to $logFile"
Write-Log "You can now use SSMS on this VM"

Write-Log "Phase 2 script execution finished"
