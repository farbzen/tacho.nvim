# Development

## Prerequisites

- [devenv](https://devenv.sh) – provides Neovim, StyLua, selene and
  lua-language-server

## Development environment

```sh
git clone git@github.com:farbzen/tacho.nvim.git
cd tacho.nvim
devenv shell
```

## Tests

```sh
run-tests
```

The tests in `tests/run.lua` run in a clean headless Neovim
(`nvim --clean -l`). The cache directory points to `$DEVENV_STATE/test-cache`,
so the real statistics in `stdpath("cache")` stay untouched.

## Code quality

```sh
lint      # stylua --check and selene on lua/, plugin/ and tests/
format    # stylua on lua/, plugin/ and tests/
```

Formatting rules live in `stylua.toml`, linter rules in `selene.toml` and
`vim.yml`.

## Project layout

| Path                               | Content                                         |
| ---------------------------------- | ----------------------------------------------- |
| `lua/tacho/init.lua`               | Public Lua API and autocommands                 |
| `lua/tacho/tracker.lua`            | Keystroke bursts, active time and live window   |
| `lua/tacho/storage.lua`            | Cache file reading, merging and atomic writes   |
| `lua/tacho/config.lua`             | Defaults and option handling                    |
| `lua/lualine/components/tacho.lua` | lualine component                               |
| `plugin/tacho.lua`                 | `:Tacho` command and autostart                  |
| `doc/tacho.txt`                    | Vim help file                                   |
| `tests/run.lua`                    | Test suite                                      |
