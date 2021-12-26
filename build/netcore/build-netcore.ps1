<#
  .SYNOPSIS
  This script build and tests a .NET Core application
#>

Write-Output '=========='
Write-Output 'Install packages...'
run: dotnet restore ${{ inputs.projectsToBuild }} --verbosity ${{ inputs.verbosity }}
 
Write-Output '=========='
Write-Output 'Build application...'
run: dotnet build ${{ inputs.projectsToBuild }} --configuration Release --no-restore --verbosity ${{ inputs.verbosity }}

Write-Output '=========='
Write-Output 'Run tests...'
run: dotnet test ${{ inputs.projectsToTest }} --configuration Release --no-restore --no-build --verbosity ${{ inputs.verbosity }}

Write-Output '=========='
