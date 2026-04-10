# K12 Fabric Lab Infrastructure - Quick Deployment Script (PowerShell)
# Usage: .\deploy.ps1

param(
    [string]$Location = "canadacentral",
    [string]$DeploymentName = "k12lab-deployment"
)

Write-Host ""
Write-Host "K12 Fabric Lab Infrastructure Deployment"
Write-Host "=============================================="
Write-Host ""
Write-Host "Configuration:"
Write-Host "  Location: $Location"
Write-Host "  Deployment: $DeploymentName"
Write-Host ""
Write-Host "This may take 10-15 minutes..."
Write-Host ""

try {
    az deployment sub create `
        --name $DeploymentName `
        --template-file main.bicep `
        --parameters main.bicepparam `
        --location $Location
    
    Write-Host ""
    Write-Host "Deployment completed successfully!"
    Write-Host ""
    Write-Host "Deployment Outputs:"
    Write-Host "========================"
    
    az deployment sub show `
        --name $DeploymentName `
        --query 'properties.outputs' `
        --output table
} catch {
    Write-Host "Deployment failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Infrastructure Ready!"
Write-Host "========================"
Write-Host ""