<#
  .SYNOPSIS
  This script creates a new release on GitHub and publishes a workspace as NuGet packages
  .PARAMETER versionFile
  The file where to get version (XML file)
  .PARAMETER currentBranch
  The current branch
  .PARAMETER projectsToBuild
  The projects to build
  .PARAMETER projectsToPublish
  The projects to publish
  .PARAMETER nugetOrgToken
  The nuget.org token
  .PARAMETER avoidGithubPrerelease
  Avoid creating GitHub release for prerelease versions
  .PARAMETER githubOrganization
  Name of the GitHub organization
  .PARAMETER verbosity
  The verbosity level
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [string]$versionFile,

  [parameter(Mandatory = $true)]
  [string]$currentBranch,
  
  [parameter(Mandatory = $true)]
  [string]$projectsToBuild,

  [parameter(Mandatory = $true)]
  [string]$projectsToPublish,

  [parameter(Mandatory = $true)]
  [string]$nugetOrgToken,

  [parameter(Mandatory = $true)]
  [string]$avoidGithubPrerelease,

  [parameter(Mandatory = $true)]
  [string]$githubOrganization,
  
  [parameter(Mandatory = $true)]
  [ValidateSet('minimal', 'normal', 'detailed')]
  [string]$verbosity
)

Write-Output "Version file is: $versionFile"
Write-Output "Current branch is: $currentBranch"
Write-Output "Projects to build are: $projectsToBuild"
Write-Output "Projects to publish are: $projectsToPublish"
Write-Output "GitHub organization is: $githubOrganization"
Write-Output "Verbosity is: $verbosity"

$avoidGithubPrerelease = [System.Convert]::ToBoolean($avoidGithubPrerelease)
Write-Output "Avoid GitHub prerelease is: $avoidGithubPrerelease"


Write-Output '=========='
Write-Output 'Get current version...'

[xml]$versionFileContent = Get-Content -Path $versionFile
$version = "v" + $versionFileContent.Project.PropertyGroup.Version
Write-Output "Set long version to $version"
Write-Output "versionLong=$version" >> $Env:GITHUB_OUTPUT

$versionShort = ($version -split '\.')[0]
Write-Output "Set short version to $versionShort"
Write-Output "versionShort=$versionShort" >> $Env:GITHUB_OUTPUT

$exp = '^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'
$match = $version -match $exp
Write-Output "Prerelease match is: $match"
Write-Host "versionPrerelease=$match" >> $Env:GITHUB_OUTPUT

Write-Output '=========='
Write-Output 'Check prerelease if not main branch...'
$mainBranch = 'refs/heads/main'
if ( ($currentBranch -ne $mainBranch) -And ($match -ne $true)) {
  Write-Output 'You can not publish a stable release package if you are not in the main branch'
  throw 'You can not publish a stable release package if you are not in the main branch'
}

Write-Output '=========='
Write-Output 'Install packages...'
dotnet restore $projectsToBuild --verbosity $verbosity

Write-Output '=========='
Write-Output 'Build application...'
dotnet build $projectsToBuild --configuration Release --no-restore --verbosity $verbosity

Write-Output '=========='
Write-Output 'Pack projects...'
dotnet pack $projectsToPublish --configuration Release --no-restore --no-build --output ./build --verbosity $verbosity

Write-Output '=========='
Write-Output 'Publish projects to nuget.org...'
if ($nugetOrgToken.length -gt 0) {
  Write-Output 'Token for nuget.org is found.'
  dotnet nuget push ./build/*.nupkg --api-key $nugetOrgToken --source https://api.nuget.org/v3/index.json
}

Write-Output '=========='
Write-Output 'Publish projects to GitHub Packages...'
dotnet nuget push ./build/*.nupkg --api-key="$($Env:GH_TOKEN)" --source="https://nuget.pkg.github.com/$githubOrganization/index.json"

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

if ($match -eq $false) {
  Write-Output 'A stable release must be created.'
  gh release create "$version" --generate-notes --title "Version $version"
} elseif ($avoidGithubPrerelease -eq $false) {
  Write-Output 'A prerelease must be created.'
  gh release create "$version" --generate-notes --title "Version $version" --prerelease
  $rawBody.prerelease = $true;
} else {
  Write-Output 'No release has been created!'
  return
}

Write-Output 'Release has been created.'
Write-Output "=========="
