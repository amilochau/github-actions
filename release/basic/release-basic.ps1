<#
  .SYNOPSIS
  This script creates a new release on GitHub
  .PARAMETER versionMajor
  The major version
  .PARAMETER versionMinor
  The minor version
  .PARAMETER versionPatch
  The patch version
  .PARAMETER versionUnstableSuffix
  The unstable suffix version
  .PARAMETER currentBranch
  The current branch
  .PARAMETER createGithubPrerelease
  Create GitHub release for prerelease versions
  .PARAMETER verbosity
  The verbosity level
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [string]$versionMajor,

  [parameter(Mandatory = $true)]
  [string]$versionMinor,

  [parameter(Mandatory = $true)]
  [string]$versionPatch,

  [parameter(Mandatory = $false)]
  [string]$versionUnstableSuffix,

  [parameter(Mandatory = $true)]
  [string]$currentBranch,
  
  [parameter(Mandatory = $true)]
  [string]$createGithubPrerelease,
  
  [parameter(Mandatory = $true)]
  [ValidateSet('quiet', 'minimal', 'normal', 'detailed', 'diagnostic')]
  [string]$verbosity
)

Write-Output "Current branch is: $currentBranch"
Write-Output "Verbosity is: $verbosity"

$createGithubPrerelease = [System.Convert]::ToBoolean($createGithubPrerelease)
Write-Output "Create GitHub prerelease is: $createGithubPrerelease"


Write-Output '=========='
Write-Output 'Get current version...'

if ($versionUnstableSuffix) {
  $version="v$versionMajor.$versionMinor.$versionPatch-$versionUnstableSuffix"
  $isPrerelease = $true
  Write-Host "versionPrerelease=$true" >> $Env:GITHUB_OUTPUT
} else {
  $version="v$versionMajor.$versionMinor.$versionPatch"
  $isPrerelease = $false
  Write-Host "versionPrerelease=$false" >> $Env:GITHUB_OUTPUT
}
Write-Output "Set long version to $version"
Write-Output "versionLong=$version" >> $Env:GITHUB_OUTPUT

$versionShort="v$versionMajor"
Write-Output "Set short version to $versionShort"
Write-Output "versionShort=$versionShort" >> $Env:GITHUB_OUTPUT

Write-Output '=========='
Write-Output 'Check prerelease if not main branch...'
$mainBranch = 'refs/heads/main'
if ( ($currentBranch -ne $mainBranch) -And ($isPrerelease -ne $true)) {
  Write-Output 'You can not publish a stable release package if you are not in the main branch'
  throw 'You can not publish a stable release package if you are not in the main branch'
}

Write-Output '=========='
Write-Output 'Remove precedent tags for short and long versions...'
if ($isPrerelease -ne $true) {
  git push origin :refs/tags/$versionShort
  Write-Output "Precedent tag for short version has been removed ($versionShort)."
}
git push origin :refs/tags/$version
Write-Output "Precedent tag for long version has been removed ($version)."

Write-Output '=========='
Write-Output 'Set short and long versions tags...'
git config --global user.email "actions@github.com"
git config --global user.name "Github Actions"

if ($isPrerelease -ne $true) {
  git tag -fa $versionShort -m "Version $versionShort"
  Write-Output "Short version tag has been set ($versionShort)."
}

git tag -fa $version -m "Version $version"
Write-Output "Long version tag has been set ($version)."
git push origin --tags

Write-Output '=========='
Write-Output 'Create GitHub Release...'

if ($isPrerelease -eq $false) {
  Write-Output 'A stable release must be created.'
  gh release create "$version" --generate-notes --title "Version $version"
  Write-Output 'Release has been created.'
} elseif ($createGithubPrerelease -eq $true) {
  Write-Output 'A prerelease must be created.'
  gh release create "$version" --generate-notes --title "Version $version" --prerelease
  Write-Output 'Release has been created.'
} else {
  Write-Output 'No release has been created.'
}

Write-Output "=========="
