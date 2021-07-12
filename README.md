# Readme - actions-release

## Introduction

`actions-release` is a GitHub Action developed to manage GitHub release.

## Getting Started

1. Installation process
From your local computer, clone the repository.

- dotnet restore
- dotnet run

2. Integration process
Please follow the development good practices, then follow the integration process.

---

## Usage

Describe how to use your action here.

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
      uses: milochaucom/actions-release/generic@main
      # Reference the Action variables
      with:
        test: true
```

### Inputs

| Input | Description |
|-------|-------------|
| `test` | A test input |

### Outputs

| Output | Description |
|--------|-------------|
| `testOutput` | A test output |

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
  uses: milochaucom/actions-release/generic@main
  with:
    test: true

# Use outputs here 
- name: Check outputs
    run: |
    echo "Outputs - ${{ steps.actions_release.outputs.testOutput }}"
```
