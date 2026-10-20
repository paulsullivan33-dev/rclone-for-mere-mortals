# Mount and Serve

**Scope:** the two ways rclone presents storage as
something other programs can use — as a folder on
this machine (`mount`), and over the network
(`serve`). One of them the lab could run; the other
it could not, and the failed capture is included
because it's the honest answer.

## `rclone mount` — storage wearing a folder's clothes

`rclone mount remote:path /some/folder` makes the
remote appear as a directory, so tools that know
nothing about rclone — a file manager, a media
player, a backup program — can read and write it
as local disk. On a normal Linux desktop, or on
macOS and Windows with their filesystem helpers,
this works and is genuinely useful for browsing and
light editing.

The lab's build machine has no FUSE device, and the
attempt's output is worth quoting exactly, because
servers and containers commonly lack one too:

```
$ rclone mount local1:store/documents mnt
NOTICE: mount helper error: fusermount3: fuse device not found, try 'modprobe fuse' first
CRITICAL: Fatal error: failed to mount FUSE fs: fusermount: exit status 1
[exit 1]
```

So: **mount is (documented) beyond this point in
the guide** — the lab can prove it needs FUSE and
nothing more. Three documented cautions travel
with it:

- A mount is a **view, not a sync.** Files are
  fetched and stored back as they're used; it has
  none of `sync`'s guarantees and all of the
  network's latency.
- The **`--vfs-cache-mode`** setting decides how
  honest that illusion is. Modes below `full` can
  refuse operations real programs expect (seeks,
  rewrites); `full` caches whole files locally, at
  disk-space cost. This setting is why old advice
  about the deprecated cache backend (chapter 11)
  mostly routes here now.
- Unmount cleanly (`fusermount -u` or stopping the
  command) so cached writes flush — a killed mount
  is a small data-loss story waiting to be told.

## `rclone serve` — storage over a protocol

`serve` speaks for the remote instead: HTTP,
WebDAV, FTP, SFTP, and DLNA are among its dialects
**(the list is documented; HTTP is the one run
here)**. The lab served the documents folder
read-only on a loopback port and asked it for a
file with curl:

```
$ rclone serve http local1:store/documents --addr 127.0.0.1:18099 --read-only
NOTICE: Local file system at store/documents: HTTP Server started on [http://127.0.0.1:18099/]

$ curl -s http://127.0.0.1:18099/notes/todo.txt
Buy filament
Water the plants
Back up the laptop
Feed the cat
one more line

$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18099/logs/
200
```

The file's contents cross the wire; a directory
URL answers 200 with a listing page. Two habits
from that run generalise: `--read-only` unless a
client genuinely must write, and bind addresses
chosen on purpose — the lab used loopback because
the demo needed no network. rclone's serve can add
authentication and TLS **(documented)**; an
unauthenticated serve on a reachable address is a
published folder, whether you meant it or not.

**Scope note:** serve is how you *offer* storage,
not how you back it up. Jobs that must land files
reliably still belong to `copy`/`sync` and a log
file.
