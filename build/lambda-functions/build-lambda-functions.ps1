<#
  .SYNOPSIS
  This script builds and tests Terraform modules
  .PARAMETER solutionPath
  The path to the solution file, with functions to deploy
  .PARAMETER publishPathFilter
  The path of the files to publish, as a filter to be tested to determine the files to add in the artifact
  .PARAMETER verbosity
  The verbosity level
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [string]$solutionPath, # Typically './src/proto-api/Milochau.Proto.Functions.sln'

  [parameter(Mandatory = $true)]
  [string]$publishPathFilter, # Typically '*/bin/Release/net8.0/linux-x64/publish/bootstrap'
  
  [parameter(Mandatory = $true)]
  [ValidateSet('quiet', 'minimal', 'normal', 'detailed', 'diagnostic')]
  [string]$verbosity
)

Write-Output "Solution path is: $solutionPath"
Write-Output "Publish path filter is: $publishPathFilter"
Write-Output "Verbosity is: $verbosity"
Write-Output "Token is: $($env:GH_TOKEN)"

Write-Output '=========='

$sw = [Diagnostics.Stopwatch]::StartNew()
$image = "public.ecr.aws/sam/build-dotnet8:latest-x86_64"
$dir = (Get-Location).Path

Write-Output "Pull Docker image, used to build functions"
docker pull $image -q

docker run --rm -v "$($dir):/src" -w /src $image dotnet publish "$solutionPath" -c Release -r linux-x64 --sc true -p:BuildSource=AwsCmd
if (!$?) {
  Write-Output "::error title=Build failed::Build failed"
  throw 1
}

Write-Output '=========='

Write-Output "Finding the files to publish in the artifact..."

$publishPathFilterLinux = $publishPathFilter.Replace("\", "/")
$publishPathFilterWindows = $publishPathFilter.Replace("/", "\")
$solutionDirectoryPath = (Get-ChildItem $solutionPath).Directory.FullName
$childItems = Get-ChildItem -Path $solutionDirectoryPath -Recurse -Include 'bootstrap'

if (Test-Path "./output") {
  Remove-Item -LiteralPath "./output" -Force -Recurse
}
if (Test-Path "./output-compressed") {
  Remove-Item -LiteralPath "./output-compressed" -Force -Recurse
}
New-Item -Path "./output" -ItemType Directory | Out-Null
New-Item -Path "./output-compressed" -ItemType Directory | Out-Null

Write-Output '=========='

$childItemsCount = $childItems.Count
Write-Output "Items found: $childItemsCount"

$childItems | Foreach-Object -Parallel {
  $childItem = $PSItem
  $directoryRelativePath = $childItem.Directory.FullName | Resolve-Path -Relative
  $fileRelativePath = $childItem.FullName | Resolve-Path -Relative

  if ($fileRelativePath -inotlike $using:publishPathFilterLinux -and $fileRelativePath -inotlike $using:publishPathFilterWindows) {
    Write-Output "[$fileRelativePath] Not treated."
  } else {
    Write-Output "[$fileRelativePath] Copying file to output..."
    $directoryDestinationPath = Join-Path "$PWD/output" "$directoryRelativePath"
    $destinationPath = Join-Path $directoryDestinationPath $childItem.Name
    if (-not (Test-Path $directoryDestinationPath)) {
      New-Item -Path $directoryDestinationPath -ItemType Directory | Out-Null
    }
    Copy-Item -Path $childItem -Destination $destinationPath
    Write-Output "[$fileRelativePath] File copied to output."
  
    Write-Output "[$fileRelativePath] Creating compressed file..."
    $directoryDestinationPathCompressed = Join-Path "$PWD/output-compressed" "$directoryRelativePath"
    if (-not (Test-Path $directoryDestinationPathCompressed)) {
      New-Item -Path $directoryDestinationPathCompressed -ItemType Directory | Out-Null
    }
    $compressedFilePath = Join-Path $directoryDestinationPathCompressed "$($childItem.Name).zip"
    [System.IO.Compression.ZipFile]::CreateFromDirectory($directoryDestinationPath, $compressedFilePath)
    Write-Output "[$fileRelativePath] Compressed file created."
  
    Write-Output "-----"
  }
}

Write-Output '=========='

$sw.Stop()
Write-Output "Job duration: $($sw.Elapsed.ToString("c"))"
