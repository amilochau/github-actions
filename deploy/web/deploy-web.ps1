<#
  .SYNOPSIS
  This script deploys a Web application from a Docker image
  .PARAMETER dockerRegistryHost
  The host of the Docker registry - with a leading slash
  .PARAMETER dockerImageName
  The name of the Docker image
  .PARAMETER dockerImageTag
  The tag of the Docker image
  .PARAMETER resourceGroupName
  The resource group name
  .PARAMETER applicationName
  The application name
  .PARAMETER relativeHealthUrl
  The relative health URL
  .PARAMETER verbosity
  The verbosity level
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [string]$dockerRegistryHost,

  [parameter(Mandatory = $true)]
  [string]$dockerImageName,

  [parameter(Mandatory = $true)]
  [string]$dockerImageTag,

  [parameter(Mandatory = $true)]
  [string]$resourceGroupName,

  [parameter(Mandatory = $true)]
  [string]$applicationName,

  [parameter(Mandatory = $true)]
  [string]$relativeHealthUrl,
  
  [parameter(Mandatory = $true)]
  [ValidateSet('minimal', 'normal', 'detailed')]
  [string]$verbosity
)

Write-Output "Docker registry host is: $dockerRegistryHost"
Write-Output "Docker image name is: $dockerImageName"
Write-Output "Docker image tag is: $dockerImageTag"
Write-Output "Resource group name is: $resourceGroupName"
Write-Output "Application name is: $applicationName"
Write-Output "Relative health URL is: $relativeHealthUrl"
Write-Output "Verbosity is: $verbosity"

Write-Output '=========='
Write-Output 'Set local variables...'
$dockerImageReference = "$($dockerRegistryHost)$($dockerImageName):$($dockerImageTag)"
Write-Output "Docker image reference: $dockerImageReference"

Write-Output '=========='
Write-Output 'Get application information from application settings...'
$app = Get-AzWebApp -Name $applicationName -ResourceGroupName $resourceGroupName
$defaultHostName = $app.DefaultHostName
Write-Output "Default host name: $defaultHostName"

Write-Output '=========='
Write-Output 'Update application container image reference...'
Set-AzWebApp -Name $applicationName -ResourceGroupName $resourceGroupName -ContainerImageName $dockerImageReference | Out-Null

Write-Output '=========='
Write-Output 'Check application health...'
$healthUrl = "https://$defaultHostName$relativeHealthUrl"
Write-Host "Using default health URL: $healthUrl"

Invoke-WebRequest $healthUrl -TimeoutSec 120 -MaximumRetryCount 12 -RetryIntervalSec 10

Write-Output 'Deployment is done.'

Write-Output '=========='
