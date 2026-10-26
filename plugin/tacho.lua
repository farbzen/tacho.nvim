if vim.g.loaded_tacho then
  return
end
vim.g.loaded_tacho = true

local subcommands = {
  show = function()
    local stats = require("tacho").stats()
    vim.notify(
      string.format(
        "tacho: Ø %d wpm, live %d wpm (%d characters in %.1f s active typing)",
        stats.wpm,
        stats.live_wpm,
        stats.characters,
        stats.active_seconds
      ),
      vim.log.levels.INFO
    )
  end,
  reset = function(command)
    local confirmed = command.bang
      or vim.fn.confirm("Reset tacho WPM statistics?", "&Yes\n&No", 2) == 1
    if not confirmed then
      return
    end
    if require("tacho").reset() then
      vim.notify("tacho: statistics reset", vim.log.levels.INFO)
    else
      vim.notify("tacho: could not write cache file", vim.log.levels.ERROR)
    end
  end,
  save = function()
    if not require("tacho").save() then
      vim.notify("tacho: could not write cache file", vim.log.levels.ERROR)
    end
  end,
}

vim.api.nvim_create_user_command("Tacho", function(command)
  local name = command.fargs[1] or "show"
  local subcommand = subcommands[name]
  if not subcommand then
    vim.notify("tacho: unknown subcommand '" .. name .. "'", vim.log.levels.ERROR)
    return
  end
  subcommand(command)
end, {
  nargs = "?",
  bang = true,
  desc = "Show, save or reset tacho WPM statistics",
  complete = function(argument_lead)
    local matches = vim.tbl_filter(function(name)
      return vim.startswith(name, argument_lead)
    end, vim.tbl_keys(subcommands))
    table.sort(matches)
    return matches
  end,
})

require("tacho").start()
