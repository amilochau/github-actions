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

Write-Output "Actions runtime URL: $env:ACTIONS_RUNTIME_URL"
$uri = "$($env:ACTIONS_RUNTIME_URL)_apis/pipelines/workflows/$env:GITHUB_RUN_ID/artifacts?api-version=2022-11-28"
Write-Output "Uri: $uri"
            


$headers = @{
  Accept = 'application/vnd.github.v3+json'
  Authorization = "token $env:GITHUB_TOKEN"
  'Content-Type' = 'application/json'
}

$artifactsResponse1 = Invoke-RestMethod "https://api.github.com/repos/$env:GITHUB_REPOSITORY/actions/runs/$env:GITHUB_RUN_ID/artifacts" -Method 'GET' -Headers $headers -SkipHttpErrorCheck
Write-Output '----- Response 1'
Write-Output $artifactsResponse1
Write-Output '----- Response 1'

$artifactsResponse2 = gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" $url
Write-Output '----- Response 2'
Write-Output $artifactsResponse2
Write-Output '----- Response 2'

$artifacts = ($artifactsResponse2 | ConvertFrom-Json).artifacts
$artifactsCount = $artifacts.Count
Write-Output "Items found: $artifactsCount"

foreach ($artifact in $artifacts) {
  $artifactName = $artifact.name
  Write-Output "[$artifactName] Removing artifact..."
}

Write-Output '=========='
