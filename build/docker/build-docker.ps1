<#
  .SYNOPSIS
  This script builds a Docker application
  .PARAMETER context
  The path of the context where to build
  .PARAMETER dockerfile
  The path of the Dockerfile
  .PARAMETER dockerRegistryHost
  The host of the Docker registry - with a leading slash
  .PARAMETER dockerRegistryUsername
  The username to login to Docker registry
  .PARAMETER dockerRegistryPassword
  The password to login to Docker registry
  .PARAMETER dockerImageName
  The name of the Docker image
  .PARAMETER dockerImageTag
  The tag of the Docker image
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [string]$context,

  [parameter(Mandatory = $true)]
  [string]$dockerfile,

  [parameter(Mandatory = $true)]
  [string]
  $dockerRegistryHost,

  [parameter(Mandatory = $true)]
  [string]
  $dockerRegistryUsername,

  [parameter(Mandatory = $true)]
  [string]
  $dockerRegistryPassword,

  [parameter(Mandatory = $true)]
  [string]
  $dockerImageName,

  [parameter(Mandatory = $true)]
  [string]
  $dockerImageTag
)

Write-Output "Context is: $context"
Write-Output "Docker file is: $dockerfile"
Write-Output "Docker registry host is: $dockerRegistryHost"
Write-Output "Docker image name is: $dockerImageName"
Write-Output "Docker image tag is: $dockerImageTag"

Write-Output '=========='
Write-Output 'Set local variables...'
$dockerImageReference = "$($dockerRegistryHost)$($dockerImageName):$($dockerImageTag)"
Write-Output "Docker image reference: $dockerImageReference"

Write-Output '=========='
Write-Output 'Building Docker image...'
docker build $context --file $dockerfile --tag $dockerImageReference

Write-Output '=========='
Write-Output 'Loging to Container Registry...'
docker login $dockerRegistryHost --username $dockerRegistryUsername --password $dockerRegistryPassword

Write-Output '=========='
Write-Output 'Pushing to Container Registry...'
docker push $dockerImageReference

Write-Output '=========='
