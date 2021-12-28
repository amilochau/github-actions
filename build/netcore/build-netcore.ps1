<#
  .SYNOPSIS
  This script build and tests a .NET Core application
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
  [string]$verbosity
)

Write-Output '=========='
Write-Output 'Install packages...'
run: dotnet restore $projectsToBuild --verbosity $verbosity
 
Write-Output '=========='
Write-Output 'Build application...'
run: dotnet build $projectsToBuild --configuration Release --no-restore --verbosity $verbosity

Write-Output '=========='
Write-Output 'Run tests...'
run: dotnet test $projectsToTest --configuration Release --no-restore --no-build --verbosity $verbosity

Write-Output '=========='
