# Readme - deploy/infrastructure

## Introduction

`amilochau/github-actions/deploy/infrastructure` is a GitHub Action developed to deploy Azure infrastructure.

---

## Usage

Use this GitHub action if you have ARM templates that you want to deploy, typically in a Continuous Delivery process.

### Example workflow

```yaml
name: Deploy infrastructure

on:
  workflow_dispatch:
    inputs:
      forceDeployment:
        description: Force infrastructure deployment if the last infrastructure template used is the same as the current one
        required: false
        default: false
        type: boolean

concurrency: deploy_infra_[NAME OF ENV]

jobs:
  deploy_app:
    name: Deploy infrastructure
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          path: app
      - name: Deploy application
        uses: amilochau/github-actions/deploy/infrastructure@v3
        with:
          azureTemplateVersion: ${{ env.TEMPLATES_VERSION }}
          azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
          scopeType: ${{ env.INFRA_SCOPE_TYPE }}
          scopeLocation: ${{ env.INFRA_SCOPE_LOCATION }}
          templateType: ${{ env.INFRA_DEPLOY_TYPE }}
          resourceGroupName: ${{ env.INFRA_RG_NAME }}
          parametersFilePath: ${{ env.INFRA_DEPLOY_PARAMETERS_PATH }}
          forceDeployment: ${{ github.event.inputs.forceDeployment }}
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `azureTemplateVersion` | The version of 'azure-templates' to use | **true** |
| `azureCredentials` | Azure credentials, typically get from `secrets.AZURE_CREDENTIALS` | **true** |
| `templateType` | The type of Azure templates to use | **true** |
| `scopeType` | The deployment scope type | **true** | `resourceGroup` |
| `scopeLocation` | The deployment scope location (Azure region) | **true** |
| `resourceGroupName` | The name of the resource group where to deploy the infrastructure | *true if scope type is `resourceGroup`* |
| `subscriptionId` | The ID of the Azure subscription | *true if scope type is `subscription`* |
| `managementGroupId` | The ID of the Azure management group | *true if scope type is `managementGroup`* |
| `parametersFilePath` | The path of the parameters files to use during deployment | **true** |
| `deploymentName` | The path of the deployment into Azure | *false* | `Deployment-GitHub` |
| `forceDeployment` | Force deployment if the last template used is the same as the current one | **true** |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |
| `resourceId` | The ID of the main deployed resource |
| `resourceName` | The name of the main deployed resource |
