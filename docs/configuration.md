# Configuration and API

## Options

`require("tacho").setup(opts)` is optional; the plugin starts with the defaults
below as soon as it is loaded. Calling `setup()` again saves pending data and
restarts tracking with the new options.

| Option              | Default                                 | Description                                                                 |
| ------------------- | --------------------------------------- | --------------------------------------------------------------------------- |
| `idle_timeout_ms`   | `5000`                                  | Gaps between keystrokes longer than this are not counted as typing time.    |
| `live_window_ms`    | `10000`                                 | Length of the sliding window for the live value.                            |
| `save_interval_ms`  | `30000`                                 | Minimum time between automatic saves on `InsertLeave`.                      |
| `cache_path`        | `stdpath("cache") .. "/tacho.json"`     | File the all-time statistics are persisted in.                              |
| `statusline_format` | `"%d wpm (Ø %d)"`                       | `string.format` pattern for `statusline()`; arguments: live WPM, average.   |

## Lua API

| Function                         | Returns                                                                   |
| -------------------------------- | ------------------------------------------------------------------------- |
| `require("tacho").wpm()`         | All-time average WPM (integer), persisted across sessions.                |
| `require("tacho").live_wpm()`    | Current WPM over the live window (integer), `0` when idle.                |
| `require("tacho").statusline()`  | Formatted string for a statusline.                                        |
| `require("tacho").stats()`       | Table with `wpm`, `live_wpm`, `characters`, `active_seconds`.             |
| `require("tacho").save()`        | Merges pending data into the cache file; `true` on success.               |
| `require("tacho").reset()`       | Clears all statistics in memory and in the cache file; `true` on success. |

All getters only do arithmetic on values kept in memory, so they are cheap
enough to be called on every statusline redraw.

## Commands

| Command         | Effect                                      |
| --------------- | ------------------------------------------- |
| `:Tacho [show]` | Print average, live WPM and totals.         |
| `:Tacho save`   | Write pending data to the cache file now.   |
| `:Tacho reset`  | Reset all statistics after a confirmation.  |
| `:Tacho! reset` | Reset all statistics without confirmation.  |

## Statusline examples

lualine (built-in component):

```lua
require("lualine").setup({
  sections = { lualine_x = { "tacho" } },
})
```

lualine with a custom function:

```lua
lualine_x = { function() return require("tacho").live_wpm() .. " wpm" end }
```

Native statusline:

```lua
vim.o.statusline = "%f %= %{v:lua.require'tacho'.statusline()}"
```
