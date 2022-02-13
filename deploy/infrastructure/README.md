# Readme - deploy/infrastructure

## Introduction

`amilochau/github-actions/deploy/infrastructure` is a GitHub Action developed to deploy Azure infrastructure.

---

## Usage

Use this GitHub action if you have ARM templates that you want to deploy, typically in a Continuous Delivery process.

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
      - uses: actions/checkout@v2
        with:
          path: app
      - name: Deploy application
        uses: amilochau/github-actions/deploy/infrastructure@v1
        with:
          azureTemplateVersion: ${{ env.TEMPLATES_VERSION }}
          azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
          scopeType: ${{ env.INFRA_SCOPE_TYPE }}
          resourceGroupName: ${{ env.INFRA_RG_NAME }}
          resourceGroupLocation: ${{ env.INFRA_RG_LOCATION }}
          parametersFilePath: ${{ env.INFRA_DEPLOY_PARAMETERS_PATH }}
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `azureTemplateVersion` | The version of 'azure-templates' to use | **true** |
| `azureCredentials` | Azure credentials, typically get from `secrets.AZURE_CREDENTIALS` | **true** |
| `resourceGroupName` | The name of the resource group where to deploy the infrastructure | *true if scope is `resourceGroup`* |
| `resourceGroupLocation` | The location of the resource group where to deploy the infrastructure | *true if scope is `resourceGroup`* |
| `subscriptionId` | The ID of the Azure subscription | *true if scope is `subscription`* |
| `subscriptionRegion` | The region of the Azure subscription | *true if scope is `subscription`* |
| `managementGroupId` | The ID of the Azure management group | *true if scope is `managementGroup`* |
| `managementGroupRegion` | The region of the Azure management group | *true if scope is `managementGroup`* |
| `scopeType` | The deployment scope type | **true** | `resourceGroup` |
| `templateType` | The type of Azure templates to use | **true** |
| `parametersFilePath` | The path of the parameters files to use during deployment | **true** |
| `deploymentName` | The path of the deployment into Azure | *false* | `Deployment-GitHub` |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |
| `resourceId` | The ID of the main deployed resource |
| `resourceName` | The name of the main deployed resource |
