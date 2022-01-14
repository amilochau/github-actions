# Readme - build/netcore

## Introduction

`amilochau/github-actions/build/netcore` is a GitHub Action developed to build and test .NET Core projects.

---

## Usage

Use this GitHub action if you want have one or many .NET Core projects that you want to build and test, typically in a Continuous Integration process.

### Example workflow

```yaml
name: Build

on: workflow_dispatch

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@main
      - name: Setup .NET Core
        uses: actions/setup-dotnet@v1
        with:
          dotnet-version: ${{ env.DOTNET_VERSION }}
      - name: Build and test projects
        uses: amilochau/github-actions/build/netcore@v1
        with:
          projectsToBuild: ${{ env.PROJECTS_BUILD }}
          projectsToTest: ${{ env.PROJECTS_TESTS }}
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `projectsToBuild` | The path to the projects to build - can be a .csproj or a .sln file | **true** |
| `projectsToTest` | The path to the projects to test - can be a .csproj or a .sln file | **true** |
| `verbosity` | The verbosity of the dotnet CLI | *false* | `minimal` |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
