# Layered Remotes

**Scope:** remotes that wrap other remotes. crypt
(chapter 10) is the famous one; this chapter covers
the two the lab ran live — `alias` for names and
`chunker` for size limits — and one honest paragraph
about `cache`.

The pattern to notice: a layered remote is just a
remote whose `remote =` setting points at another
remote's path. Layers compose, which is how setups
like "chunked, then encrypted, then stored on
Drive" are built **(documented as a combination;
each layer here was run on its own)**.

## `alias` — a short name for a long path

Some paths get typed too often to stay long:

```
$ rclone config create docs alias remote local1:store/documents
[docs]
type = alias
remote = local1:store/documents

$ rclone lsf docs:notes
new-note.txt
todo.txt
```

That's the whole feature, and it's enough: scripts
can say `docs:` and the real location can move
later by editing one config section. Alias can also
point at a bare local path, giving a folder a
remote-style name without a `local` remote in
between **(documented)**.

## `chunker` — files bigger than the place allows

Some storage caps the size of a single object. A
`chunker` remote hides that cap: files arrive
whole through the chunker and are stored as a
sequence of pieces plus a small metadata file.
The lab set the chunk size absurdly small — 1 MiB —
so the fixture's 2.5 MiB scan would split visibly:

```
$ rclone config create chunked chunker remote local1:store/chunkstore chunk_size 1M

$ rclone copy fixture-src/photos/big-scan.bin chunked: -v
INFO  : big-scan.bin.rclone_chunk.001_84lat4: Moved (server-side) to: big-scan.bin.rclone_chunk.001
INFO  : big-scan.bin.rclone_chunk.002_84lat4: Moved (server-side) to: big-scan.bin.rclone_chunk.002
INFO  : big-scan.bin.rclone_chunk.003_84lat4: Moved (server-side) to: big-scan.bin.rclone_chunk.003
INFO  : big-scan.bin: Copied (new)
```

Through the chunker, one file. Underneath, the
truth:

```
$ rclone lsf chunked:
big-scan.bin

$ rclone ls local1:store/chunkstore
       77 big-scan.bin
  1048576 big-scan.bin.rclone_chunk.001
  1048576 big-scan.bin.rclone_chunk.002
   524288 big-scan.bin.rclone_chunk.003
```

Two 1 MiB chunks, one 512 KiB remainder, and a
77-byte metadata file wearing the real name —
chunker records the assembly instructions there.
Reading back reassembles transparently, and the
round trip was verified byte-for-byte (`copyto` +
`cmp`, [exit 0] — the capture lives in chapter 4,
where it also teaches the `copy`/`copyto`
distinction).

Real chunk sizes are chosen just under the
provider's cap, not at 1 MiB; the lab's size is a
demonstration, not a recommendation. And a warning
worth its line: **the pieces are only meaningful
through the chunker.** Browse the underlying
storage with anything else and you own a jigsaw.

## `cache` — one paragraph, honestly

rclone has a `cache` backend that wraps a remote
with a local disk cache, historically used to make
mounted cloud storage feel faster. It is
**(documented-only in this guide)**: rclone's own
documentation marks the cache backend as deprecated
and points users at the VFS cache built into
`mount` instead. It is named here so an old config
or forum post mentioning it doesn't confuse you —
not as something to build new work on.

**Check:** for any layered remote, the two-view
test from chapter 10 applies — list through the
layer, then list the underlying storage directly.
If you can't explain the difference between the
two listings, don't put real data through the
layer yet.
