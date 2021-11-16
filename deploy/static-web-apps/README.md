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
          azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
          staticWebAppsName: ${{ env.INFRA_APP_NAME }}
          projectWorkspace: ${{ env.PROJECT_WORKSPACE }}
          projectOutput: ${{ env.PROJECT_OUTPUT }}
          azureStaticWebAppsApiToken: ${{ secrets.SWA_TOKEN }}
          githubToken: ${{ secrets.GITHUB_TOKEN }}
```

### Inputs

| Input | Description | Required | Default value |
| ----- | ----------- | -------- | ------------- |
| `azureCredentials` | Azure credentials, typically get from secrets.AZURE_CREDENTIALS | **true** |
| `applicationName` | The application name, as defined on Azure | **true** |
| `projectWorkspace` | The path to the project to build | **true** |
| `projectOutput` | The path to the output of the build project | **true** |
| `githubToken` | The GitHub token, typically get from `secrets.GITHUB_TOKEN` | **true** |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
