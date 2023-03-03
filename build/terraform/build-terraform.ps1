<#
  .SYNOPSIS
  This script builds and tests Terraform modules
  .PARAMETER modulesPath
  The path to the Terraform modules to build
  .PARAMETER modulesPathDepth
  The depth of the path search, to find the Terraform modules to build
  .PARAMETER verbosity
  The verbosity level
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [string]$modulesPath,
  
  [parameter(Mandatory = $true)]
  [int]$modulesPathDepth,
  
  [parameter(Mandatory = $true)]
  [ValidateSet('minimal', 'normal', 'detailed')]
  [string]$verbosity
)

Write-Output "Modules path is: $modulesPath"
Write-Output "Modules path depth is: $modulesPathDepth"
Write-Output "Verbosity is: $verbosity"

Write-Output '=========='

$sw = [Diagnostics.Stopwatch]::StartNew()
$pathFilter = 'main.tf'
$childItems = Get-ChildItem -Path $modulesPath -Recurse -Depth $modulesPathDepth -Filter $pathFilter -Force
$childItemsCount = $childItems.Length
Write-Output "Items found: $childItemsCount"

$childItems | Foreach-Object -ThrottleLimit 5 -Parallel {
  #Action that will run in Parallel. Reference the current object via $PSItem and bring in outside variables with $USING:varname
  $directoryAbsolutePath = $PSItem.Directory.FullName
  $directoryRelativePath = $PSItem.Directory.FullName | Resolve-Path -Relative
  Write-Output "[$directoryRelativePath] Starting..."
  Set-Location $directoryAbsolutePath

  Write-Output "[$directoryRelativePath] Terraform initialisation..."
  terraform init -input=false -backend=false -upgrade -no-color 2>&1
  if (!$?) {
    Write-Output "::error title=Terraform failed::Terraform initialization failed"
    throw 1
  }
  
  Write-Output "[$directoryRelativePath] Terraform format..."
  terraform fmt -check -recursive -no-color 2>&1
  if (!$?) {
    Write-Output "::error title=Terraform failed::Terraform format failed"
    throw 1
  }

  Write-Output "[$directoryRelativePath] Terraform validation..."
  terraform validate -no-color 2>&1
  if (!$?) {
    Write-Output "::error title=Terraform failed::Terraform validation failed"
    throw 1
  }
}

Write-Output '=========='

$sw.Stop()
Write-Output "Job duration: $($sw.Elapsed.ToString("c"))"
