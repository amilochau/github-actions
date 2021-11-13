# Readme - deploy/static-web-apps

## Introduction

`amilochau/github-actions/deploy/static-web-apps` is a GitHub Action developed to deploy Azure Static Web Apps applications.

---

## Usage

Use this GitHub action if you want have one Azure Static Web Apps application that you want to publish, typically in a Continuous Delivery process.

### Example workflow

```yaml
name: Deploy application

on: workflow_dispatch

concurrency: deploy_app_[NAME OF ENV]

jobs:
  deploy_app:
    name: Deploy application
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@main
      - name: Deploy application
        uses: amilochau/github-actions/deploy//static-web-apps@v1
        with:
          projectWorkspace: ${{ env.PROJECT_WORKSPACE }}
          projectOutput: ${{ env.PROJECT_OUTPUT }}
          azureStaticWebAppsApiToken: ${{ secrets.SWA_TOKEN }}
          githubToken: ${{ secrets.GITHUB_TOKEN }}
```

### Inputs

| Input | Description | Required | Default value |
| ----- | ----------- | -------- | ------------- |
| `projectWorkspace` | The path to the project to build | **true** |
| `projectOutput` | The path to the output of the build project | **true** |
| `azureStaticWebAppsApiToken` | The token from the Azure Static Web Apps; could be found from the Azure Portal | **true** |
| `githubToken` | The GitHub token, typically get from `secrets.GITHUB_TOKEN` | **true** |
| `nodeVersion` | The Node.js version to use | *false* | `16.x` |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
