# Readme - release/nuget

## Introduction

`milochaucom/github-actions/release/nuget` is a GitHub Action developed to pack .NET libraries as NuGet packages, publish them into GitHub Packages, and create a custom Release in the GitHub repository.

---

## Usage

Use this GitHub action if you want have one or many .NET libraries that you want to build, pack and publish.

### Example workflow

```yaml
name: My Workflow
on: workflow_dispatch
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@main
    - name: Manage release
      # Reference the current GitHub Action
      uses: milochaucom/github-actions/release/nuget@main
      # Reference the Action variables
      with:
        test: true
```

### Inputs

| Input | Description | Required | Default value |
| ----- | ----------- | -------- | ------------- |
| `dotnetVersion` | The .NET SDK version to install | **true** |
| `nugetUrl` | The URL of the NuGet feed | **true** |
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

### Using the optional input

This is how to use the optional input.

```yaml
with:
  test: true
```

### Using outputs

Show people how to use your outputs in another action.

```yaml
steps:
- uses: actions/checkout@main
- name: Manage release
  id: actions_release
    uses: milochaucom/github-actions/release/nuget@main
  with:
    test: true

# Use outputs here 
- name: Check outputs
    run: |
    echo "Outputs - ${{ steps.actions_release.outputs.testOutput }}"
```
