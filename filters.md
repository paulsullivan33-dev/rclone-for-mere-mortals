# Filters

**Scope:** telling rclone which files a command is
about. Filters apply to *every* verb — listings,
copies, checks, deletions — and they are evaluated
the same way everywhere, which makes an hour spent
here pay rent in every other chapter.

The test subject is the lab's source tree, which
contains one `.tmp` file and one file planted with
a 2020 timestamp, precisely so the filters have
something visible to exclude.

## The baseline, and one exclusion

```
$ rclone lsf fixture-src --recursive --files-only
archive/old-note.txt
drafts/report.md
drafts/scratch.tmp
logs/2026-10-19.log
logs/2026-10-20.log
notes/new-note.txt
notes/todo.txt
photos/big-scan.bin
photos/cat.jpg

$ rclone lsf fixture-src --recursive --files-only --exclude '*.tmp'
archive/old-note.txt
drafts/report.md
logs/2026-10-19.log
...
```

`scratch.tmp` is gone from the listing — and would
be gone from a copy, a check, or a sync built on
the same flags. Patterns use rclone's own glob
rules, and the two worth memorising are:

- `*` matches within one path segment — it does
  **not** cross a `/`. `*.tmp` still matched
  `drafts/scratch.tmp` above because a pattern with
  no slash is tried against the file's name at any
  depth.
- `**` crosses directories. `/archive/**` means
  "everything under the top-level `archive`" — the
  leading slash anchors the pattern to the root of
  the place you named.

## `--include` — the allowlist

```
$ rclone lsf fixture-src --recursive --files-only --include '*.log'
logs/2026-10-19.log
logs/2026-10-20.log
```

Include flips the default: nothing matches except
what the patterns name. Order matters when flags
mix — rclone tests each file against the patterns
in the order you gave them and the first match
decides **(documented)**. Keep combinations simple
enough to say out loud.

## `--filter-from` — the patterns live in a file

Any job bigger than a one-liner wants its rules in
a file it can be reviewed in. The lab's
`examples/filters.txt` ships with the guide:

```
- *.tmp
- /archive/**
```

Each line is `+` (include) or `-` (exclude) and a
pattern, first match wins, and a file matched by
no line is included — the exact opposite default
from `--include`, so read your own file with that
in mind:

```
$ rclone lsf fixture-src --recursive --files-only --filter-from filters.txt
photos/big-scan.bin
photos/cat.jpg
logs/2026-10-19.log
logs/2026-10-20.log
drafts/report.md
notes/new-note.txt
notes/todo.txt
```

The `.tmp` and everything under `archive/` are
gone; the other seven files remain.

## Age and size: filters that aren't patterns

`--max-age`, `--min-age`, `--max-size`, and
`--min-size` filter on facts instead of names:

```
$ rclone lsf fixture-src --recursive --files-only --max-age 24h
(everything except archive/old-note.txt — the planted 2020 file)

$ rclone lsf fixture-src --recursive --files-only --min-size 1M
photos/big-scan.bin
```

`--max-age 24h` is how "upload today's logs, not
the whole archive" gets said. Durations accept
`s`, `m`, `h`, `d`, `w`, `M`, `y` suffixes
**(documented)**.

## `--files-from` — name the exact files

Sometimes the list *is* the filter. `--files-from`
takes a file of paths, one per line, and the
command touches exactly those:

```
$ cat files-list.txt
notes/todo.txt
logs/2026-10-20.log

$ rclone copy fixture-src local1:store/picked --files-from files-list.txt -v
INFO  : logs/2026-10-20.log: Copied (new)
INFO  : notes/todo.txt: Copied (new)
Transferred:            2 / 2, 100%
```

Note it respects the source's structure — the two
files arrived under their `notes/` and `logs/`
folders. A sibling flag, `--files-from-raw`,
skips comment and blank-line handling
**(documented)**.

## Filters and `sync`: the sharp edge

A filter decides what a sync can *see*. Files a
filter excludes from the source are not copied —
and a file that exists at the destination but is
invisible to the sync's filters is not the same,
to rclone, as a file the source deleted. The safe
working rule, and the one this guide follows:
**never let a filter be the only thing standing
between a sync and a file you care about** — test
filter changes against a destination you can
afford, with `--dry-run`, and read the `Skipped
delete` lines before trusting the combination.

**Check:** the fastest filter test in the toolbox
is the one this chapter used — `rclone lsf <place>
--recursive --files-only` with your flags, before
and after. If the two listings differ exactly the
way you intended, the filter is right.
