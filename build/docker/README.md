# Readme - build/docker

## Introduction

`amilochau/github-actions/build/docker` is a GitHub Action developed to build a Docker application.

---

## Usage

Use this GitHub action if you want have an application defined with a Dockerfile that you want to build, typically in a Continuous Integration process.

### Example workflow

```yaml
name: Build

on: workflow_dispatch

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build application
        uses: amilochau/github-actions/build/docker@v3
        with:
          context: ${{ env.DOCKER_IMAGE_CONTEXT }}
          dockerfile: ${{ env.DOCKER_FILE }}
          dockerRegistryUsername: ${{ github.actor }}
          dockerRegistryPassword: ${{ github.token }}
          dockerImageName: ${{ env.DOCKER_IMAGE_NAME }}
          dockerImageTag: ${{ github.sha }}
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `context` | The path of the context where to build | **true** |
| `dockerfile` | The path of the Dockerfile | **true** |
| `dockerRegistryHost` | The host of the Docker registry |*false* | `ghcr.io/` | Should end with a leading slash |
| `dockerRegistryUsername` |The username to login to Docker registry | **true** |
| `dockerRegistryPassword` | The password to login to Docker registry | **true** |
| `dockerImageName` | The name of the Docker image | **true** | 
| `dockerImageTag` | The tag of the Docker image | **true** | 
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
