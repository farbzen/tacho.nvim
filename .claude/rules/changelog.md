# Changelog

- Every change to the code of the application(s) must be recorded in the
  changelog at `/CHANGELOG.md` with entries that reflect the substance of the
  change. The application code usually lives in one of the following
  directories:
  - `/src*`
  - `/app*`
  - `/backend*`
  - `/database*`
  - `/frontend*`
  - `/cli*`

- Changes that only affect the development environments or the repository
  itself are exempt from the changelog. Examples are changes in the following
  directories:
  - `/` (files at the root level)
  - `/.assets` (assets for rendering the README.md)
  - `/.claude` (Claude Code)
  - `/.gitlab` (GitLab)
  - `/.vscode` (Visual Studio Code)
  - `/docs` (documentation)

- Guiding principles:
  - Changelogs are for humans, not machines.
  - There should be an entry for every single version.
  - Changes of the same type should be grouped.
  - Versions and sections should be linkable.
  - The latest version comes first.
  - The release date of each version must be stated.
  - State whether you follow Semantic Versioning.

  - Types of changes
    - `Added` for new features.
    - `Changed` for changes in existing functionality.
    - `Deprecated` for features that will be removed in upcoming versions.
    - `Removed` for deprecated features removed in this version.
    - `Fixed` for any bug fixes.
    - `Security` to urge users to upgrade in case of fixed vulnerabilities.

  - Keep changes not yet assigned to a new version in a dedicated `Unreleased`
    section.
