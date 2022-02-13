# Readme - release/npm

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
      - uses: actions/checkout@v2
      - name: Deploy libraries
        uses: amilochau/github-actions/release/npm@v1
        with:
          versionFile: ${{ env.VERSION_FILE }}
          githubToken: ${{ secrets.GITHUB_TOKEN }}
          avoidGitHubPrerelease: true
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `projectWorkspace` | The path to the project workspace | *false* | `.` |
| `nodeVersion` | The Node.js version to use | *false* | `16.x` |
| `githubToken` | The GitHub token, typically get from `secrets.GITHUB_TOKEN` | **true** |
| `avoidGitHubPrerelease` | Disable GitHub Release creation for unstable version | *false* | `false` |
| `npmjsComToken` |  The npmjs.com token, typically get from a secret; used to publish projects to npmjs.com | *false* | `''` |
| `mainBranch` | The name of the main branch | *false* | `refs/heads/main` |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |
| `versionLong` | The long version as defined in the long Git tag |
| `versionShort` | The short version as defined in the short Git tag |
| `versionPrerelease` | If the version is recognized as a prerelease |
