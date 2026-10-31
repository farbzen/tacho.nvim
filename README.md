<div align="center">

# tacho.nvim

_A speedometer for your typing – words per minute in Neovim, live and all-time._

[![Version](https://img.shields.io/badge/version-0.1.0-blue?style=flat-square)](CHANGELOG.md)
[![Neovim](https://img.shields.io/badge/Neovim-0.10%2B-57A143?style=flat-square&logo=neovim&logoColor=white)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-2C2D72?style=flat-square&logo=lua&logoColor=white)](https://www.lua.org)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)

[Overview](#overview) • [Getting Started](#getting-started) • [Applications](#applications) • [Documentation](#documentation)

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
- **Zero config**: works without calling `setup()`.

## Getting Started

### Prerequisites

- [Neovim](https://neovim.io) 0.10 or newer
- [devenv](https://devenv.sh) for development (provides Neovim, StyLua,
  selene and lua-language-server)

### Development environment

```sh
git clone git@github.com:farbzen/tacho.nvim.git
cd tacho.nvim
devenv shell
```

The shell provides the scripts `run-tests`, `lint` and `format`; details are
in [docs/development.md](docs/development.md).

> [!TIP]
> With [direnv](https://direnv.net) installed, `direnv allow` loads the
> environment automatically via the included `.envrc`.

## Applications

### Plugin

Install it with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "farbzen/tacho.nvim",
  lazy = false,
  opts = {},
}
```

Tracking starts automatically. The `:Tacho` command shows and manages the
statistics:

| Command        | Effect                                    |
| -------------- | ----------------------------------------- |
| `:Tacho`       | Show average, live WPM and totals.        |
| `:Tacho save`  | Write pending data to the cache file now. |
| `:Tacho reset` | Reset all statistics (`!` skips confirm). |

The most important options with their defaults:

```lua
require("tacho").setup({
  idle_timeout_ms = 5000,
  live_window_ms = 10000,
  statusline_format = "%d wpm (Ø %d)",
})
```

All options and the full Lua API are listed in
[docs/configuration.md](docs/configuration.md).

> [!NOTE]
> Pasted text and accepted completions are not counted, and deletions are not
> subtracted (gross WPM). See [docs/measurement.md](docs/measurement.md).

### lualine component

Adds the values to the [lualine](https://github.com/nvim-lualine/lualine.nvim)
statusline:

```lua
require("lualine").setup({
  sections = { lualine_x = { "tacho" } },
})
```

This shows e.g. `72 wpm (Ø 58)` – live value and all-time average. Other
statuslines can use `require("tacho").live_wpm()` and `require("tacho").wpm()`.

> [!TIP]
> Load the plugin eagerly (`lazy = false`) – lualine cannot find the component
> of a plugin that has not been loaded yet. The plugin is tiny and only
> registers three autocommands.

## Documentation

- [Configuration and API](docs/configuration.md)
- [Measurement](docs/measurement.md)
- [Development](docs/development.md) – environment, tests and code quality
- Vim help: `:help tacho`
- [Changelog](CHANGELOG.md)

## License

See [LICENSE](LICENSE).
