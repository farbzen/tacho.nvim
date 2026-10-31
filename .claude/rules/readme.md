# README handling

- Consider the entire project within the repository and write a `README.md`
  that gives a complete overview of it (all apps, features, getting started,
  key commands) while staying concise.
- Details such as complete lists of environment variables, interface
  protocols, test and tooling details, or operations and emergency runbooks
  belong in separate files under `docs/` and are only linked from the README.
  If none fits, create a new file under `docs/` and link it under
  "Documentation"; subprojects with their own README (e.g. `examples/*`) keep
  their details there.
- If a `README.md` already exists that goes beyond a bare template (example:
  the content is limited to "# TEMPLATE"), extend the existing `README.md` with
  new apps, commands and references; put details in the matching file under
  `docs/`.
- Since `LICENSE`, `CHANGELOG` and `CONTRIBUTING` are covered in their own
  files, at most link to these files.

## README structure

Distilled from these role models:

- Azure-Samples/serverless-chat-langchainjs
- Azure-Samples/serverless-recipes-javascript
- sinedied/run-on-output
- sinedied/smoke

## What the role models have in common

- **Centered header**: title, one-sentence tagline, badges, jump navigation
  (`[Overview](#overview) • [Getting Started](#getting-started) • …`).
- **One paragraph right after the header** stating what the project is and who
  it is for.
- **Overview with a component list**: one bullet per component with its
  technology (linked) and directory (`The code lives in packages/api`).
- **Features** as bold keywords with a half-sentence of benefit.
- **Getting Started** with prerequisites and several ways into the development
  environment, followed by **Run/Usage** with copyable command blocks.
- **GitHub alert boxes** (`> [!TIP]`, `> [!NOTE]`, `> [!IMPORTANT]`) for
  pitfalls instead of prose.
- **Resources / Troubleshooting / Getting Help** at the end, Contributing and
  License only as a short reference.

## Outline for this monorepo

Omit sections that have no content in the repo instead of padding them with
filler sentences.

~~~md
<div align="center">

# <Project name>

_<One-sentence tagline>_

[![Version](https://img.shields.io/badge/version-<X.Y.Z>-blue?style=flat-square)](CHANGELOG.md)
<!-- further badges only for technologies actually used -->

[Overview](#overview) • [Getting Started](#getting-started) • [Applications](#applications) • [Development](#development) • [Documentation](#documentation)

</div>

<One paragraph: what the project is, who it is for, which problem it solves.>

## Overview

<What the project is for, one or two paragraphs.>

The monorepo consists of the following applications:

- **<app>** – <purpose>, built with [<technology>](<url>). The code lives in `<directory>/`.
- …

## Features

- **<Keyword>**: <benefit in half a sentence>.

## Getting Started

### Prerequisites

- [devenv](https://devenv.sh) (provides Python, Node, MariaDB …)

### Development environment

```sh
git clone <repo>
cd <repo>
devenv shell
```

> [!TIP]
> <Pitfall or shortcut, if any>

## Applications

### <app>

<Purpose, how to start, only the most important configuration; details linked to docs/>

```sh
<start command>
```

## Development

### Tests

```sh
<test command per app>
```

### Code quality

<Linter/formatter/type checking with commands, from ruff.toml, pyrightconfig.json etc.>

### API documentation

<e.g. Doxygen, OpenAPI at /docs – only if present>

## Deployment

<Short description and link to docs/deployment.md – do not remove this
section, messages of the deploy scripts refer to "README (section
Deployment)">

## Documentation

- [<Topic>](docs/<file>.md)
- [Architecture Decision Records](docs/adr/)
- [Changelog](CHANGELOG.md)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

See [LICENSE](LICENSE).
~~~

## Notes

- **Changelog, Contributing, License** live in their own files. Only link them
  from the README – copied content drifts apart otherwise. If one of the files
  does not exist, omit the reference.
- **Commands** only if they can be backed by the repo (`devenv.nix`,
  `pyproject.toml`, `package.json`, `pytest.ini`, …).
- **Badges** only for facts stated in the repo (version from `/version`,
  languages/frameworks in use). No build badges without a known CI URL.
- **Images/logos** only if the file exists (e.g. under `.assets/`).
