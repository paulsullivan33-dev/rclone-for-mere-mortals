# What rclone Is

**Scope:** the one idea everything else hangs on —
storage has *names* — and how rclone differs from
rsync, because confusing them is where trouble
starts.

## A remote is a name for a place

rclone never asks you to learn a different tool per
storage service. Instead you define a **remote**
once — a name, a type, and whatever that type needs
(an account, a bucket, a folder) — and from then on
every command addresses storage as:

```
remote:path/to/the/thing
```

The lab in this guide defines a remote called
`local1` whose type is `local` — ordinary folders on
the same disk:

```
$ rclone listremotes
local1:
secret:
docs:
chunked:
```

(`secret`, `docs`, and `chunked` arrive in later
chapters; they are layered remotes, built on top of
`local1`.) A real setup might also have `gdrive:`
for Google Drive or `b2:` for Backblaze. The verbs
don't change. `rclone copy holiday-photos gdrive:photos`
and `rclone copy holiday-photos local1:store/photos`
are the same sentence with a different place named.

Two consequences worth fixing in memory now:

- **A plain path needs no remote.** `rclone copy
  ./notes ./backup` works, and both sides are just
  folders. Remotes earn their keep when a side is a
  service, an encryption layer, or a place you refer
  to often enough to want a short name.
- **The colon is the tell.** `store/documents` is a
  folder under where you stand. `local1:store/documents`
  is "the `documents` folder inside `store`, as the
  remote called `local1` sees it." For a `local`
  remote those happen to be the same bytes; for
  Drive, only the second form exists.

## rclone is not rsync

They look alike — both move trees, both have a sync
mode that deletes — and the resemblance misleads.
The differences that matter:

| | rsync | rclone |
|---|---|---|
| Built for | host ↔ host over ssh or its daemon | storage services and their APIs |
| What crosses the wire | changed *blocks* of a file | the whole changed file |
| Addressing | `host:path` | `remote:path`, ~70 backend types |
| Directory slash trap | yes, famous | no — but see `copy` vs `copyto` in the verbs chapter |
| Delete-to-match | `--delete`, off by default | `sync`, a separate verb, always on |

The whole-file point is not theory. In the lab, one
line was appended to a 49-byte file, and the next
`copy` reported:

```
Transferred:           79 B / 79 B, 100%
```

79 bytes is the full 62-byte file plus a 17-byte new
file — the append cost a whole re-send. At lab sizes
nobody cares. At "the 4 GB video changed slightly"
sizes, rsync's delta is a feature rclone simply
does not have. Choose accordingly: rsync between
hosts you control, rclone when a storage API is
involved.

## Where rclone fits

The jobs rclone is genuinely best at:

- **Feeding cloud storage from scripts.** Upload
  this folder to that bucket/Drive, on a schedule,
  unattended — this guide's worked example is
  exactly that pattern, and it is how the tool earns
  its keep in real home labs (log folders shipped to
  Drive every few minutes by a cron job).
- **Moving between services.** `remote:` on both
  sides works; neither side needs to be a disk.
- **Encrypted storage on an untrusted place** via
  the crypt remote (chapter 10) — the service stores
  ciphertext; only your config knows the names.
- **Inspecting storage uniformly.** One set of
  listing and checking verbs across every service
  you use (chapter 3 and chapter 8).

What it is not: a backup program by itself (it has
no history or retention unless you build them), a
delta-sync tool, or a mounting tool first — mounting
exists (chapter 12) but is a view, not a sync.

**Scope note:** everything in this guide was run on
Linux with rclone v1.75.2. rclone also runs on
macOS and Windows with the same commands; paths and
config locations differ slightly **(documented)**.
