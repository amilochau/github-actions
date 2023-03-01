<#
  .SYNOPSIS
  This script builds and tests Terraform modules
  .PARAMETER functionsPath
  The path to the functions to deploy
  .PARAMETER functionsPathFilter
  The path filter to find the functions to deploy
  .PARAMETER verbosity
  The verbosity level
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [string]$functionsPath,

  [parameter(Mandatory = $true)]
  [string]$functionsPathFilter,
  
  [parameter(Mandatory = $true)]
  [ValidateSet('minimal', 'normal', 'detailed')]
  [string]$verbosity
)

Write-Output "Functions path is: $functionsPath"
Write-Output "Functions path filter is: $functionsPathFilter"
Write-Output "Verbosity is: $verbosity"

Write-Output '=========='

$sw = [Diagnostics.Stopwatch]::StartNew()
$image = "public.ecr.aws/sam/build-dotnet7:latest-x86_64"
$dir = (Get-Location).Path

$childItems = Get-ChildItem -Path $functionsPath -Recurse -Filter $functionsPathFilter
$childItemsCount = $childItems.Length
Write-Output "Items found: $childItemsCount"

$childItems | Foreach-Object -ThrottleLimit 5 -Parallel {
  $directoryAbsolutePath = $PSItem.Directory.FullName
  $directoryRelativePath = $PSItem.Directory.FullName | Resolve-Path -Relative
  Write-Output "[$directoryRelativePath] Starting..."
  Set-Location $directoryAbsolutePath

  $fileAbsolutePath = $PSItem.FullName

  if (Test-Path "$directoryAbsolutePath/obj") {
    Remove-Item -LiteralPath "$directoryAbsolutePath/obj" -Force -Recurse
  }
  if (Test-Path "$directoryAbsolutePath/bin") {
    Remove-Item -LiteralPath "$directoryAbsolutePath/bin" -Force -Recurse
  }
  if (Test-Path "$directoryAbsolutePath/dist") {
    Remove-Item -LiteralPath "$directoryAbsolutePath/dist" -Force -Recurse
  }

  docker run --rm -v "$($using:dir):/src" -w /src $using:image dotnet publish "$fileAbsolutePath" -c Release -f net7.0 -r linux-x64 --sc true -p:BuildSource=AwsCmd /p:GenerateRuntimeConfigurationFiles=true /p:StripSymbols=true
  Write-Output "[$directoryRelativePath] Done."
}

Write-Output '=========='

$sw.Stop()
Write-Output "Job duration: $($sw.Elapsed.ToString("c"))"
