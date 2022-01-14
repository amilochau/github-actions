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
  The path of the template file
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

  [parameter(Mandatory = $true)]
  [string]$templateFilePath,

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
Write-Output "Parameters file path is: $parametersFilePath"
Write-Output "Templates directory path is: $templatesDirectory"
Write-Output "Deployment name is: $deploymentName"

Write-Output '=========='
Write-Host 'Define default subscription...'
if (($null -ne $subscriptionId) -and ($subscriptionId.Length -gt 0)) {
  az account set --subscription $subscriptionId
  Write-Output "Default subscription set: $subscriptionId"
} elseif ($scope -eq 'subscription') {
  Write-Host 'No subscription ID found; we require it on a subscription scope, for security reasons.'
  throw 'A subscription ID must be set to deploy on a subscription scope.'
}

if ($scope -eq 'resourceGroup') {
  Write-Output 'SCOPE: RESOURCE GROUP'

  Write-Output '=========='
  Write-Output 'Create Resource Group...'
  if ((az group exists --name $resourceGroupName) -eq 'false') {
    Write-Output 'Creating the resource group...'
    az group create `
      --name $resourceGroupName `
      --location $resourceGroupLocation
      Write-Output 'Resource group has been be created.'
  }

  Write-Output '=========='
  Write-Output 'Detach Static Web Apps...'
  az staticwebapp list --resource-group $resourceGroupName | ConvertFrom-Json | ForEach-Object {
    $staticWebAppName = $_.name
    Write-Output "Disconnecting application:$staticWebAppName..."
    az staticwebapp disconnect --name $staticWebAppName
    Write-Output 'Application has been disconnected.'
  }

  Write-Output '=========='
  Write-Output 'Determine template version...'
  $scriptLocation = Get-Location
  Set-Location $templatesDirectory
  $templateVersion=$(git describe --tags --match v*.*.*)
  Write-Output "Template version is $templateVersion"
  Set-Location $scriptLocation

  Write-Output '=========='
  Write-Output 'Deploy ARM template file...'
  $result = az deployment group create `
    --name $deploymentName `
    --resource-group $resourceGroupName `
    --template-file $templateFilePath `
    --parameters $parametersFilePath `
    --parameters templateVersion=$templateVersion `
    --no-prompt

  Write-Output 'Deployment is now completed on resource group.'

} elseif ($scope -eq 'subscription') {
  Write-Output 'SCOPE: SUBSCRIPTION'

  Write-Output '=========='
  Write-Output 'Deploy ARM template file...'
  $result = az deployment sub create `
    --name $deploymentName `
    --location $subscriptionLocation `
    --template-file $templateFilePath `
    --parameters $parametersFilePath `
    --no-prompt

    Write-Output 'Deployment is now completed on subscription.'
} elseif ($scope -eq 'managementGroup') {
  Write-Output 'SCOPE: MANAGEMENT GROUP'
  
  Write-Output '=========='
  Write-Output 'Deploy ARM template file...'
  $result = az deployment mg create `
    --name $deploymentName `
    --management-group-id $managementGroupId `
    --location $managementGroupLocation `
    --template-file $templateFilePath `
    --parameters $parametersFilePath `
    --no-prompt

    Write-Output 'Deployment is now completed on management group.'
} else {
  Write-Host 'No scope found.'
  throw 'You must provide a scope.'
}

Write-Output '=========='
Write-Output 'Setting outputs...'
$resultAsJson = $result | ConvertFrom-Json

$resourceId = $resultAsJson.properties.outputs.resourceId.value
Write-Host "::set-output name=resourceId::$resourceId"
Write-Host "[Output] resourceId: $resourceId"

$resourceName = $resultAsJson.properties.outputs.resourceName.value
Write-Host "::set-output name=resourceName::$resourceName"
Write-Host "[Output] resourceName: $resourceName"
