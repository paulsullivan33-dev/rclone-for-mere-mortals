# Troubleshooting

**Scope:** symptom → cause → fix, built from the
errors the lab actually produced. If your message
isn't here, the shape of the search is: read the
exit code (chapter 5), re-run with `-v`, and try
the same verb against a local path to separate
"rclone is confused" from "the remote is."

## "directory not found" — exit 3

```
$ rclone lsd local1:store/no-such-dir
ERROR : error listing: directory not found
[exit 3]
```

**Causes, in order of likelihood:** the path is
wrong; the remote name is wrong (a typo'd name
makes rclone guess, and its guesses fail here);
the job is reading a *different config file* than
you think — scheduled jobs especially (chapter
14). **Fix:** `rclone config file` shows which
config this shell is using; `rclone listremotes`
shows the names in it; `rclone lsd remote:` walks
from the top instead of from a guessed path.

**Special case:** from a *crypt* remote, this
message with a path you're sure exists means the
config's password, salt, or name-encryption
settings don't match the ones the data was written
with — chapter 10 produced exactly this with a
wrong-password remote. There is no "try again"
state; the names themselves are encrypted.

## "Failed to copy: directory not found" — exit 3, after retries

```
ERROR : Attempt 1/3 failed with 1 errors and: directory not found
ERROR : Attempt 2/3 failed with 1 errors and: directory not found
ERROR : Attempt 3/3 failed with 1 errors and: directory not found
NOTICE: Failed to copy: directory not found
```

The *source* is the missing side this time. The
retry lines are rclone's default persistence (3
attempts) before it gives up — in a log, they are
your clue that the failure began earlier than the
final NOTICE suggests.

## `check` reports differences — exit 1

Not an rclone error: the witness doing its job
(chapter 8). Read which kind — `sizes differ`,
`hashes differ`, `file not in…` — then decide
whether the fix is a re-`copy` (usual), a `sync`
(think about chapter 6 first), or an investigation.
Exit 1 in a script should page a human, not
trigger an automatic overwrite.

## A sync stopped dead — exit 7, "--max-delete threshold reached"

```
ERROR : delta.txt: Got fatal error on delete: --max-delete threshold reached
ERROR : Cancelling sync due to fatal error: failed to delete 2 files
```

The safety net fired (chapter 6). The sync planned
more deletions than you allowed — which almost
always means the *source* is emptier than expected:
wrong path, unmounted drive, an upstream job that
failed. Do not simply raise the cap. Find out why
so many deletions were pending; the cap just bought
you the chance to ask.

## "There was nothing to transfer" — but you expected files

Usually the comparison is right and the expectation
is wrong: the destination genuinely matches (run
`rclone check` to confirm), or a filter is silently
excluding the new files (re-run the chapter 7
listing test with the same flags), or the files
changed *content* without changing size *or*
timestamp in a way the default comparison can see
— the case `--checksum` and `--download` exist for
(chapter 8).

## `mount` dies immediately — "fuse device not found"

```
NOTICE: mount helper error: fusermount3: fuse device not found, try 'modprobe fuse' first
CRITICAL: Fatal error: failed to mount FUSE fs: fusermount: exit status 1
```

The machine lacks a working FUSE device — common
on servers, containers, and minimal installs
(chapter 12). On a machine you administer, loading
the fuse module or installing the helper is the
fix; on one you don't, use `serve` or the plain
verbs instead. No rclone flag changes this answer.

## The destination has a directory wearing your file's name

You used `copy` where you meant `copyto`
(chapter 4). `copy`'s destination is always a
directory to fill. Remove the accidental directory
with `purge` (carefully — chapter 6) and re-run
with `copyto`.

## It works by hand and fails on a schedule

The scheduler's environment is not your shell's —
see chapter 14. The three regulars: a different
config file (set `RCLONE_CONFIG` in the script), a
different working directory (use absolute paths or
`cd` in the script), and a PATH that lacks the
rclone binary (call it by full path). All three
present as "remote not found" or "command not
found," never as what they are.
