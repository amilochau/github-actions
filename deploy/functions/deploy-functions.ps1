<#
  .SYNOPSIS
  The path to projects to publish
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

  [parameter(Mandatory = $true)]
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
Write-Output 'Get storage account name from application settings...'
$resourceGroupName = az functionapp list --query "[?name == '$applicationName'] | [].resourceGroup" | ConvertFrom-Json
$appSettings = az functionapp config appsettings list --name $applicationName --resource-group $resourceGroupName | ConvertFrom-Json
$storageAccountName = $appSettings | Where-Object { $_.name -eq "AzureWebJobsStorage__accountName" } | ForEach-Object { $_.value }
Write-Output "Resource group name: $resourceGroupName"
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
az functionapp restart --name $applicationName --resource-group $resourceGroupName | Out-Null

Write-Output '=========='
Write-Output 'Check application health...'
Invoke-WebRequest $healthUrl -TimeoutSec 120 -MaximumRetryCount 12 -RetryIntervalSec 10

Write-Output 'Deployment is done.'
