# A Worked Example

**Scope:** one job, end to end, with real output —
the pattern this whole guide points at. A small
device writes log files into a folder and rotates
old ones away. The job: keep an archive of those
logs on storage the device doesn't control, so
rotation can never eat the only copy. In the lab,
"storage" is the local remote `local1:store/device-logs`
standing in for a cloud folder; chapter 13
documented how the real one is connected.

## The setup

The device folder starts with two days of logs. The
script is `examples/sync-logs.sh` (chapter 14) —
`copy`, not `sync`, for the reason its header
states: the device *will* delete local logs, and an
archive that mirrors deletions is not an archive.

```
$ ls device-logs
2026-10-18.log
2026-10-19.log

$ sh sync-logs.sh
[exit 0]

$ rclone lsf local1:store/device-logs
2026-10-18.log
2026-10-19.log
```

Quiet run, exit 0, two files archived. The log file
says what the terminal didn't:

```
2026/10/20 18:48:02 INFO  : 2026-10-18.log: Copied (new)
2026/10/20 18:48:02 INFO  : 2026-10-19.log: Copied (new)
Transferred:            2 / 2, 100%
```

## A day passes

A new log appears on the device, and rotation
removes the oldest local one. Both facts are
exactly what the archive exists to survive:

```
$ ls device-logs
2026-10-19.log
2026-10-20.log

$ sh sync-logs.sh
[exit 0]

$ rclone lsf local1:store/device-logs
2026-10-18.log
2026-10-19.log
2026-10-20.log
```

Read the last listing twice — it's the whole
argument of chapter 6 in miniature. The archive
holds **three** files; the device holds **two**.
`2026-10-18.log` exists only in the archive now,
because `copy` sent the new file and deleted
nothing. Had the script said `sync`, this listing
would match the device's — and the archived
18th would have been deleted to achieve the match.

The run's log shows the incremental shape of the
job from the second run on — one file moved, one
checked and found already present:

```
2026/10/20 18:48:02 INFO  : 2026-10-20.log: Copied (new)
Checks:                 1 / 1, 100%
Transferred:            1 / 1, 100%
```

## The job, assembled

Everything from the earlier chapters in one place:

- **Verb chosen on purpose** — `copy`, because the
  destination must accumulate (chapters 4 and 6).
- **A script, not a command line**, so the choice
  and its reason survive in writing (chapter 14).
- **A log file per the script**, so silence means
  success and anything else can be read later
  (chapter 5).
- **A schedule with a lock** — every ten minutes,
  `flock -n`, or the systemd timer pair
  (chapter 14).
- **Exit code 0 as the contract**: a run that finds
  nothing new is a successful run (chapter 5).

Variants worth knowing, stated once: if the far
end were a crypt remote (`secret:device-logs`),
nothing else in the job changes — the archive
would hold ciphertext logs, readable only with the
config, which some archives want. And if the goal
were a *mirror* — a second device kept identical,
retirements included — the verb would be `sync`
with `--max-delete` set and a `--backup-dir`
beside it, and chapter 6 would be the chapter to
re-read first.
