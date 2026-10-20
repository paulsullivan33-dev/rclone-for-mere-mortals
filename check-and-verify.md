# Check and Verify

**Scope:** answering "did it actually arrive, all
of it, unchanged?" with evidence instead of vibes.
`check` is the verb scripts can trust, because it
reports through its exit code.

## A check that fails

The lab tampered with one destination file and
removed another (the `move` in chapter 4 took it),
then asked:

```
$ rclone check fixture-src local1:store/documents
ERROR : drafts/report.md: file not in Local file system at store/documents
ERROR : notes/todo.txt: sizes differ
NOTICE: Local file system at store/documents: 1 files missing
NOTICE: Local file system at store/documents: 2 differences found
NOTICE: Local file system at store/documents: 7 matching files
[exit 1]
```

Three facts to take from this: `check` names each
difference and says what kind it is; it counts the
matching files too, so "0 differences" is a
positive claim, not an absence of output; and the
exit code is **1** — a script can branch on it
without parsing a word.

## What check compares

By default, matching size *and* hash where both
sides can hash. Two useful weakenings, both shown
in the lab:

- `--size-only` compares sizes alone — faster, and
  blind to a same-size content change:

  ```
  $ rclone check fixture-src local1:store/documents --size-only
  ERROR : notes/todo.txt: sizes differ
  ...
  [exit 1]
  ```

- `--download` makes rclone read both sides and
  compare the bytes themselves — the strongest
  check it can do, at the cost of moving all the
  data. The lab ran it after repairing the tree:

  ```
  $ rclone check fixture-src local1:store/documents --download --size-only
  NOTICE: Local file system at store/documents: 0 differences found
  NOTICE: Local file system at store/documents: 9 matching files
  [exit 0]
  ```

There is also `--checksum`, comparing hashes only
**(documented)**. Know the ladder: size is a claim,
hash is evidence, download is proof — priced in
time and bandwidth accordingly.

## Repair, then re-check

The lab's fix was the boring one — let `sync`
restore the tree, and check again:

```
$ rclone sync fixture-src local1:store/documents
[exit 0]

$ rclone check fixture-src local1:store/documents
NOTICE: Local file system at store/documents: 0 differences found
NOTICE: Local file system at store/documents: 9 matching files
[exit 0]
```

That pairing — a writing verb, then `check` as the
independent witness — is the pattern to build into
any job whose output you'd otherwise take on
faith. A sync reporting success says rclone
*believes* it finished; a check says the trees
agree.

## Hashes on demand

`hashsum` prints a file's (or a tree's) hashes in
the classic checksum format:

```
$ rclone hashsum MD5 local1:store/documents/notes
8bd07364aa48498bf83b3045560b6e02  new-note.txt
b3a057ee14149083f463295298aae106  todo.txt
```

Which hashes exist depends on the backend — the
local backend offers MD5 among others; a cloud
backend offers whatever the service stores. A
missing hash is reported as such rather than
invented **(documented)**. Note the connection to
`check`: two files whose sizes *and* hashes match
are, for practical purposes, the same file, which
is why `check` trusts hashes when it can get them.

**Scope note:** for an encrypted destination, plain
`check` still works on sizes but hashes live on the
encrypted side of the wall. Chapter 10's
`cryptcheck` is the variant built for that — it
compares plaintext against the crypt remote
properly.
