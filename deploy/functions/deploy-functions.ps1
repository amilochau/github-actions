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
$app = Get-AzFunctionApp | Where-Object { $_.Name -eq $applicationName } # Would be easier to get with resource group @next-major-version
$resourceGroupName = $app.ResourceGroupName
$applicationType = $app.Type
$defaultHostName = $app.DefaultHostName
Write-Output "Resource group name: $resourceGroupName"
Write-Output "Application type: $applicationType"
Write-Output "Default host name: $defaultHostName"

$appSettings = Get-AzFunctionAppSetting -Name $applicationName -ResourceGroupName $resourceGroupName
$storageAccountName = $appSettings | Where-Object { $_.Name -eq "AzureWebJobsStorage__accountName" } | ForEach-Object { $_.Value }
Write-Output "Storage account name: $storageAccountName"

Write-Output '=========='
Write-Output 'Upload package to blob storage...'
$containerName = 'deployment-packages'

New-AzStorageContext -StorageAccountName $storageAccountName | Set-AzStorageBlobContent `
  -Container $containerName `
  -Blob $fileName `
  -File $fileName ` | Out-Null

$blobUri = "https://$storageAccountName.blob.core.windows.net/$containerName/$fileName"
Write-Output "Deployment package has been uploaded to $blobUri."

Write-Output '=========='
Write-Output 'Update Functions appsettings with package reference...'
Update-AzFunctionAppSetting -Name $applicationName -ResourceGroupName $resourceGroupName -AppSetting @{"WEBSITE_RUN_FROM_PACKAGE" = $blobUri} | Out-Null

Write-Output '=========='
Write-Output 'Synchronize triggers...'
Invoke-AzureRmResourceAction -ResourceGroupName $resourceGroupName -ResourceType $applicationType -ResourceName $applicationName -Action syncfunctiontriggers | Out-Null

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
