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
    permissions:
      contents: read # Required to checkout repository
      packages: read # Required to fetch NuGet packages
    steps:
      - uses: actions/checkout@v4
      - name: Build and test projects
        uses: amilochau/github-actions/build/netcore@v4
        with:
          projectsToBuild: ${{ env.PROJECTS_BUILD }}
          projectsToTest: ${{ env.PROJECTS_TESTS }}
          dotnetVersion: ${{ env.DOTNET_VERSION }}
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `projectsToBuild` | The path to the projects to build - can be a .csproj or a .sln file | **true** |
| `projectsToTest` | The path to the projects to test - can be a .csproj or a .sln file | **true** |
| `dotnetVersion` | The .NET version to use | *false* | `'9.0.x'` |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
