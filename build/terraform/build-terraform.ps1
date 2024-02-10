<#
  .SYNOPSIS
  This script builds and tests Terraform modules
  .PARAMETER modulesPathDepth
  The depth of the path search, to find the Terraform modules to build
  .PARAMETER workspaceName
  The name of the Terraform workspace
  .PARAMETER verbosity
  The verbosity level
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [int]$modulesPathDepth,

  [parameter(Mandatory = $false)]
  [string]$workspaceName,
  
  [parameter(Mandatory = $true)]
  [ValidateSet('quiet', 'minimal', 'normal', 'detailed', 'diagnostic')]
  [string]$verbosity
)

Write-Output "Modules path depth is: $modulesPathDepth"
Write-Output "Workspace name is: $workspaceName"
Write-Output "Verbosity is: $verbosity"

Write-Output '=========='

$sw = [Diagnostics.Stopwatch]::StartNew()
$pathFilter = 'main.tf'
$childItems = Get-ChildItem -Recurse -Depth $modulesPathDepth -Filter $pathFilter -Force
$childItemsCount = $childItems.Count
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
  
if (-not ([string]::IsNullOrWhiteSpace($workspaceName))) {   
  Write-Output "Terraform initialisation..."
  terraform init -input=false -upgrade -no-color 2>&1
  if (!$?) {
    Write-Output "::error title=Terraform failed::Terraform initialization failed"
    throw 1
  }
  
  Write-Output "Terraform workspace selection..."
  terraform workspace select -or-create $workspaceName -no-color 2>&1
  if (!$?) {
    Write-Output "::error title=Terraform failed::Terraform workspace selection failed"
    throw 1
  }

  Write-Output "Terraform plan..."
  $planResult = terraform plan -var-file="hosts/$workspaceName.tfvars" -input=false -no-color -lock=false 2>&1
  if (!$?) {
    Write-Output $planResult
    Write-Output "::error title=Terraform failed::Terraform plan failed"
    throw 1
  }
  
  Write-Output $planResult
} else {
  Write-Output "No workspace defined: no plan performed."
}

Write-Output '=========='

$sw.Stop()
Write-Output "Job duration: $($sw.Elapsed.ToString("c"))"
