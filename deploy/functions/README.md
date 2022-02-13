# Readme - deploy/functions

## Introduction

`amilochau/github-actions/deploy/functions` is a GitHub Action developed to deploy Azure Functions applications.

---

## Usage

Use this GitHub action if you want have one Azure Functions application that you want to publish, typically in a Continuous Delivery process.

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
      - uses: actions/checkout@v2
      - name: Deploy application
        uses: amilochau/github-actions/deploy/functions@v1
        with:
          azureCredentials: ${{ secrets.AZURE_CREDENTIALS }}
          applicationName: ${{ env.INFRA_APP_NAME }}
          projectsToPublishPath: ${{ env.PROJECTS_PUBLISH }}
          dotnetVersion: ${{ env.DOTNET_VERSION }}
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `dotnetVersion` | The .NET version to use | *false* | `''` | If you don't specify this, you should use your own `actions/setup-dotnet` task before |
| `azureCredentials` | Azure credentials, typically get from secrets.AZURE_CREDENTIALS | **true** |
| `applicationName` | The application name, as defined on Azure | **true** |
| `projectsToPublishPath` | The path of the projects to publish, relative to the checkout path | **true** |
| `healthUrl` | The absolute URL of the health endpoint, from the Functions application | *false* |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
