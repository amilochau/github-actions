# Readme - build/netcore

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
      - uses: actions/checkout@main
      - name: Setup .NET Core
        uses: actions/setup-dotnet@v1
        with:
          dotnet-version: ${{ env.DOTNET_VERSION }}
      - name: Deploy application
        uses: amilochau/github-actions/deploy/application@v1
        with:
          projectsToBuild: ${{ env.PROJECTS_BUILD }}
          projectsToTest: ${{ env.PROJECTS_TESTS }}
```

### Inputs

| Input | Description | Required | Default value |
| ----- | ----------- | -------- | ------------- |
| `projectsToBuild` | The path to the projects to build - can be a .csproj or a .sln file | **true** |
| `verbosity` | The verbosity of the dotnet CLI | *false* | `minimal` |
| `azureCredentials` | Azure credentials, typically get from secrets.AZURE_CREDENTIALS | **true** |
| `applicationName` | The application name, as defined on Azure | **true** |
| `projectsToPublishPath` | The path of the projects to publish, relative to the checkout path | **true** |
| `healthUrl` | The absolute URL of the health endpoint, from the Functions application | **true** |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
