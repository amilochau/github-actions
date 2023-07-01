<p align="center">
  <a href="https://github.com/amilochau/github-actions/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/amilochau/github-actions" alt="License">
  </a>
  <a href="https://github.com/amilochau/github-actions/releases">
    <img src="https://img.shields.io/github/v/release/amilochau/github-actions" alt="Release">
  </a>
</p>
<h1 align="center">
  amilochau/github-actions
</h1>

`github-actions` is a set of GitHub Actions developed to help defining workflows for `amilochau` projects.

## What's new

You can find the new releases on the [GitHub releases page](https://github.com/amilochau/github-actions/releases).

---

## Actions

The following actions are proposed, and can be freely used:

| Path | Usage | Readme |
| ---- | ----- | ------ |
| `clean/artifacts` | Clean GitHub Actions artifacts | [README.md](./clean/artifacts/README.md) |
| `build/netcore` | Build and Test .NET projects | [README.md](./build/netcore/README.md) |
| `build/node` | Build and Test Node.js projects | [README.md](./build/node/README.md) |
| `build/docker` | Build a Docker application | [README.md](./build/docker/README.md) |
| `build/lambda-functions` | Build AWS Lambda functions | [README.md](./build/lambda-functions/README.md) |
| `build/terraform` | Build Terraform modules | [README.md](./build/terraform/README.md) |
| `deploy/functions` | Deploy Azure Functions applications | [README.md](./deploy/functions/README.md) |
| `deploy/infrastructure` | Deploy Azure infrastructure | [README.md](./deploy/infrastructure/README.md) |
| `deploy/static-web-apps` | Deploy Static Web Apps applications | [README.md](./deploy/static-web-apps/README.md) |
| `deploy/web` | Deploy Web applications | [README.md](./deploy/web/README.md) |
| `release/basic` | Create complete GitHub Releases with a simple process | [README.md](./release/basic/README.md) |
| `release/npm` | Release Node.js libraries as npm packages into npmjs.com and GitHub Packages | [README.md](./release/npm/README.md) |
| `release/nuget` | Release .NET libraries as NuGet packages into nuget.org and GitHub Packages | [README.md](./release/nuget/README.md) |

*Note that all actions must start with the prefix `amilochau/github-actions/`*

--- 

## Contribute

Feel free to push your code if you agree with publishing under the [MIT license](./LICENSE).
