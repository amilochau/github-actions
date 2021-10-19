# Readme - build/netcore

## Introduction

`amilochau/github-actions/deploy/infrastructure` is a GitHub Action developed to deploy Azure infrastructure.

---

## Usage

Use this GitHub action if you want have ARM templates that you want to deploy, typically in a Continuous Delivery process.

### Example workflow

```yaml
name: Deploy infrastructure

on: workflow_dispatch

concurrency: deploy_infra_[NAME OF ENV]

jobs:
  deploy_app:
    name: Deploy infrastructure
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@main
        with:
          path: app
      - name: Deploy application
        uses: amilochau/github-actions/deploy/infrastructure@v1
        with:
          azureTemplateVersion: ${{ env.TEMPLATES_VERSION }}
          azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
          resourceGroupName: ${{ env.INFRA_RG_NAME }}
          resourceGroupLocation: ${{ env.INFRA_RG_LOCATION }}
          templateFilePath: ${{ env.INFRA_DEPLOY_TEMPLATE_PATH }}
          parametersFilePath: ${{ env.INFRA_DEPLOY_PARAMETERS_PATH }}
```

### Inputs

| Input | Description | Required | Default value |
| ----- | ----------- | -------- | ------------- |
| `azureTemplateVersion` | The version of 'azure-templates' to use | **true** |
| `azureCredentials` | Azure credentials, typically get from secrets.AZURE_CREDENTIALS | **true** |
| `resourceGroupName` | The name of the resource group where to deploy the infrastructure | **true** |
| `resourceGroupLocation` | The location of the resource group where to deploy the infrastructure | **true** |
| `templateFilePath` | The path of the infrastructure template to deploy | **true** |
| `parametersFilePath` | The path of the parameters files to use during deployment | **true** |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
