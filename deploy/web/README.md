# Readme - deploy/web

## Introduction

`amilochau/github-actions/deploy/web` is a GitHub Action developed to deploy Web applications from Docker images.

---

## Usage

Use this GitHub action if you want have one Web application that you want to deploy from a Docker image, typically in a Continuous Delivery process.

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
        uses: amilochau/github-actions/deploy/web@v3
        with:
          azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
          dockerImageName: ${{ env.DOCKER_IMAGE_NAME }}
          dockerImageTag: ${{ github.sha }}
          resourceGroupName: ${{ env.INFRA_RG_NAME }}
          applicationName: ${{ env.INFRA_APP_NAME }}
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `azureCredentials` | Azure credentials, typically get from secrets.AZURE_CREDENTIALS | **true** |
| `dockerRegistryHost` | The host of the Docker registry | *false* | `ghcr.io/` | Should end with a leading slash |
| `dockerImageName` | The name of the Docker image | **true** |
| `dockerImageTag` | The tag of the Docker image | **true** |
| `resourceGroupName` | The resource group name, as defined on Azure | **true** |
| `applicationName` | The application name, as defined on Azure | **true** |
| `relativeHealthUrl` | The relative URL of the health endpoint, from the Functions application | *false* | `/api/health` |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
