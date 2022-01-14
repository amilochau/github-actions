# Readme - build/node

## Introduction

`amilochau/github-actions/build/node` is a GitHub Action developed to build and test Node.js projects.

---

## Usage

Use this GitHub action if you want have a Node.js projects that you want to build and test, typically in a Continuous Integration process.

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
      - name: Build and test projects
        uses: amilochau/github-actions/build/node@v1
        with:
          projectWorkspace: ${{ env.PROJECT_WORKSPACE }}
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `projectWorkspace` | The path to the project to build | *false* | `.` |
| `nodeVersion` | The Node.js version to use | *false* | `16.x` |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
