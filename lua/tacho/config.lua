local M = {}

function M.defaults()
  return {
    idle_timeout_ms = 5000,
    live_window_ms = 10000,
    save_interval_ms = 30000,
    cache_path = vim.fn.stdpath("cache") .. "/tacho.json",
    statusline_format = "%d wpm (Ø %d)",
  }
end

M.options = M.defaults()

function M.apply(user_options)
  M.options = vim.tbl_deep_extend("force", M.defaults(), user_options or {})
  return M.options
end

return M
