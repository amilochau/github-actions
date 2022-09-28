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
      - uses: actions/checkout@v3
      - name: Build and test projects
        uses: amilochau/github-actions/build/node@v3
        with:
          projectWorkspace: ${{ env.PROJECT_WORKSPACE }}
```

### Inputs

| Input | Description | Required | Default value | Comment |
| ----- | ----------- | -------- | ------------- | ------- |
| `projectWorkspace` | The path to the project to build | *false* | `.` |
| `nodeVersion` | The Node.js version to use | *false* | `16.x` |
| `npmBuildScript` | The npm script to run, to build the application | *false* | `build` |
| `npmLintScript` | The npm script to run, to lint the application | *false* | `''` |
| `relativeOutputPath` | The path to the output of the build project | *false* | `./dist` |
| `verbosity` | The verbosity of the scripts | *false* | `minimal` | Set to `minimal`, `normal` or `detailed` |

### Outputs

| Output | Description |
| ------ | ----------- |

*No output is defined in the current GitHub Action...*
