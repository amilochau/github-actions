# Readme - release/basic

## Introduction

`amilochau/github-actions/release/basic` is a GitHub Action developed to create a custom Release in the GitHub repository, with Git tags management and pre-releases support.

---

## Usage

Use this GitHub action if you want create complete GitHub Releases, with a manual version to provide.

### Example workflow

```yaml
name: Release

on:
  workflow_dispatch:
    inputs:
      versionMajor:
        description: Major version - must be changed when you make incompatible API changes
        required: true
      versionMinor:
        description: Minor version - must be changed when you add functionality in a backward compatible manner
        required: true
      versionPatch:
        description: Patch version - must be changed when you make backwards compatible bug fixes
        required: true
      versionUnstableSuffix:
        description: Unstable suffix version - must be added when you want to create a pre-release
        required: false
        default: ''
      avoidGitHubPrerelease:
        description: Disable GitHub Release creation for unstable version
        type: boolean
        default: true

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@main
      - name: Set up a GitHub Release
        uses: amilochau/github-actions/release/basic@v1
        with:
          versionMajor: ${{ github.event.inputs.versionMajor }}
          versionMinor: ${{ github.event.inputs.versionMinor }}
          versionPatch: ${{ github.event.inputs.versionPatch }}
          versionUnstableSuffix: ${{ github.event.inputs.versionUnstableSuffix }}
          githubToken: ${{ secrets.GITHUB_TOKEN }}
          avoidGitHubPrerelease: ${{ github.event.inputs.avoidGitHubPrerelease }}
          generateReleaseNotes: true
```

### Inputs

| Input | Description | Required | Default value |
| ----- | ----------- | -------- | ------------- |
| `versionMajor` | The major version - must be changed when you make incompatible API changes | **true** |
| `versionMinor` | The minor version - must be changed when you add functionality in a backward compatible manner | **true** |
| `versionPatch` | The patch version - must be changed when you make backwards compatible bug fixes | **true** |
| `versionUnstableSuffix` | The unstable suffix version - must be added when you want to create a pre-release | **true** |
| `githubToken` | The GitHub token, typically get from `secrets.GITHUB_TOKEN` | **true** |
| `avoidGitHubPrerelease` | Disable GitHub Release creation for unstable version | *false* | `false` |
| `generateReleaseNotes` | Generate automatic release notes |  *false* | `false` |
| `mainBranch` | The name of the main branch | *false* | `refs/heads/main` |

### Outputs

| Output | Description |
| ------ | ----------- |
| `versionLong` | The long version as defined in the long Git tag |
| `versionShort` | The short version as defined in the short Git tag |
| `versionPrerelease` | If the version is recognized as a prerelease |

## Examples

```yaml
steps:
- uses: actions/checkout@main
- name: Set up a GitHub Release
  id: actions_release
  uses: amilochau/github-actions/release/basic@v1
  with:
    versionMajor: ${{ github.event.inputs.versionMajor }}
    versionMinor: ${{ github.event.inputs.versionMinor }}
    versionPatch: ${{ github.event.inputs.versionPatch }}
    versionUnstableSuffix: ${{ github.event.inputs.versionUnstableSuffix }}
    githubToken: ${{ secrets.GITHUB_TOKEN }}

# Use outputs here 
- name: Check outputs
    run: |
    echo "Version (long): ${{ steps.actions_release.outputs.versionLong }}"
```
