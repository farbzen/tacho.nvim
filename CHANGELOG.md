# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-10-31

### Added

- Typing speed measurement in words per minute (5 characters = 1 word, gross)
  based on characters typed in insert mode, counting only active typing time
  with a configurable idle timeout.
- Live WPM value over a sliding window that decays during pauses.
- All-time average persisted in `stdpath("cache")/tacho.json`, merged safely
  across several running Neovim instances.
- Lua API `wpm()`, `live_wpm()`, `stats()`, `statusline()`, `save()`,
  `reset()` and `setup()`.
- Configurable `statusline_format` template with the named variables
  `{live_wpm}`, `{wpm}` and `{characters}`.
- `:Tacho` command with `show`, `save` and `reset` (`:Tacho! reset` skips the
  confirmation).
- lualine component `tacho`.
- Vim help file `:help tacho`.

[Unreleased]: https://github.com/farbzen/tacho.nvim/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/farbzen/tacho.nvim/releases/tag/v0.1.0
