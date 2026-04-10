# ============================================================================
# VM Initialization Script - Phase 1 (Quick setup)
# ============================================================================
# This script runs on VM creation to:
# - Install Chocolatey
# - Install Git
# - Clone repository
# - Register Phase 2 script as scheduled task
# - Reboot

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

# Create Logs directory if it doesn't exist
$logsDir = 'C:\Logs'
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
}

$logFile = 'C:\Logs\initialize-vm.log'

# Logging function
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp - $Message" | Out-File -FilePath $logFile -Append -Encoding UTF8
    Write-Host $Message
}

Write-Log "Starting VM initialization (Phase 1)..."

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
# Install Chocolatey
# ============================================================================
try {
    Write-Log "Checking for Chocolatey..."
    $chocoPath = 'C:\ProgramData\chocolatey\choco.exe'
    
    if (-not (Test-Path $chocoPath)) {
        Write-Log "Installing Chocolatey..."
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Log "Chocolatey installation completed"
    } else {
        Write-Log "Chocolatey is already installed"
    }
}
catch {
    Write-Log "Warning: Chocolatey installation encountered an issue: $_"
}

# ============================================================================
# Install Git
# ============================================================================
try {
    Write-Log "Installing Git for Windows (latest)..."
    & 'C:\ProgramData\chocolatey\choco.exe' install git -y --no-progress 2>&1 | Out-File -FilePath $logFile -Append -Encoding UTF8
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
    & 'C:\Program Files\Git\cmd\git.exe' clone https://github.com/JoelQuimper/presentations-and-labs.git 'C:\repos\presentations-and-labs' 2>&1 | Tee-Object -FilePath $logFile -Append
    Write-Log "Repository cloned to C:\repos\presentations-and-labs"
}
catch {
    Write-Log "Error cloning repository: $_"
}

# ============================================================================
# Register Phase 2 Script as Scheduled Task
# ============================================================================
try {
    Write-Log "Registering Phase 2 installation task..."
    
    $scriptPath = 'C:\repos\presentations-and-labs\Labs\Fabric\Database\infra\vm-config\install-development-tools.ps1'
    $taskName = 'Install-Development-Tools'
    $taskDescription = 'Phase 2: Install SSMS (scheduled to run 30 seconds after Phase 1)'
    
    # Create scheduled task action
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Unrestricted -File `"$scriptPath`""
    
    # Create scheduled task trigger (run once, 30 seconds from now)
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(30)
    
    # Create scheduled task principal (run as SYSTEM with highest privileges)
    $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest
    
    # Register the scheduled task
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Description $taskDescription -Force | Out-Null
    
    Write-Log "Scheduled task '$taskName' registered successfully"
}
catch {
    Write-Log "Error registering scheduled task: $_"
}

Write-Log "Phase 1 initialization completed"
Write-Log "VM will execute Phase 2 installation (SSMS) in approximately 30 seconds"
Write-Log "Initialization log saved to $logFile"

# ============================================================================
# Phase 1 Complete - Phase 2 will run shortly
# ============================================================================
Write-Log "Phase 1 script execution finished"
