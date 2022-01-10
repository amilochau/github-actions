<#
  .SYNOPSIS
  This script releases a workspace as a npm package
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
  .PARAMETER generateReleaseNotes
  Generate release notes
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
  [string]$avoidGithubPrerelease,
  
  [parameter(Mandatory = $true)]
  [string]$generateReleaseNotes
)

Write-Output "Main branch is: $mainBranch"
Write-Output "Current branch is: $currentBranch"

[System.Convert]::ToBoolean($avoidGithubPrerelease)
Write-Output "Avoid GitHub prerelease is: $avoidGithubPrerelease"

[System.Convert]::ToBoolean($generateReleaseNotes)
Write-Output "Generate release notes is: $generateReleaseNotes"


Write-Output '=========='
Write-Output 'Get current version...'

if (($null -ne $versionUnstableSuffix) -and ($versionUnstableSuffix.Length -gt 0)) {
  $versionLong=v$versionMajor.$versionMinor.$versionPatch-$versionUnstableSuffix
  $match = $true
  Write-Host "::set-output name=versionPrerelease::$true"
} else {
  $versionLong=v$versionMajor.$versionMinor.$versionPatch
  $match = $false
  Write-Host "::set-output name=versionPrerelease::$false"
}
Write-Output "Set long version to $versionLong"
Write-Output "::set-output name=versionLong::$versionLong"

$versionShort=v$versionMajor
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
git push origin :refs/tags/$versionLong
Write-Output "Precedent tag for long version has been removed ($versionLong)."

Write-Output '=========='
Write-Output 'Set short and long versions tags...'
git config --global user.email "actions@github.com"
git config --global user.name "Github Actions"

if ($match -ne $true) {
  git tag -fa $versionShort -m "Version $versionLong"
  Write-Output "Short version tag has been set ($versionShort)."
}

git tag -fa $versionLong -m "Version $versionLong"
Write-Output "Long version tag has been set ($versionLong)."
git push origin --tags

Write-Output '=========='
Write-Output 'Create GitHub Release...'
if ($match -And $avoidGithubPrerelease) {
  Write-Output 'No release must be created.'
  return
}

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/vnd.github.v3+json")
$headers.Add("Authorization", "token $githubToken")

Write-Output 'Checking if release notes must be included...'
$releaseNote = '...'
if ($generateReleaseNotes) {
  Write-Output 'Release note must be included.'

  $response = Invoke-RestMethod "https://api.github.com/repos/$Env:GITHUB_REPOSITORY/releases/latest" -Method 'GET' -Headers $headers -SkipHttpErrorCheck
  if ($response.tag_name) {
    $lastRelease = $response.tag_name
    Write-Output "Latest release is $($lastRelease)."

    $headers.Add("Content-Type", "application/json")
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
} else {
  Write-Output 'Release note is read from CHANGELOG.md'
  $releaseNote = Get-Content 'CHANGELOG.md' | Out-String
  Write-Output 'Release note has been read.'
}

Write-Debug $releaseNote

Write-Output 'Creating release...'
if ($match -eq $false) {
  Write-Output 'A stable release must be created.'

  $body = @{
    tag_name = "$version";
    name = "Version $version";
    body = $releaseNote;
    draft = $true;
  } | ConvertTo-Json

  Invoke-RestMethod "https://api.github.com/repos/$Env:GITHUB_REPOSITORY/releases" -Method 'POST' -Headers $headers -Body $body

  Write-Output 'Stable release has been created.'
} elseif ($avoidGithubPrerelease -eq $false) {
  Write-Output 'A prerelease must be created.'

  $body = @{
    tag_name = "$version";
    name = "Version $version";
    body = $releaseNote;
    draft = $true;
    prerelease = $true;
  } | ConvertTo-Json

  Invoke-RestMethod "https://api.github.com/repos/$Env:GITHUB_REPOSITORY/releases" -Method 'POST' -Headers $headers -Body $body

  Write-Output 'Prerelease has been created.'
} else {
  Write-Output 'No release has been created!'
}

Write-Output "=========="
