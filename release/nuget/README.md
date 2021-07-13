# Readme - release/nuget

## Introduction

`milochaucom/github-actions/release/nuget` is a GitHub Action developed to pack .NET libraries as NuGet packages, publish them into GitHub Packages, and create a custom Release in the GitHub repository.

---

## Usage

Use this GitHub action if you want have one or many .NET libraries that you want to build, pack and publish.

### Example workflow

```yaml
name: Deploy libraries

on: workflow_dispatch

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@main
      - name: Setup .NET Core
        uses: actions/setup-dotnet@v1
        with:
          dotnet-version: ${{ env.DOTNET_VERSION }}
          source-url: ${{ env.NUGET_URL }}
        env:
          NUGET_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - name: Deploy libraries
        uses: milochaucom/github-actions/release/nuget@main
        with:
          projectsToBuild: ${{ env.PROJECTS_BUILD }}
          projectsToPublish: ${{ env.PROJECTS_SDK }}
          versionFile: ${{ env.VERSION_FILE }}
```

### Inputs

| Input | Description | Required | Default value |
| ----- | ----------- | -------- | ------------- |
| `versionFile` | The path to the file where the version can be found - must be an XML file | **true** |
| `projectsToBuild` | The path to the projects to build - can be a .csproj or a .sln file | **true** |
| `projectsToPublish` | The path to the projects to publish - can be a .csproj or a .sln file | **true** |
| `mainBranch` | The name of the main branch | *false* | `refs/heads/main` |

### Outputs

| Output | Description |
| ------ | ----------- |
| `versionNumber` | The version as defined in the Git tag |
| `versionPrerelease` | If the version is recognized as a prerelease |

## Examples

```yaml
steps:
- uses: actions/checkout@main
- name: Setup .NET Core
  uses: actions/setup-dotnet@v1
  with:
    dotnet-version: ${{ inputs.dotnetVersion }}
    source-url: ${{ inputs.nugetUrl }}
  env:
    NUGET_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
- name: Deploy libraries
  id: actions_release
    uses: milochaucom/github-actions/release/nuget@main
  with:
    projectsToBuild: ${{ env.PROJECTS_BUILD }}
    projectsToPublish: ${{ env.PROJECTS_SDK }}
    versionFile: ${{ env.VERSION_FILE }}

# Use outputs here 
- name: Check outputs
    run: |
    echo "Version number: ${{ steps.actions_release.outputs.versionNumber }}"
```
