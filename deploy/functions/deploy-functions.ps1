<#
  .SYNOPSIS
  This script deploys a Functions application
  .PARAMETER verbosity
  The verbosity level
  .PARAMETER applicationName
  The application name
  .PARAMETER healthUrl
  The health URL
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [string]$verbosity,

  [parameter(Mandatory = $true)]
  [string]$applicationName,

  [parameter(Mandatory = $false)]
  [string]$healthUrl
)

Write-Output "Verbosity is: $verbosity"
Write-Output "Application name is: $applicationName"
Write-Output "Health URL is: $healthUrl"

Write-Output '=========='
Write-Output 'Publish application...'
dotnet publish --configuration Release --output ./output --verbosity $verbosity

Write-Output '=========='
Write-Output 'Create deployment package...'
$currentDate = Get-Date -Format yyyyMMdd_HHmmss
$fileName = "FunctionsApp_$currentDate.zip"
[System.IO.Compression.ZipFile]::CreateFromDirectory('./output', $fileName)
Write-Output "Deployment package has been created ($fileName)."

Write-Output '=========='
Write-Output 'Get application information from application settings...'
$app = az functionapp list --query "[?name == '$applicationName']" | ConvertFrom-Json
$appSettings = az functionapp config appsettings list --name $applicationName --resource-group $resourceGroupName | ConvertFrom-Json

$resourceGroupName = $app.resourceGroup
$applicationType = $app.type
$defaultHostName = $app.defaultHostName
Write-Output "Resource group name: $resourceGroupName"
Write-Output "Application type: $applicationType"
Write-Output "Default host name: $defaultHostName"

$storageAccountName = $appSettings | Where-Object { $_.name -eq "AzureWebJobsStorage__accountName" } | ForEach-Object { $_.value }
Write-Output "Storage account name: $storageAccountName"

Write-Output '=========='
Write-Output 'Upload package to blob storage...'
$containerName = 'deployment-packages'
az storage blob upload `
  --account-name $storageAccountName `
  --container-name $containerName `
  --name $fileName `
  --file $fileName `
  --auth-mode login `
  --no-progress | Out-Null

$blobUri = "https://$storageAccountName.blob.core.windows.net/$containerName/$fileName"
Write-Output "Deployment package has been updated to $blobUri."

Write-Output '=========='
Write-Output 'Update Functions appsettings with package reference...'
az functionapp config appsettings set --name $applicationName --resource-group $resourceGroupName --settings "WEBSITE_RUN_FROM_PACKAGE=$blobUri" | Out-Null

Write-Output '=========='
Write-Output 'Synchronize triggers...'
az resource invoke-action --resource-group $resourceGroupName --action syncfunctiontriggers --name $applicationName --resource-type $applicationType

Write-Output '=========='
Write-Output 'Check application health...'

if (($null -ne $healthUrl) -and ($healthUrl.Length -gt 0)) {
  Write-Host "Using configured health URL: $healthUrl"
} else {
  $healthUrl="https://$defaultHostName/api/health"
  Write-Host "Using default health URL: $healthUrl"
}

Invoke-WebRequest $healthUrl -TimeoutSec 120 -MaximumRetryCount 12 -RetryIntervalSec 10

Write-Output 'Deployment is done.'
