# Readme - github-actions

## Introduction

`github-actions` is a set of GitHub Actions developed to help defining workflows for `amilochau` projects.

## What's new

You can find the new releases on the [GitHub releases page](https://github.com/amilochau/github-actions/releases).

---

## Actions

The following actions are proposed, and can be freely used:

| Path | Usage | Readme |
| ---- | ----- | ------ |
| `build/netcore` | Build and Test .NET projects | [README.md](./build/netcore/README.md) |
| `build/node` | Build and Test Node.js projects | [README.md](./build/node/README.md) |
| `deploy/functions` | Deploy Azure Functions applications | [README.md](./deploy/functions/README.md) |
| `deploy/infrastructure` | Deploy Azure infrastructure | [README.md](./deploy/infrastructure/README.md) |
| `deploy/static-web-apps` | Deploy Static Web Apps applications | [README.md](./deploy/static-web-apps/README.md) |
| `release/basic` | Create complete GitHub Releases with a simple process | [README.md](./release/basic/README.md) |
| `release/npm` | Release Node.js libraries as npm packages into npmjs.com and GitHub Packages | [README.md](./release/npm/README.md) |
| `release/nuget` | Release .NET libraries as NuGet packages into nuget.org and GitHub Packages | [README.md](./release/nuget/README.md) |

*Note that all actions must start with the prefix `amilochau/github-actions/`*
