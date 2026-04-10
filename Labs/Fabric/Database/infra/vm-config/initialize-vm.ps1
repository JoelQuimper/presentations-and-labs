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

# Logging function
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp - $Message" | Out-File -FilePath 'C:\initialize-vm.log' -Append -Encoding UTF8
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
# Install Git
# ============================================================================
try {
    Write-Log "Installing Git for Windows (latest)..."
    & 'C:\ProgramData\chocolatey\choco.exe' install git -y --no-progress 2>&1 | Tee-Object -FilePath 'C:\initialize-vm.log' -Append
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
    & 'C:\Program Files\Git\cmd\git.exe' clone https://github.com/JoelQuimper/presentations-and-labs.git 'C:\repos\presentations-and-labs' 2>&1 | Tee-Object -FilePath 'C:\initialize-vm.log' -Append
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
    $taskDescription = 'Phase 2: Install SSMS and Visual Studio on VM reboot'
    
    # Create scheduled task action
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Unrestricted -File `"$scriptPath`""
    
    # Create scheduled task trigger (on system boot)
    $trigger = New-ScheduledTaskTrigger -AtStartup
    
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
Write-Log "VM will reboot to start Phase 2 installation (SSMS and Visual Studio)"
Write-Log "Initialization log saved to C:\initialize-vm.log"

# ============================================================================
# Reboot VM
# ============================================================================
Write-Log "Rebooting VM in 10 seconds..."
Start-Sleep -Seconds 10
Restart-Computer -Force
