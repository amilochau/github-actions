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

jobs:
  release:
    runs-on: ubuntu-latest
    env:
      GH_TOKEN: ${{ github.token }}
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
      - name: Set up a GitHub Release
        uses: amilochau/github-actions/release/basic@v4
        with:
          versionMajor: ${{ github.event.inputs.versionMajor }}
          versionMinor: ${{ github.event.inputs.versionMinor }}
          versionPatch: ${{ github.event.inputs.versionPatch }}
          versionUnstableSuffix: ${{ github.event.inputs.versionUnstableSuffix }}
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `versionMajor` | The major version - must be changed when you make incompatible API changes | **true** |
| `versionMinor` | The minor version - must be changed when you add functionality in a backward compatible manner | **true** |
| `versionPatch` | The patch version - must be changed when you make backwards compatible bug fixes | **true** |
| `versionUnstableSuffix` | The unstable suffix version - must be added when you want to create a pre-release | *false* | `''` |
| `createGithubPrerelease` | Create GitHub Release for unstable version | *false* | `false` |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |
| `versionLong` | The long version as defined in the long Git tag |
| `versionShort` | The short version as defined in the short Git tag |
| `versionPrerelease` | If the version is recognized as a prerelease |
