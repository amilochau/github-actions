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
    steps:
      - uses: actions/checkout@v3
      - name: Build AWS Lambda functions
        uses: amilochau/github-actions/build/lambda-functions@v3
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `functionsPath` | The path to the functions to deploy | **true** |
| `functionsPathFilter` | The path filter to find the functions to deploy | *false* | `*.csproj` |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
