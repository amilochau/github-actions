<#
  .SYNOPSIS
  This script deploys infrastructure on Azure
  .PARAMETER templateType
  The type of Azure templates to use
  .PARAMETER scopeType
  The deployment scope type
  .PARAMETER scopeLocation
  The deployment scope location (Azure region)
  .PARAMETER resourceGroupName
  The name of the resource group
  .PARAMETER subscriptionId
  The ID of the subscription
  .PARAMETER managementGroupId
  The ID of the management group
  .PARAMETER parametersFilePath
  The path of the parameters file
  .PARAMETER templatesDirectory
  The directory of the ARM templates
  .PARAMETER deploymentName
  The name of the deployment
  .PARAMETER forceDeployment
  Force deployment if the last template used is the same as the current one
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [ValidateSet('configuration', 'functions', 'functions/api-registration', 'functions/local-dependencies', 'gateway', 'management-group', 'monitoring', 'static-web-apps')]
  [string]$templateType,

  [parameter(Mandatory = $true)]
  [ValidateSet('resourceGroup', 'subscription', 'managementGroup')]
  [string]$scopeType,

  [parameter(Mandatory = $true)]
  [string]$scopeLocation,

  [parameter(Mandatory = $false)]
  [string]$resourceGroupName,

  [parameter(Mandatory = $false)]
  [string]$subscriptionId,

  [parameter(Mandatory = $false)]
  [string]$managementGroupId,

  [parameter(Mandatory = $true)]
  [string]$parametersFilePath,

  [parameter(Mandatory = $true)]
  [string]$templatesDirectory,

  [parameter(Mandatory = $true)]
  [string]$deploymentName,

  [parameter(Mandatory = $true)]
  [string]$forceDeployment
)

Write-Output "Template type is: $templateType"
Write-Output "Scope type is: $scopeType"
Write-Output "Scope location is: $scopeLocation"
Write-Output "Resource group name is: $resourceGroupName"
Write-Output "Subscription ID is: $subscriptionId"
Write-Output "Management group ID is: $managementGroupId"
Write-Output "Parameters file path is: $parametersFilePath"
Write-Output "Templates directory path is: $templatesDirectory"
Write-Output "Deployment name is: $deploymentName"

$forceDeployment = [System.Convert]::ToBoolean($forceDeployment)
Write-Output "Force deployment is: $forceDeployment"


Write-Output '=========='
Write-Host 'Define default subscription...'
if ($subscriptionId) {
  Set-AzContext -Subscription $subscriptionId
  Write-Output "Default subscription set: $subscriptionId"
} elseif ($scopeType -eq 'subscription') {
  Write-Host 'No subscription ID found; we require it on a subscription scope, for security reasons.'
  throw 'A subscription ID must be set to deploy on a subscription scope.'
}

switch ($templateType) {
  'configuration' { $templateFilePath = './templates/configuration/template.bicep' }
  'functions' { $templateFilePath = './templates/functions/template.bicep' }
  'functions/api-registration' { $templateFilePath = './templates/functions/api-registration.bicep' }
  'functions/local-dependencies' { $templateFilePath = './templates/functions/local-dependencies.bicep' }
  'gateway' { $templateFilePath = './templates/gateway/template.bicep' }
  'management-group' { $templateFilePath = './templates/management-group/template.bicep' }
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
  $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
  if (!($resourceGroup)) {
    Write-Output 'Creating the resource group...'
    New-AzResourceGroup -Name $resourceGroupName -Location $scopeLocation
    Write-Output 'Resource group has been be created.'
  }

  Write-Output '=========='
  Write-Output 'Determine template version to use...'
  $scriptLocation = Get-Location
  Set-Location $templatesDirectory
  $templateVersion=$(git describe --tags --match v*.*.*)
  $templateExtraParameters.Add('templateVersion', $templateVersion)
  Write-Output "Template version is $templateVersion"
  Set-Location $scriptLocation

  Write-Output '=========='
  Write-Output 'Determine last template version used...'
  if (!$resourceGroup.Tags) {
    Write-Output "No tag found in resource group '$resourceGroup.Name'"
  } else {
    $lastTemplateVersion = $resourceGroup.Tags['templateVersion']
    Write-Output "Last template version is $lastTemplateVersion"
  
    if ($templateVersion -eq $lastTemplateVersion) {
      Write-Output "Template has already been deployed."
      if ($forceDeployment -eq $true) {
        Write-Output "Force deployment is enabled, deployment will continue."
      } else {
        Write-Output "Force deployment is disabled, deployment will resume."
        return
      }
    }
  }

  Write-Output '=========='
  Write-Output 'Detach Static Web Apps...'
  if ($templateType -eq 'static-web-apps' -or $templateType -eq 'functions') {
    Write-Host 'Static Web Apps should be detached before upgrading infrastucture.'
    # @last-major-version only detach static web apps here
    
    $staticWebApp = Get-AzStaticWebApp -ResourceGroupName $resourceGroupName
    if (!!$staticWebApp) {
      $staticWebAppName = $staticWebApp.Name
      Write-Output "Disconnecting application: $staticWebAppName..."
      Remove-AzStaticWebAppAttachedRepository -ResourceGroupName $resourceGroupName -Name $staticWebAppName
      Write-Output 'Application has been disconnected.'
    }
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
      if ($applicationPackageUri) {
        $templateExtraParameters.Add('applicationPackageUri', $applicationPackageUri)
        Write-Output "Application package URI found ($($applicationPackageUri.Length) characters)."
      } else {
        Write-Output "Application package URI not found."
      }
    }
  }

  Write-Output '=========='
  Write-Output 'Deploy ARM template file...'
  $result = New-AzResourceGroupDeployment `
    -Name $deploymentName `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile $templateFilePath `
    -TemplateParameterFile $parametersFilePath `
    @templateExtraParameters

  Write-Output 'Deployment is now completed on resource group.'

  Write-Output 'Post-deployment steps...'

  Write-Output '=========='
  Write-Output 'Enable HTTPS for CDN custom domains...'
  if ($templateType -eq 'functions' -or $templateType -eq 'functions/local-dependencies') {
    Write-Host 'Functions (template and local dependencies) template must enable HTTPS for CDN custom domains.'
    $cdnProfiles = Get-AzCdnProfile -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
    if (!!$cdnProfiles) {
      Write-Output "CDN profiles found ($($cdnProfiles.Length) profiles)."
      $customDomainHttpsParameter = New-AzCdnManagedHttpsParametersObject -CertificateSourceParameterCertificateType Dedicated -CertificateSource Cdn -ProtocolType ServerNameIndication -MinimumTlsVersion TLS12
      foreach ($cdnProfile in $cdnProfiles) {
        $cdnProfileName = $cdnProfile.Name
        $cdnEndpoints = Get-AzCdnEndpoint -ResourceGroupName $resourceGroupName -ProfileName $cdnProfileName -ErrorAction SilentlyContinue
        if (!!$cdnEndpoints) {
          Write-Output "CDN endpoints found ($($cdnEndpoints.Length) endpoints) for CDN profile '$cdnProfileName'."
          foreach ($cdnEndpoint in $cdnEndpoints) {
            $cdnEndpointName = $cdnEndpoint.Name
            $customDomains = Get-AzCdnCustomDomain -ResourceGroupName $resourceGroupName -ProfileName $cdnProfileName -EndpointName $cdnEndpointName -ErrorAction SilentlyContinue
            if (!!$customDomains) {
              Write-Output "CDN custom domains found ($($customDomains.Length) endpoints) for CDN endpoint '$cdnEndpointName'."
              foreach ($customDomain in $customDomains) {
                $customDomainName = $customDomain.Name
                $customDomainHttpsProvisioningState = $customDomain.CustomHttpsProvisioningState
                if ($customDomainHttpsProvisioningState -eq 'Disabled') {
                  Write-Output "HTTPS is disabled for CDN custom domains '$customDomainName', it will now be enabled."
                  Enable-AzCdnCustomDomainCustomHttps -ResourceGroupName $resourceGroupName -ProfileName $cdnProfileName -EndpointName $cdnEndpointName -CustomDomainName $customDomainName -CustomDomainHttpsParameter $customDomainHttpsParameter -ErrorAction SilentlyContinue
                }
              }
            } else {
              Write-Output "No custom domain found for CDN endpoint '$cdnEndpointName'."
            }
          }
        } else {
          Write-Output "No CDN profile found for CDN profile '$cdnProfileName'."
        }
      }
    } else {
      Write-Output "No CDN profile found."
    }
  }

  Write-Output 'Post-deployment steps done.'
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
    -Location $scopeLocation `
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
