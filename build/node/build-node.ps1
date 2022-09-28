<#
  .SYNOPSIS
  This script builds and tests a Node.js application
  .PARAMETER npmBuildScript
  The npm script to build
  .PARAMETER npmLintScript
  The npm script to lint
  .PARAMETER verbosity
  The verbosity level
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [string]$npmBuildScript,
  
  [parameter(Mandatory = $false)]
  [string]$npmLintScript,
  
  [parameter(Mandatory = $true)]
  [ValidateSet('minimal', 'normal', 'detailed')]
  [string]$verbosity
)

Write-Output "npm build script is: $npmBuildScript"
Write-Output "npm lint script is: $npmLintScript"
Write-Output "Verbosity is: $verbosity"

Write-Output '=========='
Write-Output 'Install packages...'
npm ci

Write-Output '=========='
Write-Output 'Build application...'
npm run $npmBuildScript

Write-Output '=========='
Write-Output 'Run linter...'
if ($npmLintScript) {
  npm run $npmLintScript
}

Write-Output '=========='
Write-Output 'Run tests...'
npm test --if-present

Write-Output '=========='
