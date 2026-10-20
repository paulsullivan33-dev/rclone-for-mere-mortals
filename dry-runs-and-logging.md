# Dry Runs, Logs, and Exit Codes

**Scope:** how to see what a command *would* do,
how to keep a record of what it *did*, and the
numbers a script should judge it by.

## `--dry-run` — rehearse everything

Add `--dry-run` to any transfer verb and rclone
walks the whole job, changing nothing, narrating
what it skipped:

```
$ rclone copy fixture-src local1:store/documents-dryrun --dry-run -v
NOTICE: drafts/report.md: Skipped copy as --dry-run is set (size 36)
NOTICE: photos/big-scan.bin: Skipped copy as --dry-run is set (size 2.500Mi)
NOTICE: photos: Skipped set directory modification time as --dry-run is set
...
Transferred:           10 / 10, 100%
```

Nothing arrived at `documents-dryrun` — check for
yourself with `rclone lsd local1:store`; it isn't
there. Two habits follow:

1. **Every new command gets a dry run first.** New
   source, new destination, new filter — rehearse,
   read, then run.
2. **Read for the lines you *didn't* expect.** A
   dry run's value is not the files it lists; it's
   the `Skipped delete` you didn't know your `sync`
   was planning (chapter 6 has one).

## Verbosity: what `-v` buys

Without flags, rclone prints errors and notices
only — a successful script run is nearly silent.
`-v` adds the `INFO` lines every chapter here
quotes: each file copied, deleted, or moved, plus
the stats footer. `-vv` adds `DEBUG`, which is for
diagnosing rclone itself and produces a flood;
reach for it last.

The footer deserves one careful read, using a
sync that deleted two files:

```
Transferred:            0 B / 0 B, -, 0 B/s, ETA -
Checks:                11 / 11, 100%, Listed 30
Deleted:                2 (files), 0 (dirs), 85 B (freed)
Elapsed time:         0.0s
```

**Transferred** is bytes that moved; **Checks** is
files compared; **Deleted** is the line people
skim past and shouldn't; **Errors**, when present,
counts trouble. A monitoring habit worth having:
any run whose **Deleted** line surprises you is a
run to investigate before the next one.

## Logging to a file

`--log-file` sends the same lines to a file instead
of the terminal — the difference between a cron job
you can audit and one you have to take on faith:

```
$ rclone copy fixture-src local1:store/documents --log-file copy-log.txt -v
$ cat copy-log.txt
2026/10/20 18:46:55 INFO  : There was nothing to transfer
...
```

The worked example's script (chapter 15) keeps one
log per upload job for exactly this reason.
`--log-level` picks the threshold when the flag and
the file disagree about how much you want.

## `--progress`

In a terminal, `--progress` draws a live bar with
speeds and an ETA. In a script there is no terminal,
and what you get is the final stats block:

```
$ rclone copy fixture-src local1:store/documents --progress --stats 1s
Transferred:           76 B / 76 B, 100%, 0 B/s, ETA -
Checks:                 9 / 9, 100%, Listed 28
Transferred:            1 / 1, 100%
```

Use `--progress` interactively, `--log-file` in
scripts, and don't confuse the two audiences.

## Exit codes — the script's verdict

rclone reports how it went through its exit code.
These were produced for real in the lab:

| Code | Seen when | Lab evidence |
|---|---|---|
| 0 | success, including "nothing to transfer" | every clean run |
| 1 | `check` found differences | chapter 8 — 2 differences, exit 1 |
| 3 | the named place or path doesn't exist | `lsd` on a missing folder; `copy` from a missing source |
| 7 | a fatal error stopped the job | `sync --max-delete 1` with 3 deletions pending, chapter 6 |

The full official list lives in rclone's docs
**(documented)**; the four above are the ones a
script writer meets weekly. Two behaviours to know
alongside them: a failed transfer is retried
(`Attempt 1/3` … `Attempt 3/3` appears in the
missing-source output before the final error), and
"nothing to transfer" is success, not an error —
a scheduled job that finds no new logs exits 0.

**Check:** after any scripted run, `echo $?`
should be part of the ritual until the job has
earned your trust — and the job itself should
treat anything but 0 as worth a human's attention.
