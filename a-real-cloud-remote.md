# A Real Cloud Remote

**(Documented — this whole chapter.)** Nothing in
it was run against a real account. The lab's rule
was absolute: local remotes only, no credentials,
no cloud. What follows is the real shape of the
process, from rclone's documentation, so that when
you do it yourself nothing about it is a surprise.
Every command in the other chapters then works
unchanged against the remote you create — that was
the point of learning on local storage.

## The shape of every cloud setup

Whatever the provider, creating a cloud remote is
three moves:

1. **Create a remote of the right type** in
   `rclone config` (interactive) or `config create`.
2. **Prove who you are** — by signing in through a
   browser (OAuth), or by pasting keys the provider
   issued.
3. **Test read-only first**: `lsd`, `lsf`, `size`,
   `about` from chapter 3, before any verb that
   writes.

## Google Drive, step by step

Drive is the backend readers of this guide most
often want — it's the far end of the log-upload
pattern in chapter 15. Documented steps:

1. Run `rclone config`. Choose **n** for a new
   remote, give it a name (`gdrive` is the
   conventional one), and pick **drive** from the
   list of storage types.
2. Leave the client ID and secret blank for the
   quick path — *or*, the step this guide
   recommends, create your own OAuth client ID in
   the provider's developer console first. rclone's
   shared built-in client is rate-limited across
   all its users; your own client ID is fifteen
   minutes of console clicking that removes a whole
   category of mysterious throttling, and it's the
   setup the official Drive documentation walks
   through.
3. Choose the scope — full access, or the narrower
   "see only files rclone created" option, which is
   the safer default for a single-purpose job.
4. Say no to advanced config, and yes to auto
   config. A browser opens on the provider's own
   sign-in page. **This is the step to be sure
   about:** you are granting the token to *your*
   rclone, on the provider's real page — check the
   address bar as you would for any sign-in.
5. Back in the terminal, confirm. Then stop and
   verify before trusting it:

   ```
   rclone about gdrive:
   rclone lsd gdrive:
   rclone lsf gdrive: --max-depth 1
   ```

6. The resulting config section holds a token
   (JSON, including a refresh token) in place of a
   password. Chapter 2's warning applies at full
   strength: **this file is now a key to the
   account.** Permissions 600, never in git.

For a headless machine with no browser, the same
flow works by running the sign-in half on a machine
that has one (`rclone authorize`) and pasting the
resulting token where the headless config asks for
it **(documented)** — the token still ends up in
that machine's config file, with the same warning
attached.

## Key-based backends, in one paragraph

S3-shaped storage (Amazon S3, Backblaze B2's
S3 interface, Wasabi, and friends) skips the
browser: the provider's console issues an access
key ID and a secret, and both go into the remote's
config — created non-interactively with
`rclone config create name s3 ...` in exactly the
style chapter 2 used **(documented for these
backends)**. Create a *dedicated* key per job
where the provider allows it, scoped as narrowly
as it allows; a leaked key that can only write one
bucket is a bad day, while a leaked master key is
a bad month.

## What transfers from the lab, unchanged

Everything. `gdrive:backups` is addressed like
`local1:store/documents`; `copy`, `sync`, `check`,
filters, crypt layered on top, and the exit codes
behave as the earlier chapters showed, because the
verbs never knew what was behind the name. The
differences a real backend introduces are of
degree, not kind: transfers are slower, `about`
shows a quota instead of a disk, name rules are
the provider's (Drive, for instance, permits
duplicate file names in a folder, which is why
rclone has a `dedupe` command **(documented)**
for tidying them), and deleting is forever in a
different way — chapter 6's `--backup-dir` habit
is worth *more* against a service, not less.
