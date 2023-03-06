# Readme - deploy/static-web-apps

## Introduction

`amilochau/github-actions/deploy/static-web-apps` is a GitHub Action developed to deploy Azure Static Web Apps applications.

---

## Usage

Use this GitHub action if you have one Azure Static Web Apps application that you want to publish, typically in a Continuous Delivery process.

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
      - uses: actions/checkout@v3
      - name: Deploy application
        uses: amilochau/github-actions/deploy//static-web-apps@v3
        with:
          azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
          resourceGroupName: ${{ env.INFRA_RG_NAME }}
          applicationName: ${{ env.INFRA_APP_NAME }}
          projectsToPublishPath: ${{ env.PROJECT_WORKSPACE }}
          npmBuildScript: ${{ env.PROJECT_COMMAND }}
          githubToken: ${{ secrets.GITHUB_TOKEN }}
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `nodeVersion` | The Node.js version to use | *false* | `16.x` |
| `azureCredentials` | Azure credentials, typically get from secrets.AZURE_CREDENTIALS | **true** |
| `resourceGroupName` | The resource group name, as defined on Azure | **true** |
| `applicationName` | The application name, as defined on Azure | **true** |
| `projectsToPublishPath` | The path of the projects to publish, relative to the checkout path | *false* | `.` |
| `relativeOutputPath` | The path to the output of the build project | *false* | `./dist` |
| `npmBuildScript` | The npm script to run, to build the application | *false* | `build` |
| `githubToken` | The GitHub token, typically get from `secrets.GITHUB_TOKEN` | **true** |
| `distSource` | The source of the dist files | *false* | `build` | Set to `build` or `artifact` |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
