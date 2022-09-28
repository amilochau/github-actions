<#
  .SYNOPSIS
  This script deploys a Static Web application
  .PARAMETER projectsToPublishPath
  The path of the projects to publish
  .PARAMETER resourceGroupName
  The resource group name
  .PARAMETER applicationName
  The application name
  .PARAMETER npmBuildScript
  The npm script to build
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
  [string]$npmBuildScript,
  
  [parameter(Mandatory = $true)]
  [ValidateSet('minimal', 'normal', 'detailed')]
  [string]$verbosity
)

Write-Output "Projects to publish path is: $projectsToPublishPath"
Write-Output "Resource group name is: $resourceGroupName"
Write-Output "Application name is: $applicationName"
Write-Output "npm build script is: $npmBuildScript"
Write-Output "Verbosity is: $verbosity"

Write-Output '=========='
Write-Output 'Moving into projects to publish path...'
Set-Location $projectsToPublishPath

Write-Output '=========='
Write-Output 'Install npm packages...'
npm ci

Write-Output '=========='
Write-Output 'Build application...'
npm run $npmBuildScript

Write-Output '=========='
Write-Output 'Detach Static Web Apps application'
Remove-AzStaticWebAppAttachedRepository -ResourceGroupName $resourceGroupName -Name $applicationName

Write-Output '=========='
Write-Output 'Determine Static Web Apps deployment token'
$swaSecrets = Get-AzStaticWebAppSecret -ResourceGroupName $resourceGroupName -Name $applicationName
$token = $swaSecrets.Property['apiKey']
Write-Output "::set-output name=token::$token"
Write-Output "Deployment token found ($($token.Length) characters)."

Write-Output '=========='
