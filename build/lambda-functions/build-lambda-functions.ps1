<#
  .SYNOPSIS
  This script builds and tests Terraform modules
  .PARAMETER solutionPath
  The path to the solution file, with functions to deploy
  .PARAMETER verbosity
  The verbosity level
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [string]$solutionPath,
  
  [parameter(Mandatory = $true)]
  [ValidateSet('minimal', 'normal', 'detailed')]
  [string]$verbosity
)

Write-Output "Solution path is: $solutionPath"
Write-Output "Verbosity is: $verbosity"

Write-Output '=========='

$sw = [Diagnostics.Stopwatch]::StartNew()
$image = "public.ecr.aws/sam/build-dotnet7:latest-x86_64"
$dir = (Get-Location).Path

Write-Output "Pull Docker image, used to build functions"
docker pull $image -q

docker run --rm -v "$($dir):/src" -w /src $image dotnet publish "$solutionPath" -c Release -f net7.0 -r linux-x64 --sc true -p:BuildSource=AwsCmd /p:GenerateRuntimeConfigurationFiles=true /p:StripSymbols=true
if (!$?) {
  Write-Output "::error title=Build failed::Build failed"
  throw 1
}

Write-Output '=========='

$sw.Stop()
Write-Output "Job duration: $($sw.Elapsed.ToString("c"))"
