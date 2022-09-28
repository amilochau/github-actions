<#
  .SYNOPSIS
  This script builds and tests a .NET Core application
  .PARAMETER projectsToBuild
  The projects to build
  .PARAMETER projectsToTest
  The projects to test
  .PARAMETER verbosity
  The verbosity level
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [string]$projectsToBuild,

  [parameter(Mandatory = $true)]
  [string]$projectsToTest,
  
  [parameter(Mandatory = $true)]
  [ValidateSet('minimal', 'normal', 'detailed')]
  [string]$verbosity
)

Write-Output "Projects to build is: $projectsToBuild"
Write-Output "Projects to test is: $projectsToTest"
Write-Output "Verbosity is: $verbosity"

Write-Output '=========='
Write-Output 'Install packages...'
dotnet restore $projectsToBuild --verbosity $verbosity

Write-Output '=========='
Write-Output 'Build application...'
dotnet build $projectsToBuild --configuration Release --no-restore --verbosity $verbosity

Write-Output '=========='
Write-Output 'Run tests...'
dotnet test $projectsToTest --configuration Release --no-restore --no-build --verbosity $verbosity

Write-Output '=========='
Write-Output 'Publish application...'
dotnet publish $projectsToTest --configuration Release --runtime linux-x64 --no-self-contained --output ./output --verbosity $verbosity

Write-Output '=========='
