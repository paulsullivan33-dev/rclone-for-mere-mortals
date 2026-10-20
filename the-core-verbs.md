# The Core Verbs

**Scope:** `copy`, `sync`, `move`, and their close
relatives — what each one does to the destination,
and the one naming rule that bites every beginner
exactly once.

## `copy` — add what's missing, change what's stale

```
$ rclone copy fixture-src local1:store/documents -v
INFO  : photos/cat.jpg: Copied (new)
INFO  : archive/old-note.txt: Copied (new)
...
Transferred:       2.500 MiB / 2.500 MiB, 100%
Transferred:            9 / 9, 100%
```

`copy` never deletes. Run it again immediately and
it does the other half of its job — recognising
there's nothing to do:

```
INFO  : There was nothing to transfer
Checks:                 9 / 9, 100%
```

Edit one file and a third run moves that file
(whole — see chapter 1) plus anything new, and
nothing else. `copy` is the default verb of this
guide and of most real scripts: uploading,
archiving, and feeding a destination that is allowed
to accumulate.

## `sync` — make the destination *match*

`sync` is `copy` plus a promise: when it finishes,
the destination equals the source — including the
deletions that requires. That promise is powerful
enough to get its own chapter (chapter 6), where
you can watch it delete a stray file and a file the
source deleted, first in a dry run and then for
real. Learn `copy` first; reach for `sync` only
when "match" is truly what you mean.

## `move` — copy, then remove the source

```
$ rclone move local1:store/documents/drafts/report.md local1:store/moved -v
INFO  : report.md: Moved (server-side)
Renamed:                1
Server Side Moves:      1 @ 36 B
```

Two things to notice. The source is gone afterwards
— that's the verb's whole point — and where source
and destination live on the same storage, rclone
says `Moved (server-side)`: no bytes crossed
anywhere, the place itself renamed the object. The
same trick appears when `sync --backup-dir` rescues
files in chapter 6.

## The naming rule: `copy` fills directories, `copyto` names files

`copy`'s destination is always a *directory* to be
filled. Hand it a file path as the source and a
name you fancy as the destination, and it still
treats the destination as a directory. The lab
learned this returning a file from the chunker
(chapter 11):

```
$ rclone copy chunked:big-scan.bin big-scan-back.bin
$ ls -l big-scan-back.bin
total 2560
-rw-rw---- 1 root nogroup 2621440 ... big-scan.bin
```

`big-scan-back.bin` is a *directory* containing
`big-scan.bin`. No error, no warning — just not
what was asked. The verb that takes a full file
name on both ends is `copyto` (and `moveto`):

```
$ rclone copyto chunked:big-scan.bin restored-big-scan.bin
$ cmp fixture-src/photos/big-scan.bin restored-big-scan.bin
[exit 0]
```

`cmp` is silent and exits 0: the file that came back
is byte-identical. **Check:** whenever a destination
name *ends in a file name*, ask which verb you're
running. Directory in mind → `copy`. File name in
mind → `copyto`.

## The rest of the family, briefly

- **`delete`** removes files under a path (it
  honours filters and `--dry-run`); **`purge`**
  removes a directory and everything under it:

  ```
  $ rclone purge local1:store/filtered -v
  INFO  : drafts/report.md: Deleted
  ...
  INFO  : Local file system at store/filtered: Removing directory
  ```

  `purge` asks nothing and confirms nothing. It is
  the sharpest tool in this chapter; chapter 6's
  habits apply double.

- **`cat`** prints a remote file to your terminal —
  `rclone cat secret:notes/todo.txt` is how chapter
  10 reads a file straight out of encrypted storage.
- **`mkdir`** creates a directory on a remote that
  needs directories made explicitly **(documented)** —
  most backends make them implicitly as files arrive.

| Verb | Adds/updates | Deletes at destination | Removes source |
|---|---|---|---|
| `copy` | yes | never | no |
| `sync` | yes | **yes — to match** | no |
| `move` | yes | no | yes |
| `copyto` | one file, renamed | replaces that file | no |

**Scope note:** all four main verbs take the same
global flags — `-v`, `--dry-run`, filters, logging —
which is the subject of the next two chapters.
