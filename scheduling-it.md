# Scheduling It

**Scope:** rclone's real habitat — jobs nobody
watches. The transfer itself you already know; this
chapter is the wrapping: a script, a schedule, a
lock, and a log. The script below is the worked
example's and was run for real in chapter 15; the
schedulers are shipped as files and described,
because the lab doesn't install jobs on its own
machine.

## The script is the unit

Never schedule a bare `rclone` line. Schedule a
small script that fixes the job's choices in one
readable place — source, destination, the deliberate
choice of `copy` over `sync`, and a log file:

```sh
#!/bin/sh
# sync-logs.sh -- upload new log files to storage, keeping a run log.
# COPY, never SYNC, on purpose: the device rotates its old logs
# away, and a sync would faithfully delete the archived copies.
set -eu

SRC_DIR="${1:-device-logs}"
REMOTE="${2:-local1:store/device-logs}"
LOG_FILE="${3:-sync-logs.log}"

rclone copy "$SRC_DIR" "$REMOTE" \
    --log-file "$LOG_FILE" \
    --log-level INFO
```

(It ships as `examples/sync-logs.sh`.) Three
details do quiet work: `set -eu` makes the shell
fail loudly rather than improvise; the destination
is a parameter with a default, so the same script
is testable against a lab remote; and the log file
is how a job that runs at 3 a.m. answers questions
at 9.

One environment point that bites everyone once: a
scheduler does not inherit your shell's
environment. If your config lives somewhere
non-default, the script or the job must say so —
`RCLONE_CONFIG` from chapter 2, set in the script,
is the reliable way. A job that "can't find" its
remote is usually a job reading a different, empty
config.

## cron, with a lock

The classic driver. This line runs the upload every
ten minutes:

```
*/10 * * * * flock -n /tmp/sync-logs.lock /path/to/sync-logs.sh
```

`flock -n` is the part people omit: if a run is
still going when the next tick arrives, the new
one exits immediately instead of stacking a second
transfer on the first. Long transfers and short
intervals make the lock a necessity, not a nicety.
Output beyond the log file can be mailed or
discarded by cron as usual; the `--log-file` inside
the script is the record that matters.

## systemd timers, in two files

The modern alternative ships in `examples/`:

- `log-sync.service` — a oneshot service that runs
  the script, with `ExecStart` pointing at it.
- `log-sync.timer` — a timer with
  `OnCalendar=*:0/10` (every ten minutes) and
  `Persistent=true`, so a run missed while the
  machine was off fires at next boot instead of
  never.

Install both under `~/.config/systemd/user/`,
`systemctl --user daemon-reload`, then
`systemctl --user enable --now log-sync.timer`.
The trade against cron is mostly taste: timers get
you `systemctl list-timers` and journal logs for
free; cron gets you forty years of familiarity.
Either way the script — and rclone — are the same.

**Check:** whatever you schedule, run the script
once by hand first, and read its log. Then check
the exit code the scheduler saw (`systemctl status`
or cron's mail) after the first automatic run.
Unattended is a property you verify, not a hope.
