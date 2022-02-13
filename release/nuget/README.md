# Readme - release/nuget

## Introduction

`amilochau/github-actions/release/nuget` is a GitHub Action developed to pack .NET libraries as NuGet packages, publish them into GitHub Packages and nuget.org, and create a custom Release in the GitHub repository.

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
      - uses: actions/checkout@v2
      - name: Deploy libraries
        uses: amilochau/github-actions/release/nuget@v1
        with:
          projectsToBuild: ${{ env.PROJECTS_BUILD }}
          projectsToPublish: ${{ env.PROJECTS_SDK }}
          dotnetVersion: ${{ env.DOTNET_VERSION }}
          githubPackagesUrl: ${{ env.NUGET_URL }}
          versionFile: ${{ env.VERSION_FILE }}
          githubToken: ${{ secrets.GITHUB_TOKEN }}
          avoidGitHubPrerelease: true
          generateReleaseNotes: true
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `versionFile` | The path to the file where the version can be found - must be an XML file | **true** |
| `projectsToBuild` | The path to the projects to build - can be a .csproj or a .sln file | **true** |
| `projectsToPublish` | The path to the projects to publish - can be a .csproj or a .sln file | **true** |
| `dotnetVersion` | The .NET version to use | *false* | `''` | If you don't specify this, you should use your own `actions/setup-dotnet` task before |
| `githubPackagesUrl` | The GitHub Packages URL where to push packages | *false* | `''` | If you don't specify this, you should use your own `actions/setup-dotnet` task before |
| `githubToken` | The GitHub token, typically get from `secrets.GITHUB_TOKEN` | **true** |
| `avoidGitHubPrerelease` | Disable GitHub Release creation for unstable version | *false* | `false` |
| `generateReleaseNotes` | Generate automatic release notes |  *false* | `false` |
| `nugetOrgToken` | The nuget.org token, typically get from a secret; used to publish projects to nuget.org | *false* | `''` |
| `mainBranch` | The name of the main branch | *false* | `refs/heads/main` |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |
| `versionNumber` | The version as defined in the Git tag |
| `versionPrerelease` | If the version is recognized as a prerelease |
