<#
  .SYNOPSIS
  This script deploys infrastructure on Azure
  .PARAMETER scope
  The deployment scope
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
  .PARAMETER templateFilePath
  OBSOLETE The path of the template file
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
  [string]$scope,

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

  [parameter(Mandatory = $false)]
  [string]$templateFilePath,

  [parameter(Mandatory = $false)]
  [ValidateSet('', 'configuration', 'functions', 'functions/api-registration', 'functions/local-dependencies', 'gateway', 'management-group', 'monitoring', 'static-web-apps')]
  [string]$templateType,

  [parameter(Mandatory = $true)]
  [string]$parametersFilePath,

  [parameter(Mandatory = $true)]
  [string]$templatesDirectory,

  [parameter(Mandatory = $true)]
  [string]$deploymentName
)

Write-Output "Scope is: $scope"
Write-Output "Resource group name is: $resourceGroupName"
Write-Output "Resource group location is: $resourceGroupLocation"
Write-Output "Subscription ID is: $subscriptionId"
Write-Output "Subscription location is: $subscriptionLocation"
Write-Output "Management group ID is: $managementGroupId"
Write-Output "Management group location is: $managementGroupLocation"
Write-Output "Template file path is: $templateFilePath"
Write-Output "Template type is: $templateType"
Write-Output "Parameters file path is: $parametersFilePath"
Write-Output "Templates directory path is: $templatesDirectory"
Write-Output "Deployment name is: $deploymentName"

Write-Output '=========='
Write-Host 'Define default subscription...'
if (($null -ne $subscriptionId) -and ($subscriptionId.Length -gt 0)) {
  Set-AzContext -Subscription $subscriptionId
  Write-Output "Default subscription set: $subscriptionId"
} elseif ($scope -eq 'subscription') {
  Write-Host 'No subscription ID found; we require it on a subscription scope, for security reasons.'
  throw 'A subscription ID must be set to deploy on a subscription scope.'
}

if (($null -ne $templateType) -and ($templateType.Length -gt 0)) {
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
      if (($null -eq $templateFilePath) -or ($templateFilePath.Length -eq 0)) {
        Write-Host 'No template reference can be found.'
        throw 'You should define a template reference; use "templateType" parameter.'
      }
    }
  }
}

$templateExtraParameters = @{}

if ($scope -eq 'resourceGroup') {
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
} elseif ($scope -eq 'subscription') {
  Write-Output 'SCOPE: SUBSCRIPTION'

  Write-Output '=========='
  Write-Output 'Deploy ARM template file...'
  $result = New-AzSubscriptionDeployment `
    -Name $deploymentName `
    -Location $managementGroupLocation `
    -TemplateFile $templateFilePath `
    -TemplateParameterFile $parametersFilePath `
    @templateExtraParameters

  Write-Output 'Deployment is now completed on subscription.'
} elseif ($scope -eq 'managementGroup') {
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
  Write-Host 'No scope found.'
  throw 'You must provide a scope.'
}

Write-Output '=========='
Write-Output 'Setting outputs...'

$resourceId = $result.Outputs.resourceId.Value
Write-Host "::set-output name=resourceId::$resourceId"
Write-Host "[Output] resourceId: $resourceId"

$resourceName = $result.Outputs.resourceName.Value
Write-Host "::set-output name=resourceName::$resourceName"
Write-Host "[Output] resourceName: $resourceName"
