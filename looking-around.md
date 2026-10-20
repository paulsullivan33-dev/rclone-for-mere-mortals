# Looking Around

**Scope:** the five read-only verbs. They never
change anything, they work on every backend, and
they are how you answer "what's actually there?"
before letting a writing verb loose.

Everything below looks at `local1:store/documents`,
a folder the next chapter fills. Sizes and names are
the lab's; the shapes are universal.

## `lsd` — the directories

```
$ rclone lsd local1:store/documents
        24 2026-10-20 18:45:32        -1 archive
        40 2026-10-20 18:45:32        -1 drafts
        56 2026-10-20 18:45:32        -1 logs
        32 2026-10-20 18:45:32        -1 notes
        38 2026-10-20 18:45:32        -1 photos
```

The columns are size (meaningless for directories —
that's the `-1` object count beside it), modification
time, count, name. It's the quick "what folders live
here" answer.

## `ls` — files, with sizes

```
$ rclone ls local1:store/documents
  2621440 photos/big-scan.bin
       32 photos/cat.jpg
       68 logs/2026-10-19.log
...
```

Recursive by default, paths relative to the place
you named, size in bytes first. This is the output
to pipe at `sort -n` when hunting what ate a bucket.

## `lsf` — listings shaped for scripts

`lsf` is `ls` for programs: names by default, and
flags to shape them.

```
$ rclone lsf local1:store/documents --recursive
archive/
drafts/
...
notes/ideas.md
notes/todo.txt
photos/big-scan.bin
photos/cat.jpg
```

Directories carry a trailing slash so a script can
tell them from files; `--files-only` drops them.
`--format` can add sizes, times, and hashes as
extra fields **(documented)** — the defaults above
are what the rest of this guide uses.

## `size` and `tree` — the summary and the picture

```
$ rclone size local1:store/documents
Total objects: 9
Total size: 2.500 MiB (2621839 Byte)

$ rclone tree local1:store/documents
/
├── archive
│   └── old-note.txt
├── drafts
│   ├── report.md
│   └── scratch.tmp
...
5 directories, 9 files
```

`size` is the billing question ("how much is in
this bucket?") answered in one line. `tree` is the
same picture you'd draw on a whiteboard — worth
running before and after any structural change, so
the change has a shape you can see.

## `about` — the place itself

```
$ rclone about local1:store
Total:   99.982 GiB
Used:    6.408 GiB
Free:    92.889 GiB
```

On a local remote that's the disk's numbers. On a
cloud remote it's the account's quota view —
total, used, free, and on some backends how much of
it is trash **(documented)**. Not every backend can
answer `about`; one that can't says so rather than
guessing.

**Check:** every command in this chapter is safe to
run against a remote you don't recognise yet. Make
that a habit — `lsd`, `size`, `tree` on any new
destination *before* the first `sync` is the
cheapest insurance in this guide. (For browsing
storage like a spreadsheet there's also `rclone
ncdu`, an interactive disk-usage browser —
**(documented)**, since it needs a live terminal.)
