# Deleting, Carefully

**Scope:** the chapter to read twice. `sync`'s
deletions are a feature — mirrors, deployments, and
rotations depend on them — and the same feature,
pointed at the wrong place or run from an empty
source, is how people lose the only copy. Everything
below was done to lab fixtures on purpose. Do your
own first sync the same way: on copies.

## Watch a sync delete

The lab's destination holds one file the source
never had (`stray.txt`, planted) and one file the
source has just deleted (`notes/ideas.md`). The
dry run announces both fates before anything
happens:

```
$ rclone sync fixture-src local1:store/documents --dry-run -v
NOTICE: stray.txt: Skipped delete as --dry-run is set (size 24)
NOTICE: notes/ideas.md: Skipped delete as --dry-run is set (size 61)
Deleted:                2 (files), 0 (dirs), 85 B (freed)
```

And the real run, a second later, is unremarkable —
which is exactly the problem:

```
$ rclone sync fixture-src local1:store/documents -v
INFO  : stray.txt: Deleted
INFO  : notes/ideas.md: Deleted
Deleted:                2 (files), 0 (dirs), 85 B (freed)
```

Two plain-English rules cover most disasters:

- **`sync` makes the destination match the source —
  all of it.** A file that exists only at the
  destination is, to `sync`, simply wrong.
- **An empty source is a valid source.** Sync an
  empty folder (wrong path, unmounted drive, a
  script bug) over a full destination and rclone
  will faithfully empty the destination. It cannot
  tell your mistake from your intent.

## Net one: `--max-delete`

Cap how many files a single run may delete. The
lab set up three pending deletions and a cap of
one:

```
$ rclone sync srcA local1:store/dstA --max-delete 1 -v
ERROR : delta.txt: Got fatal error on delete: --max-delete threshold reached
INFO  : charlie.txt: Deleted
ERROR : bravo.txt: Got fatal error on delete: --max-delete threshold reached
ERROR : Cancelling sync due to fatal error: failed to delete 2 files
[exit 7]
```

Read what happened precisely: one file (the cap)
was deleted, the run then *stopped fatally*, exit
code 7, and two files survived. `--max-delete`
doesn't make a big deletion safe — it makes a
wrong deletion *small and loud*. A scheduled sync
with a sane cap turns "script emptied the archive"
into "script failed at 3 a.m. having deleted one
file," which is a story with a much better ending.

## Net two: `--backup-dir`

Tell sync where deleted and overwritten files
should go instead of the void:

```
$ rclone sync srcA local1:store/dstA --backup-dir local1:store/rescue -v
INFO  : bravo.txt: Moved into backup dir
INFO  : delta.txt: Moved into backup dir
Deleted:                2 (files), 0 (dirs), 22 B (freed)

$ rclone lsf local1:store/rescue
bravo.txt
delta.txt

$ cat store/rescue/bravo.txt
bravo file
```

The destination still ends up matching the source —
but the casualties are sitting in `rescue`, contents
intact, moved server-side where the backend allows
it. A backup dir on the *same* remote is the usual
pattern; `--suffix` can add a date or marker to the
rescued names **(documented)**. The dir is not a
recycle bin with housekeeping — empty it on your
own schedule, and size it into your quota thinking.

## The rules, collected

1. **Dry-run every new or changed sync.** Read the
   `Skipped delete` lines specifically.
2. **Cap deletions** (`--max-delete`) on any sync
   that runs unattended.
3. **Give sync a `--backup-dir`** until the job is
   old and boring — and maybe after.
4. **Check the source is alive first.** In scripts,
   a one-line `rclone check` or a known-file probe
   before the sync is cheap; chapter 8 covers it.
5. **`copy` when you only mean "add".** Most jobs
   that "sync" in conversation actually want copy's
   promise: new and changed files arrive, nothing
   ever leaves. The worked example (chapter 15)
   chooses `copy` for an archive for exactly this
   reason — a device that rotates its own logs must
   never be able to reach back and delete the
   archive's copies.
6. **`purge` has no nets at all.** It removes a
   directory and its contents on request, no
   confirmation, no Deleted line to skim. Type the
   full remote path, read it twice, then press
   enter.
