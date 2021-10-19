# Readme - build/netcore

## Introduction

`amilochau/github-actions/deploy/infrastructure` is a GitHub Action developed to deploy an API Management backend.

---

## Usage

Use this GitHub action if you have ARM templates that you want to use to register an API Management backend, typically in a Continuous Delivery process.

### Example workflow

```yaml
name: Register application

on: workflow_dispatch

concurrency: deploy_backend_[NAME OF ENV]

jobs:
  deploy_app:
    name: Register application
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@main
        with:
          path: app
      - name: Deploy application
        uses: amilochau/github-actions/deploy/gateway-backend@v1
        with:
          azureTemplateVersion: ${{ env.TEMPLATES_VERSION }}
          azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
          resourceGroupName: ${{ env.INFRA_RG_NAME }}
          templateFilePath: ${{ env.INFRA_REGISTER_TEMPLATE_PATH }}
          parametersFilePath: ${{ env.INFRA_REGISTER_PARAMETERS_PATH }}
```

### Inputs

| Input | Description | Required | Default value |
| ----- | ----------- | -------- | ------------- |
| `azureTemplateVersion` | The version of 'azure-templates' to use | **true** |
| `azureCredentials` | Azure credentials, typically get from secrets.AZURE_CREDENTIALS | **true** |
| `resourceGroupLocation` | The location of the resource group where to deploy the infrastructure | **true** |
| `templateFilePath` | The path of the infrastructure template to deploy | **true** |
| `parametersFilePath` | The path of the parameters files to use during deployment | **true** |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
