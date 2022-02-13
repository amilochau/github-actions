<#
  .SYNOPSIS
  This script deploys infrastructure on Azure
  .PARAMETER scopeType
  The deployment scope type
  .PARAMETER resourceGroupName
  The name of the resource group
  .PARAMETER resourceGroupLocation
  The location of the resource group
  .PARAMETER subscriptionId
  The ID of the subscription
  .PARAMETER subscriptionLocation
  The location of the subscription
  .PARAMETER managementGroupId
  The ID of the management group
  .PARAMETER managementGroupLocation
  The location of the management group
  .PARAMETER templateType
  The type of Azure templates to use
  .PARAMETER parametersFilePath
  The path of the parameters file
  .PARAMETER templatesDirectory
  The directory of the ARM templates
  .PARAMETER deploymentName
  The name of the deployment
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [ValidateSet('resourceGroup', 'subscription', 'managementGroup')]
  [string]$scopeType,

  [parameter(Mandatory = $false)]
  [string]$resourceGroupName,

  [parameter(Mandatory = $false)]
  [string]$resourceGroupLocation,

  [parameter(Mandatory = $false)]
  [string]$subscriptionId,

  [parameter(Mandatory = $false)]
  [string]$subscriptionLocation,

  [parameter(Mandatory = $false)]
  [string]$managementGroupId,

  [parameter(Mandatory = $false)]
  [string]$managementGroupLocation,

  [parameter(Mandatory = $true)]
  [ValidateSet('configuration', 'functions', 'functions/api-registration', 'functions/local-dependencies', 'gateway', 'management-group', 'monitoring', 'static-web-apps')]
  [string]$templateType,

  [parameter(Mandatory = $true)]
  [string]$parametersFilePath,

  [parameter(Mandatory = $true)]
  [string]$templatesDirectory,

  [parameter(Mandatory = $true)]
  [string]$deploymentName
)

Write-Output "Scope type is: $scopeType"
Write-Output "Resource group name is: $resourceGroupName"
Write-Output "Resource group location is: $resourceGroupLocation"
Write-Output "Subscription ID is: $subscriptionId"
Write-Output "Subscription location is: $subscriptionLocation"
Write-Output "Management group ID is: $managementGroupId"
Write-Output "Management group location is: $managementGroupLocation"
Write-Output "Template type is: $templateType"
Write-Output "Parameters file path is: $parametersFilePath"
Write-Output "Templates directory path is: $templatesDirectory"
Write-Output "Deployment name is: $deploymentName"

Write-Output '=========='
Write-Host 'Define default subscription...'
if (($null -ne $subscriptionId) -and ($subscriptionId.Length -gt 0)) {
  Set-AzContext -Subscription $subscriptionId
  Write-Output "Default subscription set: $subscriptionId"
} elseif ($scopeType -eq 'subscription') {
  Write-Host 'No subscription ID found; we require it on a subscription scope, for security reasons.'
  throw 'A subscription ID must be set to deploy on a subscription scope.'
}

switch ($templateType) {
  'configuration' { $templateFilePath = './templates/configuration/template.bicep' }
  'functions' { $templateFilePath = './templates/functions/template.bicep' }
  'functions' { $templateFilePath = './templates/functions/template.bicep' }
  'functions/api-registration' { $templateFilePath = './templates/functions/api-registration.bicep' }
  'functions/local-dependencies' { $templateFilePath = './templates/functions/local-dependencies.bicep' }
  'gateway' { $templateFilePath = './templates/gateway/template.bicep' }
  'management-group' { $templateFilePath = './templates/functions/template.bicep' }
  'monitoring' { $templateFilePath = './templates/monitoring/template.bicep' }
  'static-web-apps' { $templateFilePath = './templates/static-web-apps/template.bicep' }
  default {
    Write-Warning 'No template type is defined.'
    throw 'You should define a template reference; use "templateType" parameter.'
  }
}

$templateExtraParameters = @{}

if ($scopeType -eq 'resourceGroup') {
  Write-Output 'SCOPE: RESOURCE GROUP'

  Write-Output '=========='
  Write-Output 'Create Resource Group...'
  if (!(Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue)) {
    Write-Output 'Creating the resource group...'
    New-AzResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
    Write-Output 'Resource group has been be created.'
  }

  Write-Output '=========='
  Write-Output 'Detach Static Web Apps...'
  if ($templateType -eq 'static-web-apps') {
    Write-Host 'Static Web Apps should be detached before upgrading infrastucture.'
    # @last-major-version only detach static web apps here
  }

  $staticWebApp = Get-AzStaticWebApp -ResourceGroupName $resourceGroupName
  if (!!$staticWebApp) {
    $staticWebAppName = $staticWebApp.Name
    Write-Output "Disconnecting application: $staticWebAppName..."
    Remove-AzStaticWebAppAttachedRepository -ResourceGroupName $resourceGroupName -Name $staticWebAppName
    Write-Output 'Application has been disconnected.'
  }

  Write-Output '=========='
  Write-Output 'Get Functions application settings...'
  if ($templateType -eq 'functions') {
    $app = Get-AzFunctionApp -ResourceGroupName $resourceGroupName
    if (!!$app) {
      $applicationName = $app.Name
      Write-Output "Application name: $applicationName"
      $appSettings = Get-AzFunctionAppSetting -Name $applicationName -ResourceGroupName $resourceGroupName
  
      $applicationPackageUri = $appSettings['WEBSITE_RUN_FROM_PACKAGE']
      if (($null -ne $applicationPackageUri) -and ($applicationPackageUri.Length -gt 0)) {
        $templateExtraParameters.Add('applicationPackageUri', $applicationPackageUri)
        Write-Output "Application package URI found ($($applicationPackageUri.Length) characters)."
      } else {
        Write-Output "Application package URI not found."
      }
    }
  }

  Write-Output '=========='
  Write-Output 'Determine template version...'
  $scriptLocation = Get-Location
  Set-Location $templatesDirectory
  $templateVersion=$(git describe --tags --match v*.*.*)
  $templateExtraParameters.Add('templateVersion', $templateVersion)
  Write-Output "Template version is $templateVersion"
  Set-Location $scriptLocation

  Write-Output '=========='
  Write-Output 'Deploy ARM template file...'
  $result = New-AzResourceGroupDeployment `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile $templateFilePath `
    -TemplateParameterFile $parametersFilePath `
    @templateExtraParameters

  Write-Output 'Deployment is now completed on resource group.'
} elseif ($scopeType -eq 'subscription') {
  Write-Output 'SCOPE: SUBSCRIPTION'

  Write-Output '=========='
  Write-Output 'Deploy ARM template file...'
  $result = New-AzSubscriptionDeployment `
    -Name $deploymentName `
    -Location $subscriptionLocation `
    -TemplateFile $templateFilePath `
    -TemplateParameterFile $parametersFilePath `
    @templateExtraParameters

  Write-Output 'Deployment is now completed on subscription.'
} elseif ($scopeType -eq 'managementGroup') {
  Write-Output 'SCOPE: MANAGEMENT GROUP'
  
  Write-Output '=========='
  Write-Output 'Deploy ARM template file...'
  $result = New-AzManagementGroupDeployment `
    -Name $deploymentName `
    -ManagementGroupId $managementGroupId `
    -Location $managementGroupLocation `
    -TemplateFile $templateFilePath `
    -TemplateParameterFile $parametersFilePath `
    @templateExtraParameters

  Write-Output 'Deployment is now completed on management group.'
} else {
  Write-Host 'No scope type found.'
  throw 'You must provide a scope type.'
}

Write-Output '=========='
Write-Output 'Setting outputs...'

$resourceId = $result.Outputs.resourceId.Value
Write-Host "::set-output name=resourceId::$resourceId"
Write-Host "[Output] resourceId: $resourceId"

$resourceName = $result.Outputs.resourceName.Value
Write-Host "::set-output name=resourceName::$resourceName"
Write-Host "[Output] resourceName: $resourceName"
