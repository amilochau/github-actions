<#
  .SYNOPSIS
  This script clean GitHub Actions artifacts
  .PARAMETER runId
  The id of the GitHub Actions run from which to clean artifacts
  .PARAMETER verbosity
  The verbosity level
#>

[CmdletBinding()]
Param(
  [parameter(Mandatory = $true)]
  [string]$runId,

  [parameter(Mandatory = $true)]
  [ValidateSet('minimal', 'normal', 'detailed')]
  [string]$verbosity
)

Write-Output "Run Id is: $runId"
Write-Output "Verbosity is: $verbosity"
Write-Output "GitHub environment is: $env:GITHUB_REPOSITORY"

Write-Output '=========='

Write-Output 'Getting artifacts from current run...'
$url = "/repos/$env:GITHUB_REPOSITORY/actions/runs/$runId/artifacts"
Write-Output "Url is: $url"

$artifactsResponse = gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" $url

$artifacts = ($artifactsResponse | ConvertFrom-Json).artifacts
$artifactsCount = $artifacts.Count
Write-Output "Items found: $artifactsCount"

foreach ($artifact in $artifacts) {
  $artifactName = $artifact.name
  Write-Output "[$artifactName] Removing artifact..."

  $artifactId = $artifact.id
  $url = "/repos/$env:GITHUB_REPOSITORY/actions/artifacts/$artifactId"
  Write-Output "[$artifactName] Url is: $url"

  $artifactsRemoveResponse = gh api --method DELETE -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" $url

  $artifactsRemoveResponse
  Write-Output "[$artifactName] Artifact removed."
}

Write-Output '=========='
