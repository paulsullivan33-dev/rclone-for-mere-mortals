# Remotes and Config

**Scope:** where rclone keeps its names, how to
create one without the interactive prompts, and why
the config file deserves the same care as a key.

## The config file

All remotes live in one text file. Ask where yours
is before you go hunting:

```
$ rclone config file
Configuration file is stored at:
/home/hatch/workspace/rclone-lab/rclone.conf
```

That path is the lab's, not the default. The lab
sets the environment variable `RCLONE_CONFIG` to
keep its config separate from any real one, and you
should consider doing the same while experimenting:

```
export RCLONE_CONFIG="$HOME/rclone-lab/rclone.conf"
```

Left alone, rclone uses the standard per-user
config location for your platform **(documented)**.
The file itself is plain INI — one bracketed
section per remote:

```
[local1]
type = local
```

## Creating a remote, non-interactively

`rclone config` on its own walks you through
questions — fine the first time, miserable in a
script. The scriptable form names everything up
front:

```
$ rclone config create local1 local
[local1]
type = local
```

A `local` remote needs nothing else: it addresses
paths on the machine, so `local1:store/documents`
means "the `store/documents` path from where the
command runs" (or an absolute path —
`local1:/mnt/nas/documents` works the same). Other
types take their settings as further name/value
pairs on the same line; the crypt remote in chapter
10 is created exactly this way.

Three commands cover daily config life:

```
$ rclone listremotes        # the names you have
$ rclone config show local1 # what one of them is
$ rclone config delete old  # retire a name (documented)
```

## The honest warning about this file

The config file holds credentials: OAuth tokens for
cloud accounts, and crypt passwords stored
*obscured* — encoded so they are not plain text on
the screen, but trivially reversible by anyone who
has the file. Chapter 10 shows the encoding happen:

```
$ rclone obscure mere-mortals-lab-password
xGNAeS5T9b9E0S3rH2Ib2nTYtm3DV-GeDtb2PCR9Rz-...
```

That string is a locked screen door, not a safe: it
stops a casual glance, nothing more. Treat
`rclone.conf` like an ssh private key —

- keep its permissions at `600`,
- don't commit it to git, don't paste it into
  issues or chats,
- and know that anyone who copies it owns every
  remote in it.

**Check:** after creating a remote, `rclone lsd
local1:.` (listing the current directory through the
remote) should print your folders. If it errors with
`directory not found` and exit code 3, the name or
the path is wrong — chapter 16 collects the codes.

**Scope note:** rclone can encrypt the whole config
file with a password of its own, at the cost of
typing it (or supplying it via environment) on
every run. It exists and is worth it on shared
machines; it is **(documented)** — the lab ran with
an unencrypted lab-only config on purpose, so the
file's shape stayed readable.
