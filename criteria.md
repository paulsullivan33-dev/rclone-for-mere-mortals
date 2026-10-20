# Writing Criteria

Every guide in this repo is written to the same standard. If you're
adding or editing a guide — human or AI — hold it to these.

1. **Plain words, real ideas.** Simple language, never dumbed-down
   concepts. Explain jargon on first use; collect terms in the
   glossary.
2. **No hype.** No marketing adjectives, no "revolutionary," no
   promises about what something will do for the reader.
3. **Honest about limits.** Say what the thing *can't* do. State
   uncertainty instead of smoothing it over. Validation notes include
   what remains unverified.
4. **No invented numbers.** Benchmarks, defaults, and specs are either
   measured or qualified with "depends on your setup." If it wasn't
   tested, say so.
5. **Checkable.** Commands are meant to be run, with "Check:" blocks
   showing what success looks like. Sources are linked, not asserted.
6. **Respect the reader's setup.** Call out Windows/Mac/Linux
   differences. Don't assume a GPU, a budget, or prior experience.
7. **Safety isn't skipped.** Real risks get stated plainly, not buried.
8. **Scoped.** Each guide says what it covers and points elsewhere for
   the rest. No guide pretends to be the whole subject.
9. **Structure over prose.** Tables, before/after examples,
   symptom → fix. Scannable beats essay.

## Verification notes for this guide

Standard 3 and 4 applied to this guide, specifically. All live work
used rclone v1.75.2 (official static binary) on Linux, an isolated
config (`RCLONE_CONFIG` pointing into the lab), and LOCAL remotes
only — a folder on disk played the part of "the cloud." No real
cloud account, credential, or pre-existing rclone configuration was
touched at any point. Full transcripts of every captured run are
kept with the lab (numbered 01–16).

**Verified by running:**

- Config: `config create` for a `local` remote, `listremotes`,
  `config show`, `config file`, and the file's INI shape. `rclone
  obscure` output captured — and quoted in chapter 2 as evidence
  that obscuring is encoding, not encryption.
- Looking around: `lsd`, `ls`, `lsf` (including `--recursive` and
  `--files-only`), `size`, `tree`, and `about` against the planted
  fixture, outputs as printed in chapter 3.
- `copy`: a full first copy of the 9-file fixture (2.500 MiB), a
  second copy reporting "There was nothing to transfer," and a
  delta copy after a one-line append plus one new file — which
  transferred 79 B, the *whole* edited file plus the new one,
  demonstrating whole-file (not block-delta) semantics.
- `sync` deletions, exactly as chapter 6 shows: a planted
  destination-only file and a source-deleted file were announced
  in a `--dry-run` ("Skipped delete"), then actually deleted by
  the real run, with the footer's `Deleted: 2 (files)` line.
- `--max-delete 1` against three pending deletions: one file was
  deleted, the run then failed fatally, exit code **7**.
- `--backup-dir`: the two remaining pending deletions were moved
  server-side into the rescue remote path instead of being
  deleted; contents verified intact with `cat`.
- `move` between two paths on one remote, reported as
  `Moved (server-side)`; the source was gone afterwards.
- The `copy`/`copyto` trap, produced by accident and kept:
  `copy` to a file-shaped destination created a *directory* of
  that name containing the file; `copyto` delivered the file
  under the intended name, `cmp` exit 0.
- `purge` of a populated tree: every file deleted, every
  directory removed, no confirmation asked.
- `--dry-run` narration: `NOTICE: … Skipped copy as --dry-run is
  set` lines for every file, and no destination directory
  created. `--log-file` captured a complete run log. `--progress`
  without a terminal printed only the final stats block (the
  chapter says so).
- `check`: a planted content change and a missing file produced
  named differences and exit code **1**; `--size-only` agreed;
  after a repairing `sync`, `check` reported 0 differences and
  exit 0; `check --download --size-only` also passed. `hashsum
  MD5` printed real hashes for the local backend.
- Exit codes produced for real: 0 (all clean runs, including
  nothing-to-transfer), 1 (check differences), 3 (listing a
  missing directory; copying from a missing source, after the
  default 3 attempts), 7 (fatal error, the max-delete cap).
- Filters: `--exclude '*.tmp'`, `--include '*.log'`, a two-rule
  `--filter-from` file (shipped in `examples/`), `--max-age 24h`
  excluding exactly the planted 2020 file, `--min-size 1M`
  matching exactly the one big file, and a filtered `copy` whose
  destination listing confirmed the excluded file never arrived.
  `--files-from` copied exactly the two listed files.
- Crypt: a `crypt` remote created over the local remote with
  standard filename encryption and directory name encryption.
  Copied through it, the notes appeared normally via the crypt
  name; via the underlying remote, directory and file names were
  ciphertext and file contents began with the `RCLONE\0\0`
  header followed by unreadable bytes (od dump captured).
  Copying back out produced a tree `diff -r` judged identical
  (exit 0); `cryptcheck` reported 0 differences; `rclone cat`
  through the crypt remote printed plaintext. A second crypt
  remote with a **wrong password** could not even list:
  "directory not found," exit 3 — because the directory name
  itself is encrypted.
- Layered remotes: an `alias` remote answered listings through
  its short name. A `chunker` remote at chunk size 1M stored the
  2.5 MiB fixture as two 1 MiB chunks, one 512 KiB chunk, and a
  77-byte metadata file, and reassembled it byte-identically.
- Bisync: `--resync` initialised two folders; after new files on
  one side and *conflicting* edits to a shared file on both,
  a normal run propagated the new file, renamed both edits to
  `shared.txt.conflict1` / `.conflict2` on **both** sides
  (contents verified — one ends "milk", the other "eggs"),
  removed the contested name, and still reported
  "Bisync successful."
- `serve http` on a loopback address with `--read-only`: a real
  HTTP GET returned a file's contents and a directory URL
  returned 200. The server was stopped after the capture.
- The worked example: the shipped `sync-logs.sh` ran twice for
  real. Between runs a new log appeared on the "device" and the
  oldest local log was deleted (rotation); the archive ended
  holding all three files while the device held two — `copy`,
  not `sync`, demonstrated end to end.

**Documented-only (not run), and why:**

- **Real cloud remotes, including the Google Drive OAuth flow**
  (all of chapter 13): deliberately out of scope for the lab —
  no credentials were used and no real account was touched.
  Steps are described from rclone's official documentation.
- **`rclone mount` succeeding:** the build machine has no
  `/dev/fuse`. The attempt was run and its failure captured
  verbatim ("fusermount3: fuse device not found… failed to
  mount FUSE fs," exit 1); mount behaviour, `--vfs-cache-mode`,
  and clean unmounting are described from documentation.
- **The interactive `rclone config` walkthrough:** the lab
  created every remote non-interactively with `config create`.
  The interactive prompts are referenced, not reproduced.
- **The `cache` backend:** rclone's own documentation marks it
  deprecated; it is described in one paragraph so old references
  make sense, and was not built or run.
- **`filename_encryption` modes `off` and `obfuscated`:**
  `standard` was run end to end; the other two are named and
  contrasted from documentation.
- **`rclone ncdu`, `--format` field shaping in `lsf`,
  `dedupe`, serve protocols other than HTTP, config-file
  encryption, `--suffix` naming for backups, `--log-level`
  tuning, `mkdir`:** named where a reader will meet them;
  no chapter claim rests on their output.
- **cron and systemd actually firing:** the worked-example
  script was run by hand; the cron line and the systemd
  service/timer are shipped as files in `examples/` and
  described. No job was installed on the build machine.
- **Windows and macOS specifics** (config locations, mount
  helpers): the lab is Linux; platform differences are flagged
  as documented where the chapters mention them.
