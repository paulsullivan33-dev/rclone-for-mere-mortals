# Glossary

**Backend** — the type of a remote: the code that
knows how to talk to one kind of storage (`local`,
`drive`, `s3`, `crypt`, and about seventy more).

**Bisync** — rclone's two-way sync command. Keeps
state between runs and resolves double edits into
`.conflict` files. Classed as experimental by
rclone's own docs (chapter 12).

**Checksum / hash** — a short fingerprint computed
from a file's contents (MD5, SHA-1, and friends).
Two matching hashes are, for practical purposes,
the same file. What `check` compares when it can.

**Chunk** — one piece of a large file as stored by
a `chunker` remote, next to a small metadata file
that describes how the pieces reassemble
(chapter 11).

**Config file** — the INI file holding every
remote's definition, including credentials and
crypt keys (obscured, not encrypted). Find yours
with `rclone config file`. Handle it like a key.

**Crypt remote** — a layered remote that encrypts
contents (and optionally names) before they reach
the remote underneath it. The underneath storage
sees only ciphertext (chapter 10).

**Dry run** — `--dry-run`: rehearses a command,
changing nothing, narrating each skipped copy,
delete, and move as a `NOTICE`.

**Filter** — the pattern and fact rules
(`--include`, `--exclude`, `--filter-from`,
`--max-age`, `--min-size`, …) deciding which files
a command can see. Applies to every verb.

**Layered remote** — a remote whose storage is
another remote's path: crypt over Drive, chunker
over S3, alias over a folder. Layers compose.

**Listing** — bisync's saved record of what each
side contained after a run; the history that lets
the next run tell "new" from "deleted."

**Obscure** — rclone's reversible encoding for
passwords in the config file, applied by
`rclone obscure`. Stops casual reading; stops
nothing else.

**Remote** — a named storage place: a name, a
backend type, and its settings, defined in the
config file. Addressed as `remote:path`.

**Salt** — the crypt remote's second secret
(`password2`). Seasons the encryption key; needed,
with the password, to decrypt anything.

**Server-side move/copy** — a rename or copy the
storage performs internally, without bytes passing
through your machine. Fast, and reported as such.

**Sync (the verb)** — `rclone sync`: make the
destination match the source, deletions included.
Not a synonym for copying (chapter 6).

**VFS** — rclone's virtual filesystem layer, what
`mount` uses to present a remote as a local folder,
including its cache modes (chapter 12).
