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

Write-Output '=========='

Write-Output 'Getting artifacts from current run...'
$artifactsResponse = gh api \
-H "Accept: application/vnd.github+json" \
-H "X-GitHub-Api-Version: 2022-11-28" \
/repos/$env:GITHUB_REPOSITORY/actions/runs/$env:GITHUB_RUN_ID/artifacts

$artifacts = ($artifactsResponse | ConvertFrom-Json).artifacts
Write-Output 'Getting artifacts from current run...'
$artifactsCount = $artifacts.Count
Write-Output "Items found: $artifactsCount"

foreach ($artifact in $artifacts) {
  $artifactName = $artifact.name
  Write-Output "[$artifactName] Removing artifact..."
}

Write-Output '=========='
