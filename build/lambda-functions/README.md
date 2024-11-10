# Readme - build/lambda-functions

## Introduction

`amilochau/github-actions/build/lambda-functions` is a GitHub Action developed to build AWS Lambda functions.

---

## Usage

Use this GitHub action if you want have one or many AWS Lambda functions that you want to build, typically in a Continuous Integration process.

### Example workflow

```yaml
name: Build

on: workflow_dispatch

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: read
    steps:
      - uses: actions/checkout@v4
      - name: Build AWS Lambda functions
        uses: amilochau/github-actions/build/lambda-functions@v4
        with:
          solutionPath: './api/Functions.sln'
          dotnetVersion: ${{ env.DOTNET_VERSION }}
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `solutionPath` | The path to the solution file, with functions to deploy | **true** |
| `publishPathFilter` | The path of the files to publish, as a filter to be tested to determine the files to add in the artifact | **true** |
| `dotnetVersion` | The .NET version to use | *false* | `'9.0.x'` |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
