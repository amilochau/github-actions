# Readme - release/npm

## Introduction

`amilochau/github-actions/release/npm` is a GitHub Action developed to pack Node.js libraries as npm packages, publish them into npmjs.com, and create a custom Release in the GitHub repository.

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
    env:
      GH_TOKEN: ${{ github.token }}
    permissions:
      contents: write
      id-token: write
    steps:
      - uses: actions/checkout@v4
      - name: Deploy libraries
        uses: amilochau/github-actions/release/npm@v4
        with:
          npmjsComToken: ${{ secrets.NPMJSCOM_TOKEN }}
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `projectWorkspace` | The path to the project workspace | *false* | `.` |
| `nodeVersion` | The Node.js version to use | *false* | `20.x` |
| `npmBuildCommand` | The npm command to run, to build the application | *false* | `build` |
| `npmPublishCommand` | The npm command to run, to publish the application | *false* | `publish` |
| `createGithubPrerelease` | Create GitHub Release for unstable version | *false* | `false` |
| `npmjsComToken` |  The npmjs.com token, typically get from a secret; used to publish projects to npmjs.com | **true** |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |
| `versionNumber` | The version as defined in the Git tag |
| `versionPrerelease` | If the version is recognized as a prerelease |
