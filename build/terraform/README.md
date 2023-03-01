# Readme - build/terraform

## Introduction

`amilochau/github-actions/build/terraform` is a GitHub Action developed to build and test Terraform modules.

---

## Usage

Use this GitHub action if you want have one or many Terraform modules that you want to build and test, typically in a Continuous Integration process.

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
      - name: Build and test Terraform modules
        uses: amilochau/github-actions/build/terraform@v3
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `modulesPath` | The path to the Terraform modules to build | *false* | `.tf` |
| `modulesPathDepth` | The path to the projects to test - can be a .csproj or a .sln file | *false* | `1` |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
