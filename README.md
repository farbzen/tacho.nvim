<div align="center">

# tacho.nvim

_A speedometer for your typing – words per minute in Neovim, live and all-time._

[![Version](https://img.shields.io/badge/version-0.2.0-blue?style=for-the-badge&labelColor=081216)](CHANGELOG.md)
[![Neovim](https://img.shields.io/badge/Neovim-0.10%2B-57A143?style=for-the-badge&labelColor=081216&logo=neovim&logoColor=white)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&labelColor=081216&logo=lua&logoColor=white)](https://www.lua.org)
[![License: MIT](https://img.shields.io/badge/license-MIT-B0BFC9?style=for-the-badge&labelColor=081216)](LICENSE)
[![Ko-Fi donate](https://img.shields.io/badge/donate-kofi?style=for-the-badge&labelColor=081216&color=ee5556&logo=ko-fi&logoColor=white)](https://ko-fi.com/farbzen)

[Overview](#overview) • [Features](#features) •
[Getting Started](#getting-started) • [Documentation](#documentation)

</div>

tacho.nvim is a Neovim plugin for everyone who wants to know how fast they
really type while coding or writing. It shows your current pace and an
all-time average in words per minute – right in the statusline, without
leaving the editor or running a separate typing test.

## Overview

The plugin listens to characters typed in insert mode, counts only active
typing time and converts characters to words using the standard definition of
five characters per word. The all-time average survives restarts and can be
reset at any time; the live value follows your current pace.

The repository consists of the following parts:

- **Core** – measurement, persistence and Lua API, written in
  [Lua](https://www.lua.org). The code lives in `lua/tacho/`.
- **`:Tacho` command** – show, save and reset statistics, plus autostart. The
  code lives in `plugin/tacho.lua`.
- **lualine component** – ready-made statusline element for
  [lualine](https://github.com/nvim-lualine/lualine.nvim). The code lives in
  `lua/lualine/components/tacho.lua`.
- **Vim help** – `:help tacho`. The file lives in `doc/tacho.txt`.

## Features

- **Live WPM**: current pace over a sliding window, decays to zero when you pause.
- **All-time average**: persisted in Neovim's cache directory across sessions.
- **Resettable**: `:Tacho reset` clears memory and cache file at any time.
- **Fast reads**: getters only do arithmetic on in-memory values – safe for every redraw.
- **Idle-aware**: pauses longer than the idle timeout and time outside insert mode are ignored.
- **Multi-instance safe**: parallel Neovim instances merge their data instead of overwriting it.
- **Flexible statusline text**: a template with named variables such as `{live_wpm}` and `{wpm}`.
- **Zero config**: works without calling `setup()`.

## Getting Started

### Prerequisites

- [Neovim](https://neovim.io) 0.10 or newer
- Optional: [lualine](https://github.com/nvim-lualine/lualine.nvim) for the
  ready-made statusline component

### Installation

Install it with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "farbzen/tacho.nvim",
  lazy = false,
  opts = {},
}
```

> [!TIP]
> Load the plugin eagerly (`lazy = false`) – lualine cannot find the component
> of a plugin that has not been loaded yet. The plugin is tiny and only
> registers three autocommands.

### Usage

Tracking starts automatically. The `:Tacho` command shows and manages the
statistics:

| Command        | Effect                                    |
| -------------- | ----------------------------------------- |
| `:Tacho`       | Show average, live WPM and totals.        |
| `:Tacho save`  | Write pending data to the cache file now. |
| `:Tacho reset` | Reset all statistics (`!` skips confirm). |

Add the values to the lualine statusline:

```lua
require("lualine").setup({
  sections = { lualine_x = { "tacho" } },
})
```

This shows e.g. `󰼭 58` – the all-time average (the icon requires a
[Nerd Font](https://www.nerdfonts.com/)). Other
statuslines can use `require("tacho").statusline()`,
`require("tacho").live_wpm()` and `require("tacho").wpm()`.

The most important options with their defaults:

```lua
require("tacho").setup({
  idle_timeout_ms = 1000,
  live_window_ms = 10000,
  statusline_format = "󰼭 {wpm}",
})
```

`statusline_format` accepts the variables `{live_wpm}`, `{wpm}` and
`{characters}`.

> [!NOTE]
> Pasted text and accepted completions are not counted, and deletions are not
> subtracted (gross WPM). See [docs/measurement.md](docs/measurement.md).

## Documentation

- [Configuration and API](docs/configuration.md) – all options and the Lua API
- [Measurement](docs/measurement.md)
- [Development](docs/development.md) – environment, tests, code quality and
  project layout
- Vim help: `:help tacho`
- [Changelog](CHANGELOG.md)

## License

See [LICENSE](LICENSE).
