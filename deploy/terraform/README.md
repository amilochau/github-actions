# Readme - deploy/terraform

## Introduction

`amilochau/github-actions/deploy/terraform` is a GitHub Action developed to deploy a Terraform module.

---

## Usage

Use this GitHub action if you have a Terraform module that you want to deploy, typically in a Continuous Deployment process.

### Example workflow

```yaml
name: Deploy

on: workflow_dispatch

jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy a Terraform module
        uses: amilochau/github-actions/deploy/terraform@v4
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `modulePath` | The path to the Terraform module to deploy | *false* | `infra` |
| `workspaceName` | The name of the Terraform workspace | *false* | `default` |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
