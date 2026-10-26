local M = {}

function M.empty()
  return { chars = 0, active_ns = 0 }
end

function M.read(path)
  local file = io.open(path, "r")
  if not file then
    return M.empty()
  end
  local content = file:read("*a")
  file:close()
  local decoded_ok, decoded = pcall(vim.json.decode, content)
  if not decoded_ok or type(decoded) ~= "table" then
    return M.empty()
  end
  return {
    chars = tonumber(decoded.chars) or 0,
    active_ns = tonumber(decoded.active_ns) or 0,
  }
end

function M.write(path, totals)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local temporary_path = string.format("%s.%d.tmp", path, vim.uv.os_getpid())
  local file = io.open(temporary_path, "w")
  if not file then
    return false
  end
  file:write(vim.json.encode({ chars = totals.chars, active_ns = totals.active_ns }))
  file:close()
  if not vim.uv.fs_rename(temporary_path, path) then
    os.remove(temporary_path)
    return false
  end
  return true
end

function M.merge(path, pending_totals)
  local stored = M.read(path)
  local merged = {
    chars = stored.chars + pending_totals.chars,
    active_ns = stored.active_ns + pending_totals.active_ns,
  }
  if M.write(path, merged) then
    return merged
  end
  return nil
end

return M
