# Measurement

## What is counted

- **Words**: one word equals five characters (the usual WPM definition of
  typing tests), so the value is independent of word lengths and code syntax.
- **Characters**: every character typed in insert or replace mode, detected via
  the `InsertCharPre` event. Pasted text and accepted completions do not
  trigger this event and are therefore not counted.
- **Gross WPM**: backspace and other deletions are not subtracted.

## Active typing time

Only time spent actively typing counts:

- A keystroke within `idle_timeout_ms` (default 5 s) of the previous one adds
  one character and the gap between both keystrokes.
- A longer gap starts a new burst; the first keystroke of a burst only sets the
  reference time. With `n` keystrokes there are `n - 1` measured intervals,
  which avoids overestimating short bursts.
- Leaving insert mode ends the current burst.

The all-time average is `(characters / 5) / active minutes`.

## Live value

The live value uses the keystrokes of the current burst within the last
`live_window_ms` (default 10 s): `(keystrokes - 1) / 5` divided by the time
from the oldest keystroke in the window until now. It therefore decays during
a pause and drops to `0` once the idle timeout has passed.

## Persistence

The statistics are stored as `{"chars": …, "active_ns": …}` in
`stdpath("cache")/tacho.json`. Each Neovim instance keeps the last loaded
totals and its own unsaved delta separately. On saving (on `InsertLeave` at
most every `save_interval_ms`, on exit, or via `:Tacho save`) the file is read
again, the delta is added and the result is written atomically. Several
instances running in parallel therefore do not overwrite each other.

> [!NOTE]
> After `:Tacho reset` in one instance, other running instances keep showing
> their previous average until they save the next time.

A missing or corrupt cache file is treated as empty.
