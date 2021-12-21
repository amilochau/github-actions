# Readme - release/nuget

## Introduction

`amilochau/github-actions/release/npm` is a GitHub Action developed to pack Node.js libraries as npm packages, publish them into GitHub Packages and npmjs.com, and create a custom Release in the GitHub repository.

---

## Usage

Use this GitHub action if you want have one or many Node.js libraries that you want to build and publish.

### Example workflow

```yaml
name: Deploy libraries

on: workflow_dispatch

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@main
      - name: Deploy libraries
        uses: amilochau/github-actions/release/npm@v1
        with:
          versionFile: ${{ env.VERSION_FILE }}
          githubToken: ${{ secrets.GITHUB_TOKEN }}
          avoidGitHubPrerelease: true
          generateReleaseNotes: true
```

### Inputs

| Input | Description | Required | Default value |
| ----- | ----------- | -------- | ------------- |
| `projectWorkspace` | The path to the project workspace | *false* | `.` |
| `nodeVersion` | The Node.js version to use | ** | `16.x` |
| `githubToken` | The GitHub token, typically get from `secrets.GITHUB_TOKEN` | **true** |
| `avoidGitHubPrerelease` | Disable GitHub Release creation for unstable version | *false* | `false` |
| `generateReleaseNotes` | Generate automatic release notes |  *false* | `false` |
| `npmjsComToken` |  The npmjs.com token, typically get from a secret; used to publish projects to npmjs.com | *false* | `''` |
| `mainBranch` | The name of the main branch | *false* | `refs/heads/main` |

### Outputs

| Output | Description |
| ------ | ----------- |
| `versionNumber` | The version as defined in the Git tag |
| `versionPrerelease` | If the version is recognized as a prerelease |

## Examples

```yaml
steps:
- uses: actions/checkout@main
- name: Setup .NET Core
  uses: actions/setup-dotnet@v1
  with:
    dotnet-version: ${{ inputs.dotnetVersion }}
    source-url: ${{ inputs.nugetUrl }}
  env:
    NUGET_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
- name: Deploy libraries
  id: actions_release
    uses: amilochau/github-actions/release/nuget@v1
  with:
    projectsToBuild: ${{ env.PROJECTS_BUILD }}
    projectsToPublish: ${{ env.PROJECTS_SDK }}
    versionFile: ${{ env.VERSION_FILE }}
    githubToken: ${{ secrets.GITHUB_TOKEN }}

# Use outputs here 
- name: Check outputs
    run: |
    echo "Version number: ${{ steps.actions_release.outputs.versionNumber }}"
```
