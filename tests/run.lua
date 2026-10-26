local repository_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:prepend(repository_root)
vim.o.showmode = false

local Tracker = require("tacho.tracker")
local storage = require("tacho.storage")
local tacho = require("tacho")

local MILLISECOND = 1e6
local SECOND = 1e9

local tests = {}

local function test(name, body)
  table.insert(tests, { name = name, body = body })
end

local function assert_equal(actual, expected, label)
  if actual ~= expected then
    error(
      string.format(
        "%s: expected %s, got %s",
        label or "value",
        tostring(expected),
        tostring(actual)
      ),
      2
    )
  end
end

local function assert_near(actual, expected, tolerance, label)
  if math.abs(actual - expected) > tolerance then
    error(string.format("%s: expected ~%s, got %s", label or "value", expected, actual), 2)
  end
end

local function new_tracker()
  return Tracker.new({ idle_timeout_ms = 5000, live_window_ms = 10000 })
end

local function type_burst(tracker, start_ns, keystrokes, interval_ns)
  for index = 0, keystrokes - 1 do
    tracker:record(start_ns + index * interval_ns)
  end
  return start_ns + (keystrokes - 1) * interval_ns
end

local function temporary_cache_path()
  return vim.fn.tempname() .. "/tacho.json"
end

local function write_raw(path, content)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local file = assert(io.open(path, "w"))
  file:write(content)
  file:close()
end

test("steady typing at 200 ms per keystroke yields 60 wpm", function()
  local tracker = new_tracker()
  type_burst(tracker, 0, 11, 200 * MILLISECOND)
  assert_equal(tracker:totals().chars, 10, "chars")
  assert_equal(tracker:totals().active_ns, 2 * SECOND, "active_ns")
  assert_near(tracker:average(), 60, 1e-9, "average")
end)

test("gaps longer than the idle timeout do not count as typing time", function()
  local tracker = new_tracker()
  local burst_end_ns = type_burst(tracker, 0, 11, 200 * MILLISECOND)
  type_burst(tracker, burst_end_ns + 10 * SECOND, 11, 200 * MILLISECOND)
  assert_equal(tracker:totals().chars, 20, "chars")
  assert_equal(tracker:totals().active_ns, 4 * SECOND, "active_ns")
  assert_near(tracker:average(), 60, 1e-9, "average")
end)

test("leaving insert mode ends the current burst", function()
  local tracker = new_tracker()
  local burst_end_ns = type_burst(tracker, 0, 11, 200 * MILLISECOND)
  tracker:break_burst()
  tracker:record(burst_end_ns + 100 * MILLISECOND)
  assert_equal(tracker:totals().chars, 10, "chars")
  assert_equal(tracker:totals().active_ns, 2 * SECOND, "active_ns")
end)

test("average is zero without any typing", function()
  assert_equal(new_tracker():average(), 0, "average")
end)

test("live wpm reflects the recent window", function()
  local tracker = new_tracker()
  local fast_end_ns = type_burst(tracker, 0, 51, 100 * MILLISECOND)
  local slow_end_ns = type_burst(tracker, fast_end_ns + 200 * MILLISECOND, 60, 200 * MILLISECOND)
  assert_near(tracker:live(slow_end_ns), 60, 1, "live")
  assert(tracker:average() > 60, "average includes the fast phase")
end)

test("live wpm decays while pausing and drops to zero after the idle timeout", function()
  local tracker = new_tracker()
  local burst_end_ns = type_burst(tracker, 0, 11, 200 * MILLISECOND)
  assert_near(tracker:live(burst_end_ns), 60, 1e-9, "live at last keystroke")
  assert_near(tracker:live(burst_end_ns + 2 * SECOND), 30, 1e-9, "live after pause")
  assert_equal(tracker:live(burst_end_ns + 6 * SECOND), 0, "live after idle timeout")
end)

test("live wpm ignores the previous burst after an idle gap", function()
  local tracker = new_tracker()
  local burst_end_ns = type_burst(tracker, 0, 11, 200 * MILLISECOND)
  local second_start_ns = burst_end_ns + 6 * SECOND
  tracker:record(second_start_ns)
  assert_equal(tracker:live(second_start_ns), 0, "single keystroke")
  tracker:record(second_start_ns + 200 * MILLISECOND)
  assert_near(tracker:live(second_start_ns + 200 * MILLISECOND), 60, 1e-9, "second keystroke")
end)

test("storage round trip preserves totals", function()
  local path = temporary_cache_path()
  assert(storage.write(path, { chars = 1234, active_ns = 98765432109876 }))
  local loaded = storage.read(path)
  assert_equal(loaded.chars, 1234, "chars")
  assert_equal(loaded.active_ns, 98765432109876, "active_ns")
end)

test("storage merge adds deltas of several instances", function()
  local path = temporary_cache_path()
  storage.merge(path, { chars = 10, active_ns = 2 * SECOND })
  local merged = storage.merge(path, { chars = 5, active_ns = SECOND })
  assert_equal(merged.chars, 15, "merged chars")
  assert_equal(storage.read(path).active_ns, 3 * SECOND, "stored active_ns")
end)

test("missing or corrupt cache files read as zero", function()
  assert_equal(storage.read(temporary_cache_path()).chars, 0, "missing file")
  local path = temporary_cache_path()
  write_raw(path, "{not json")
  assert_equal(storage.read(path).chars, 0, "corrupt file")
  write_raw(path, "[1, 2]")
  assert_equal(storage.read(path).active_ns, 0, "unexpected shape")
end)

test("setup loads the cached average", function()
  local path = temporary_cache_path()
  storage.write(path, { chars = 300, active_ns = 60 * SECOND })
  tacho.setup({ cache_path = path })
  assert_equal(tacho.wpm(), 60, "wpm")
  assert_equal(tacho.statusline(), "0 wpm (Ø 60)", "statusline")
end)

test("reset clears memory and cache file", function()
  local path = temporary_cache_path()
  storage.write(path, { chars = 300, active_ns = 60 * SECOND })
  tacho.setup({ cache_path = path })
  assert(tacho.reset(), "reset succeeds")
  assert_equal(tacho.wpm(), 0, "wpm")
  assert_equal(storage.read(path).chars, 0, "stored chars")
end)

test("typed characters in insert mode are counted and persisted", function()
  local path = temporary_cache_path()
  tacho.setup({ cache_path = path })
  vim.api.nvim_feedkeys("ihello world\27", "xt", false)
  assert_equal(tacho.stats().characters, 10, "characters")
  assert(tacho.save(), "save succeeds")
  assert_equal(storage.read(path).chars, 10, "stored chars")
  tacho.setup({ cache_path = path })
  assert_equal(tacho.stats().characters, 10, "characters after reload")
end)

test(":Tacho command saves, resets with bang and completes subcommands", function()
  vim.cmd.source(repository_root .. "/plugin/tacho.lua")
  local path = temporary_cache_path()
  tacho.setup({ cache_path = path })
  vim.api.nvim_feedkeys("iabc\27", "xt", false)
  vim.cmd("Tacho save")
  assert_equal(storage.read(path).chars, 2, "stored chars")
  local original_notify = vim.notify
  local notified_message = nil
  vim.notify = function(message)
    notified_message = message
  end
  local reset_ok, reset_error = pcall(vim.cmd, "Tacho! reset")
  vim.notify = original_notify
  assert(reset_ok, reset_error)
  assert_equal(notified_message, "tacho: statistics reset", "notification")
  assert_equal(storage.read(path).chars, 0, "stored chars after reset")
  local completions = vim.fn.getcompletion("Tacho s", "cmdline")
  assert_equal(table.concat(completions, ","), "save,show", "completion")
end)

local failures = 0
for _, case in ipairs(tests) do
  local passed, message = pcall(case.body)
  if passed then
    io.write("ok   " .. case.name .. "\n")
  else
    failures = failures + 1
    io.write("FAIL " .. case.name .. "\n     " .. tostring(message) .. "\n")
  end
end
io.write(string.format("\n%d tests, %d failures\n", #tests, failures))
os.exit(failures == 0 and 0 or 1)
