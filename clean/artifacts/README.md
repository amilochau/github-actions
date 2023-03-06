# Readme - clean/artifacts

## Introduction

`amilochau/github-actions/clean/artifacts` is a GitHub Action developed to clean GitHub Actions artifacts.

---

## Usage

Use this GitHub action if you want to clean artifacts generated during a GitHub Actions workflow, typically in a Continuous Delivery process.

### Example workflow

```yaml
name: Clean artifacts

on: workflow_dispatch

concurrency: clean

jobs:
  clean:
    name: Clean
    runs-on: ubuntu-latest
    steps:
      - name: Clean artifacts
        uses: amilochau/github-actions/clean/artifacts@v3
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `githubToken` | The GitHub token, typically get from `secrets.GITHUB_TOKEN` | **true** |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
