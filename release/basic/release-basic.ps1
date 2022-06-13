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
  .PARAMETER mainBranch
  The main branch
  .PARAMETER currentBranch
  The current branch
  .PARAMETER githubToken
  The GitHub token
  .PARAMETER avoidGithubPrerelease
  Avoid creating GitHub release for prerelease versions
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
  [string]$mainBranch,

  [parameter(Mandatory = $true)]
  [string]$currentBranch,
  
  [parameter(Mandatory = $true)]
  [string]$githubToken,
  
  [parameter(Mandatory = $true)]
  [string]$avoidGithubPrerelease
)

Write-Output "Main branch is: $mainBranch"
Write-Output "Current branch is: $currentBranch"

$avoidGithubPrerelease = [System.Convert]::ToBoolean($avoidGithubPrerelease)
Write-Output "Avoid GitHub prerelease is: $avoidGithubPrerelease"


Write-Output '=========='
Write-Output 'Get current version...'

if ($versionUnstableSuffix) {
  $version="v$versionMajor.$versionMinor.$versionPatch-$versionUnstableSuffix"
  $match = $true
  Write-Host "::set-output name=versionPrerelease::$true"
} else {
  $version="v$versionMajor.$versionMinor.$versionPatch"
  $match = $false
  Write-Host "::set-output name=versionPrerelease::$false"
}
Write-Output "Set long version to $version"
Write-Output "::set-output name=versionLong::$version"

$versionShort="v$versionMajor"
Write-Output "Set short version to $versionShort"
Write-Output "::set-output name=versionShort::$versionShort"

Write-Output '=========='
Write-Output 'Check prerelease if not main branch...'

if ( ($currentBranch -ne $mainBranch) -And ($match -ne $true)) {
  Write-Output 'You can not publish a stable release package if you are not in the main branch'
  throw 'You can not publish a stable release package if you are not in the main branch'
}

Write-Output '=========='
Write-Output 'Remove precedent tags for short and long versions...'
if ($match -ne $true) {
  git push origin :refs/tags/$versionShort
  Write-Output "Precedent tag for short version has been removed ($versionShort)."
}
git push origin :refs/tags/$version
Write-Output "Precedent tag for long version has been removed ($version)."

Write-Output '=========='
Write-Output 'Set short and long versions tags...'
git config --global user.email "actions@github.com"
git config --global user.name "Github Actions"

if ($match -ne $true) {
  git tag -fa $versionShort -m "Version $versionShort"
  Write-Output "Short version tag has been set ($versionShort)."
}

git tag -fa $version -m "Version $version"
Write-Output "Long version tag has been set ($version)."
git push origin --tags

Write-Output '=========='
Write-Output 'Create GitHub Release...'
if ($match -And $avoidGithubPrerelease) {
  Write-Output 'No release must be created.'
  return
}

$headers = @{
  Accept = 'application/vnd.github.v3+json'
  Authorization = "token $githubToken"
  'Content-Type' = 'application/json'
}

Write-Output 'Generating release notes...'
$releaseNote = '...'

$response = Invoke-RestMethod "https://api.github.com/repos/$Env:GITHUB_REPOSITORY/releases/latest" -Method 'GET' -Headers $headers -SkipHttpErrorCheck
if ($response.tag_name) {
  $lastRelease = $response.tag_name
  Write-Output "Latest release is $($lastRelease)."

  $body = @{
    tag_name = "$version";
    previous_tag_name = $lastRelease;
  } | ConvertTo-Json

  $response = Invoke-RestMethod "https://api.github.com/repos/$Env:GITHUB_REPOSITORY/releases/generate-notes" -Method 'POST' -Headers $headers -Body $body
  $releaseNote = $response.body
  
  Write-Output 'Release note has been generated.'
} else {
  Write-Output 'No release has been found, release note can''t be generated.'
}

Write-Debug $releaseNote

Write-Output 'Creating release...'
$rawBody = @{
  tag_name = "$version";
  name = "Version $version";
  body = $releaseNote;
  draft = $true;
  prerelease = $false;
}

if ($match -eq $false) {
  Write-Output 'A stable release must be created.'
} elseif ($avoidGithubPrerelease -eq $false) {
  Write-Output 'A prerelease must be created.'
  $rawBody.prerelease = $true;
} else {
  Write-Output 'No release has been created!'
  return
}

$body = $rawBody | ConvertTo-Json
Invoke-RestMethod "https://api.github.com/repos/$Env:GITHUB_REPOSITORY/releases" -Method 'POST' -Headers $headers -Body $body
Write-Output 'Release has been created.'

Write-Output "=========="
