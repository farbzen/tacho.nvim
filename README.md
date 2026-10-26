<div align="center">

# tacho.nvim

_A speedometer for your typing – words per minute in Neovim, live and all-time._

[![Version](https://img.shields.io/badge/version-0.1.0-blue?style=flat-square)](CHANGELOG.md)
[![Neovim](https://img.shields.io/badge/Neovim-0.10%2B-57A143?style=flat-square&logo=neovim&logoColor=white)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-2C2D72?style=flat-square&logo=lua&logoColor=white)](https://www.lua.org)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)

[Overview](#overview) • [Getting Started](#getting-started) • [Usage](#usage) • [Development](#development) • [Documentation](#documentation)

</div>

tacho.nvim measures how fast you type in Neovim. It keeps an all-time average
in words per minute that survives restarts and can be reset at any time, plus
a live value of your current pace. Both are cheap to read, so they fit into
statuslines such as [lualine](https://github.com/nvim-lualine/lualine.nvim).

## Overview

The plugin listens to characters typed in insert mode, counts only active
typing time and converts characters to words using the standard definition of
five characters per word. The code lives in `lua/tacho/`, the command and
autostart in `plugin/tacho.lua`, the lualine component in
`lua/lualine/components/tacho.lua`.

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

### Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "farbzen/tacho.nvim",
  lazy = false,
  opts = {},
}
```

> [!TIP]
> The plugin is tiny and only registers three autocommands. Load it eagerly
> when you use the lualine component `"tacho"` – lualine cannot find the
> component of a plugin that has not been loaded yet.

## Usage

### Statusline

```lua
require("lualine").setup({
  sections = { lualine_x = { "tacho" } },
})
```

This shows e.g. `72 wpm (Ø 58)` – live value and all-time average. The
values are also available as `require("tacho").live_wpm()` and
`require("tacho").wpm()`.

### Commands

| Command         | Effect                                     |
| --------------- | ------------------------------------------ |
| `:Tacho`        | Show average, live WPM and totals.         |
| `:Tacho save`   | Write pending data to the cache file now.  |
| `:Tacho reset`  | Reset all statistics (`!` skips confirm).  |

### Configuration

```lua
require("tacho").setup({
  idle_timeout_ms = 5000,
  live_window_ms = 10000,
  statusline_format = "%d wpm (Ø %d)",
})
```

All options and the full Lua API are listed in
[docs/configuration.md](docs/configuration.md).

## Development

### Prerequisites

- [devenv](https://devenv.sh) (provides Neovim, StyLua, selene and lua-language-server)

```sh
git clone git@github.com:farbzen/tacho.nvim.git
cd tacho.nvim
devenv shell
```

### Tests

```sh
run-tests
```

### Code quality

```sh
lint      # stylua --check and selene
format    # stylua
```

## Documentation

- [Configuration and API](docs/configuration.md)
- [Measurement](docs/measurement.md)
- Vim help: `:help tacho`
- [Changelog](CHANGELOG.md)

## License

See [LICENSE](LICENSE).
