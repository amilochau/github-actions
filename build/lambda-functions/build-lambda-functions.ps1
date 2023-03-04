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

Write-Output "Pull Docker image, used to build functions"
docker pull $image -q

$solutionPath = './src/maps-api/Milochau.Maps.sln'
docker run --rm -v "$($dir):/src" -w /src $image dotnet publish "$solutionPath" -c Release -f net7.0 -r linux-x64 --sc true -p:BuildSource=AwsCmd /p:GenerateRuntimeConfigurationFiles=true /p:StripSymbols=true
if (!$?) {
  Write-Output "::error title=Build failed::Build failed"
  throw 1
}


#$childItems = Get-ChildItem -Path $functionsPath -Recurse -Filter $functionsPathFilter
#$childItemsCount = $childItems.Length
#Write-Output "Items found: $childItemsCount"
#
#$childItems | Foreach-Object -ThrottleLimit 5 -Parallel {
#  $directoryAbsolutePath = $PSItem.Directory.FullName
#  $directoryRelativePath = $PSItem.Directory.FullName | Resolve-Path -Relative
#  $fileRelativePath = $PSItem.FullName | Resolve-Path -Relative
#  Write-Output "[$directoryRelativePath] Starting..."
#  Set-Location $directoryAbsolutePath
#
#  if (Test-Path "$directoryAbsolutePath/obj") {
#    Remove-Item -LiteralPath "$directoryAbsolutePath/obj" -Force -Recurse
#  }
#  if (Test-Path "$directoryAbsolutePath/bin") {
#    Remove-Item -LiteralPath "$directoryAbsolutePath/bin" -Force -Recurse
#  }
#  if (Test-Path "$directoryAbsolutePath/dist") {
#    Remove-Item -LiteralPath "$directoryAbsolutePath/dist" -Force -Recurse
#  }
#
#  docker run --rm -v "$($using:dir):/src" -w /src $using:image dotnet publish "$fileRelativePath" -c Release -f net7.0 -r linux-x64 --sc true -p:BuildSource=AwsCmd /p:GenerateRuntimeConfigurationFiles=true /p:StripSymbols=true
#  if (!$?) {
#    Write-Output "::error title=Build failed::Build failed"
#    throw 1
#  }
#  
#  Write-Output "[$directoryRelativePath] Done."
#}

Write-Output '=========='

$sw.Stop()
Write-Output "Job duration: $($sw.Elapsed.ToString("c"))"
