# rclone for Mere Mortals

**rclone** is a command-line tool for moving files
between storage you control — a folder on this
machine, a USB drive, an S3 bucket, Google Drive,
and some seventy other places — through one set of
verbs. You name a storage place once (a *remote*),
and then `copy`, `sync`, `move`, and `check` work
the same whatever is behind the name.

It is often introduced as "rsync for cloud storage,"
and that is close, but the difference matters and
this guide draws it early: rsync moves trees between
hosts and sends only the changed *bytes*; rclone
speaks each storage service's own API and re-sends
whole *files* that have changed. Different tools,
different dangers. rclone's `sync` will delete
files at the destination to make it match — exactly
as cheerfully as rsync's `--delete` — so this guide
teaches the same habits its rsync sibling does: dry
runs first, output you can read, and safety nets on
anything that deletes.

Every hands-on command in this guide was run for
real (rclone v1.75.2) against **local remotes
only** — folders on disk dressed up as storage —
in a small planted lab you can rebuild from
`examples/make-fixture.sh`. Nothing here touches a
real cloud account. The one chapter that describes
connecting a real Google Drive account says so in
its title and is marked **(documented)**: the steps
are real, but no credentials were used making this
guide, and none of its outputs come from a cloud
service. The few other things that could not be run
in the lab are marked the same way.

It assumes you use a terminal and know what files,
folders, and a shell prompt are. One ordinary
machine is enough for everything except the
documented chapter.

## What this guide covers

- [**What rclone is**](what-rclone-is.md) — remotes,
  paths that name a place, and how this differs from
  rsync
- [**Remotes and config**](remotes-and-config.md) —
  the config file, creating a local remote, and why
  the file deserves care
- [**Looking around**](looking-around.md) — `lsd`,
  `ls`, `lsf`, `size`, `tree`, and `about`
- [**The core verbs**](the-core-verbs.md) — `copy`,
  `sync`, `move`, and the `copyto` lesson every new
  user learns once
- [**Dry runs, logs, and exit codes**](dry-runs-and-logging.md) —
  `--dry-run` as a way of life, reading the stats
  footer, and the numbers scripts should trust
- [**Deleting, carefully**](deleting-carefully.md) —
  what `sync` really does to the destination, and
  the nets: `--max-delete` and `--backup-dir`
- [**Filters**](filters.md) — include, exclude,
  filter files, and age and size limits
- [**Check and verify**](check-and-verify.md) —
  proving two trees match, and hashes
- [**The crypt remote**](the-crypt-remote.md) —
  encryption layered over ordinary storage, tested
  end to end on a local folder
- [**Layered remotes**](layered-remotes.md) — alias
  names, chunker splitting big files, and a word
  about cache
- [**Bisync**](bisync-two-way.md) — two-way sync,
  its conflict files, and why it carries warnings
- [**Mount and serve**](mount-and-serve.md) —
  storage as a folder, and storage over HTTP
- [**A real cloud remote**](a-real-cloud-remote.md) —
  the Google Drive sign-in flow, documented only
- [**Scheduling it**](scheduling-it.md) — cron and
  systemd timers, the unattended pattern
- [**A worked example**](worked-example.md) — a log
  archive that grows on a schedule and never
  deletes, run end to end
- [**Troubleshooting**](troubleshooting.md) —
  symptom → fix, with the real error messages
- [**Glossary**](glossary.md) — the terms, collected
  in one place

## What it doesn't cover

The seventy-odd backends individually (the official
docs at rclone.org cover each one), the VFS layer in
depth, rclone's GUI and its `rc` remote-control API,
and backup strategy. For the rsync side of the
family see the companion guide, *rsync for Mere
Mortals*; for what to keep and how long, *Backups
for Mere Mortals*.

## How to use this guide

Skim the first three chapters and you understand the
shape of every rclone command you will ever write.
Run the worked example and you have the pattern most
people actually automate. The middle chapters are
reference for the day a sync does something you
didn't expect — which, with a tool that deletes to
make things match, is a day that comes for everyone.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [rsync for Mere Mortals](https://paulsullivan33-dev.github.io/rsync-for-mere-mortals/)
- [Backups for Mere Mortals](https://paulsullivan33-dev.github.io/backups-for-mere-mortals/)
- [Nextcloud for Mere Mortals](https://paulsullivan33-dev.github.io/nextcloud-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/rclone-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/rclone-for-mere-mortals/blob/main/LICENSE-CODE).
