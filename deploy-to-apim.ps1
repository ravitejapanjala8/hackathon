# PowerShell script to deploy API to Azure API Management
# This script uses Azure CLI to import the OpenAPI specification into APIM

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$ApimServiceName,
    
    [Parameter(Mandatory=$true)]
    [string]$ApiId,
    
    [Parameter(Mandatory=$false)]
    [string]$SwaggerFilePath = "swagger.yaml",
    
    [Parameter(Mandatory=$false)]
    [string]$ApiPath = "sample-api",
    
    [Parameter(Mandatory=$false)]
    [string]$ServiceUrl = "https://api.example.com"
)

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Azure APIM Deployment Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
Write-Host "Checking Azure CLI installation..." -ForegroundColor Yellow
try {
    $azVersion = az version --output json 2>$null | ConvertFrom-Json
    Write-Host "✓ Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor Green
} catch {
    Write-Host "✗ Azure CLI is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Azure CLI from: https://docs.microsoft.com/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Check if logged in to Azure
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
$account = az account show 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Not logged in to Azure" -ForegroundColor Red
    Write-Host "Please run: az login" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Logged in to Azure" -ForegroundColor Green

# Check if swagger file exists
Write-Host "Checking for OpenAPI specification file..." -ForegroundColor Yellow
if (-not (Test-Path $SwaggerFilePath)) {
    Write-Host "✗ Swagger file not found: $SwaggerFilePath" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Found OpenAPI specification: $SwaggerFilePath" -ForegroundColor Green

# Check if APIM service exists
Write-Host "Checking if APIM service exists..." -ForegroundColor Yellow
$apimExists = az apim show --name $ApimServiceName --resource-group $ResourceGroupName 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ APIM service '$ApimServiceName' not found in resource group '$ResourceGroupName'" -ForegroundColor Red
    Write-Host "Please create the APIM service first or check the service name and resource group" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ APIM service found: $ApimServiceName" -ForegroundColor Green

Write-Host ""
Write-Host "Deployment Configuration:" -ForegroundColor Cyan
Write-Host "  Resource Group: $ResourceGroupName"
Write-Host "  APIM Service: $ApimServiceName"
Write-Host "  API ID: $ApiId"
Write-Host "  API Path: $ApiPath"
Write-Host "  Service URL: $ServiceUrl"
Write-Host "  Swagger File: $SwaggerFilePath"
Write-Host ""

# Import API to APIM
Write-Host "Importing API to Azure APIM..." -ForegroundColor Yellow
Write-Host "This may take a few moments..." -ForegroundColor Gray

try {
    # Import the OpenAPI specification
    az apim api import `
        --resource-group $ResourceGroupName `
        --service-name $ApimServiceName `
        --api-id $ApiId `
        --path $ApiPath `
        --specification-path $SwaggerFilePath `
        --specification-format OpenApi `
        --service-url $ServiceUrl `
        --protocols https `
        --subscription-required false
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "=====================================" -ForegroundColor Green
        Write-Host "✓ API deployed successfully!" -ForegroundColor Green
        Write-Host "=====================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "API Details:" -ForegroundColor Cyan
        Write-Host "  API ID: $ApiId"
        Write-Host "  API Path: /$ApiPath"
        Write-Host "  Gateway URL: https://$ApimServiceName.azure-api.net/$ApiPath"
        Write-Host ""
        Write-Host "You can now access your API at:" -ForegroundColor Yellow
        Write-Host "  https://$ApimServiceName.azure-api.net/$ApiPath/api/health"
        Write-Host "  https://$ApimServiceName.azure-api.net/$ApiPath/api/users"
        Write-Host ""
    } else {
        Write-Host "✗ API deployment failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Error during API import: $_" -ForegroundColor Red
    exit 1
}

Write-Host "Deployment completed successfully!" -ForegroundColor Green
