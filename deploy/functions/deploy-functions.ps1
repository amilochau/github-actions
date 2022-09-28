<#
  .SYNOPSIS
  This script deploys a Functions application
  .PARAMETER projectsToPublishPath
  The path of the projects to publish
  .PARAMETER resourceGroupName
  The resource group name
  .PARAMETER applicationName
  The application name
  .PARAMETER relativeHealthUrl
  The relative health URL
  .PARAMETER distSource
  The source of the dist files
  .PARAMETER verbosity
  The verbosity level
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [string]$projectsToPublishPath,

  [parameter(Mandatory = $true)]
  [string]$resourceGroupName,

  [parameter(Mandatory = $true)]
  [string]$applicationName,

  [parameter(Mandatory = $true)]
  [string]$relativeHealthUrl,
  
  [parameter(Mandatory = $true)]
  [string]$distSource,

  [parameter(Mandatory = $true)]
  [ValidateSet('minimal', 'normal', 'detailed')]
  [string]$verbosity
)

Function SynchronizeTriggers($resourceGroupName, $applicationType, $applicationName) {
  $retries = 3
  $retriesDelayInSeconds = 5

  $retrycount = 0
  $completed = $false

  while (-not $completed) {
    try {
      Invoke-AzResourceAction -ResourceGroupName $resourceGroupName -ResourceType $applicationType -ResourceName $applicationName -Action syncfunctiontriggers -Force -ErrorAction Stop  | Out-Null
      $completed = $true
    } catch {
      if ($retrycount -ge $retries) {
        Write-Verbose "Synchronize triggers failed after $retrycount times."
        throw
      } else {
        Write-Verbose "Synchronize triggers failed. Retrying in $retriesDelayInSeconds seconds."
        Start-Sleep $retriesDelayInSeconds
        $retrycount++
      }
    }
  }
}

Write-Output "Projects to publish path is: $projectsToPublishPath"
Write-Output "Resource group name is: $resourceGroupName"
Write-Output "Application name is: $applicationName"
Write-Output "Relative health URL is: $relativeHealthUrl"
Write-Output "Dist source is: $distSource"
Write-Output "Verbosity is: $verbosity"

Write-Output '=========='
Write-Output 'Moving into projects to publish path...'
Set-Location $projectsToPublishPath

Write-Output '=========='
Write-Output 'Publish application...'
dotnet publish --configuration Release --runtime linux-x64 --no-self-contained --output ./output --verbosity $verbosity

Write-Output '=========='
Write-Output 'Create deployment package...'
$currentDate = Get-Date -Format yyyyMMdd_HHmmss
$currentLocation = Get-Location
$fileName = "FunctionsApp_$currentDate.zip"
$filePath = "$currentLocation/$fileName"
[System.IO.Compression.ZipFile]::CreateFromDirectory("$currentLocation/output", $filePath)
Write-Output "Deployment package has been created ($filePath)."

Write-Output '=========='
Write-Output 'Get application information from application settings...'
$app = Get-AzFunctionApp -Name $applicationName -ResourceGroupName $resourceGroupName
$applicationType = $app.Type
$defaultHostName = $app.DefaultHostName
Write-Output "Application type: $applicationType"
Write-Output "Default host name: $defaultHostName"

$appSettings = Get-AzFunctionAppSetting -Name $applicationName -ResourceGroupName $resourceGroupName
$storageAccountName = $appSettings['AzureWebJobsStorage__accountName']
Write-Output "Storage account name: $storageAccountName"

Write-Output '=========='
Write-Output 'Upload package to blob storage...'
$containerName = 'deployment-packages'

New-AzStorageContext -StorageAccountName $storageAccountName | Set-AzStorageBlobContent `
  -Container $containerName `
  -Blob $fileName `
  -File $filePath ` | Out-Null

$blobUri = "https://$storageAccountName.blob.core.windows.net/$containerName/$fileName"
Write-Output "Deployment package has been uploaded to $blobUri."

Write-Output '=========='
Write-Output 'Update Functions appsettings with package reference...'
Update-AzFunctionAppSetting -Name $applicationName -ResourceGroupName $resourceGroupName -AppSetting @{"WEBSITE_RUN_FROM_PACKAGE" = $blobUri} | Out-Null

Write-Output '=========='
Write-Output 'Synchronize triggers...'
SynchronizeTriggers -resourceGroupName $resourceGroupName -applicationType $applicationType -applicationName $applicationName

Write-Output '=========='
Write-Output 'Check application health...'
$healthUrl = "https://$defaultHostName$relativeHealthUrl"
Write-Host "Using default health URL: $healthUrl"

Invoke-WebRequest $healthUrl -TimeoutSec 120 -MaximumRetryCount 12 -RetryIntervalSec 10

Write-Output 'Deployment is done.'

Write-Output '=========='
