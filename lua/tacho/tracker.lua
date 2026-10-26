local NANOSECONDS_PER_MILLISECOND = 1e6
local NANOSECONDS_PER_MINUTE = 60e9
local CHARACTERS_PER_WORD = 5

local Tracker = {}
Tracker.__index = Tracker

local function empty_totals()
  return { chars = 0, active_ns = 0 }
end

local function words_per_minute(chars, duration_ns)
  if duration_ns <= 0 then
    return 0
  end
  return (chars / CHARACTERS_PER_WORD) / (duration_ns / NANOSECONDS_PER_MINUTE)
end

function Tracker.new(options)
  local tracker = setmetatable({}, Tracker)
  tracker.idle_timeout_ns = options.idle_timeout_ms * NANOSECONDS_PER_MILLISECOND
  tracker.live_window_ns = options.live_window_ms * NANOSECONDS_PER_MILLISECOND
  tracker.baseline = empty_totals()
  tracker.pending = empty_totals()
  tracker.last_keystroke_ns = nil
  tracker:clear_live()
  return tracker
end

function Tracker:clear_live()
  self.live_timestamps = {}
  self.live_head = 1
  self.live_tail = 0
end

function Tracker:prune_live(now_ns)
  local window_start_ns = now_ns - self.live_window_ns
  while self.live_head <= self.live_tail do
    if self.live_timestamps[self.live_head] >= window_start_ns then
      return
    end
    self.live_timestamps[self.live_head] = nil
    self.live_head = self.live_head + 1
  end
end

function Tracker:record(now_ns)
  local previous_ns = self.last_keystroke_ns
  self.last_keystroke_ns = now_ns
  if previous_ns and now_ns - previous_ns <= self.idle_timeout_ns then
    self.pending.chars = self.pending.chars + 1
    self.pending.active_ns = self.pending.active_ns + (now_ns - previous_ns)
  else
    self:clear_live()
  end
  self.live_tail = self.live_tail + 1
  self.live_timestamps[self.live_tail] = now_ns
  self:prune_live(now_ns)
end

function Tracker:break_burst()
  self.last_keystroke_ns = nil
end

function Tracker:totals()
  return {
    chars = self.baseline.chars + self.pending.chars,
    active_ns = self.baseline.active_ns + self.pending.active_ns,
  }
end

function Tracker:average()
  local totals = self:totals()
  return words_per_minute(totals.chars, totals.active_ns)
end

function Tracker:live(now_ns)
  local newest_ns = self.live_timestamps[self.live_tail]
  if not newest_ns or now_ns - newest_ns > self.idle_timeout_ns then
    return 0
  end
  self:prune_live(now_ns)
  local keystrokes_in_window = self.live_tail - self.live_head + 1
  if keystrokes_in_window < 2 then
    return 0
  end
  local oldest_ns = self.live_timestamps[self.live_head]
  return words_per_minute(keystrokes_in_window - 1, now_ns - oldest_ns)
end

function Tracker:pending_totals()
  return { chars = self.pending.chars, active_ns = self.pending.active_ns }
end

function Tracker:commit(stored_totals)
  self.baseline = { chars = stored_totals.chars, active_ns = stored_totals.active_ns }
  self.pending = empty_totals()
end

function Tracker:reset()
  self.baseline = empty_totals()
  self.pending = empty_totals()
  self.last_keystroke_ns = nil
  self:clear_live()
end

return Tracker
