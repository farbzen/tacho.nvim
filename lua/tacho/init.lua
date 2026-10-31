local config = require("tacho.config")
local storage = require("tacho.storage")
local Tracker = require("tacho.tracker")

local NANOSECONDS_PER_MILLISECOND = 1e6

local M = {}

local tracker = nil
local last_save_ns = 0

local function round(value)
  return math.floor(value + 0.5)
end

local function save_if_due()
  local due_ns = last_save_ns + config.options.save_interval_ms * NANOSECONDS_PER_MILLISECOND
  if vim.uv.hrtime() >= due_ns then
    M.save()
  end
end

local function register_autocommands()
  local group = vim.api.nvim_create_augroup("Tacho", { clear = true })
  vim.api.nvim_create_autocmd("InsertCharPre", {
    group = group,
    callback = function()
      tracker:record(vim.uv.hrtime())
    end,
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      tracker:break_burst()
      save_if_due()
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      M.save()
    end,
  })
end

function M.setup(user_options)
  if tracker then
    M.save()
  end
  local options = config.apply(user_options)
  tracker = Tracker.new(options)
  tracker:commit(storage.read(options.cache_path))
  last_save_ns = vim.uv.hrtime()
  register_autocommands()
end

function M.start()
  if not tracker then
    M.setup()
  end
end

function M.save()
  M.start()
  local merged = storage.merge(config.options.cache_path, tracker:pending_totals())
  if merged then
    tracker:commit(merged)
  end
  last_save_ns = vim.uv.hrtime()
  return merged ~= nil
end

function M.reset()
  M.start()
  tracker:reset()
  return storage.write(config.options.cache_path, storage.empty())
end

function M.wpm()
  M.start()
  return round(tracker:average())
end

function M.live_wpm()
  M.start()
  return round(tracker:live(vim.uv.hrtime()))
end

function M.stats()
  M.start()
  local totals = tracker:totals()
  return {
    wpm = M.wpm(),
    live_wpm = M.live_wpm(),
    characters = totals.chars,
    active_seconds = totals.active_ns / 1e9,
  }
end

function M.statusline()
  local stats = M.stats()
  local variables = {
    live_wpm = tostring(stats.live_wpm),
    wpm = tostring(stats.wpm),
    characters = tostring(stats.characters),
  }
  return (config.options.statusline_format:gsub("{([%w_]+)}", variables))
end

return M
