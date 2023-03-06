<#
  .SYNOPSIS
  This script clean GitHub Actions artifacts
  .PARAMETER verbosity
  The verbosity level
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [ValidateSet('minimal', 'normal', 'detailed')]
  [string]$verbosity
)

Write-Output "Verbosity is: $verbosity"
Write-Output "GitHub environment is: $env:GITHUB_REPOSITORY"
Write-Output "GitHub run id is: $env:GITHUB_RUN_ID"
Write-Output "Verbosity is: $verbosity"

Write-Output '=========='

Write-Output 'Getting artifacts from current run...'
$url = "/repos/$env:GITHUB_REPOSITORY/actions/runs/$env:GITHUB_RUN_ID/artifacts"
Write-Output "Url is: $url"
$c = $env:GITHUB_TOKEN.Length
Write-Output "GitHub token characters: $c"
$artifactsResponse = gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" $url

$artifacts = ($artifactsResponse | ConvertFrom-Json).artifacts
$artifactsCount = $artifacts.Count
Write-Output "Items found: $artifactsCount"

foreach ($artifact in $artifacts) {
  $artifactName = $artifact.name
  Write-Output "[$artifactName] Removing artifact..."
}

Write-Output '=========='
