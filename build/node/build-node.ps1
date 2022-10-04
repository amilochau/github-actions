<#
  .SYNOPSIS
  This script builds and tests a Node.js application
  .PARAMETER npmBuildScript
  The npm script to build
  .PARAMETER npmLintScript
  The npm script to lint
  .PARAMETER npmTestScript
  The npm script to test
  .PARAMETER relativeOutputPath
  The path of the built application
  .PARAMETER verbosity
  The verbosity level
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [string]$npmBuildScript,
  
  [parameter(Mandatory = $true)]
  [string]$npmLintScript,
  
  [parameter(Mandatory = $true)]
  [string]$npmTestScript,

  [parameter(Mandatory = $true)]
  [string]$relativeOutputPath,
  
  [parameter(Mandatory = $true)]
  [ValidateSet('minimal', 'normal', 'detailed')]
  [string]$verbosity
)

Write-Output "npm build script is: $npmBuildScript"
Write-Output "npm lint script is: $npmLintScript"
Write-Output "npm test script is: $npmTestScript"
Write-Output "Relative output path is: $relativeOutputPath"
Write-Output "Verbosity is: $verbosity"

Write-Output '=========='
Write-Output 'Install packages...'
npm ci

Write-Output '=========='
Write-Output 'Build application...'
npm run $npmBuildScript

Write-Output '=========='
Write-Output 'Run linter...'
npm run $npmLintScript --if-present

Write-Output '=========='
Write-Output 'Run tests...'
npm run $npmTestScript --if-present

Write-Output '=========='
Write-Output 'Create compressed artifact...'
$compressedFilePath = './output-compressed/app.zip'
New-Item -Path "./output-compressed" -ItemType Directory
[System.IO.Compression.ZipFile]::CreateFromDirectory(".$relativeOutputPath", $compressedFilePath) | Out-Null

Write-Output '=========='
