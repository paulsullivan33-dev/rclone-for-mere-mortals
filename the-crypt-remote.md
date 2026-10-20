# The Crypt Remote

**Scope:** the guide's centrepiece after the safety
chapter. A `crypt` remote wraps any other remote
and encrypts everything passing through it — file
contents *and*, if you ask, file and directory
names. The storage underneath only ever sees
ciphertext. Every step below was run against a
local folder standing in for the storage; on a real
account the only difference is which remote sits
underneath.

## Why, and what it is not

Use crypt when the storage is not yours to trust
with plaintext: a cloud account you'd rather held
ciphertext, a shared drive, an off-site copy at a
friend's house. The encryption happens on *your*
machine, before anything leaves it — the provider
cannot read the contents and, with name encryption
on, cannot even list them meaningfully.

It is not: protection against someone who has your
config file (the keys are in there, obscured —
chapter 2's locked screen door), or a backup
strategy, or encryption of data on your own disk.
And it has one absolute property to respect: **lose
the password and the salt, and the data is gone.**
Not "hard to recover." Gone. There is no provider
reset flow for a key the provider never had.

## Creating it

A crypt remote is created like any other, layered
over an existing remote path. Passwords are fed in
through `rclone obscure` (chapter 2) so they don't
sit in the config as plain text:

```
$ rclone config create secret crypt \
    remote local1:store/encrypted \
    password "$(rclone obscure mere-mortals-lab-password)" \
    password2 "$(rclone obscure lab-salt-1234)" \
    filename_encryption standard \
    directory_name_encryption true

[secret]
type = crypt
remote = local1:store/encrypted
filename_encryption = standard
directory_name_encryption = true
password=<redacted>
password2 = *** ENCRYPTED ***
```

Three settings deserve a sentence each:

- **`password`** encrypts the contents; **`password2`**
  is the *salt*, a second secret that seasons the
  key. Both are needed to read anything back.
- **`filename_encryption standard`** encrypts file
  names into the gibberish below. `off` keeps names
  readable (contents still encrypted); `obfuscated`
  scrambles them reversibly without the key
  **(the other two modes are documented; `standard`
  is the one run here)**.
- **`directory_name_encryption true`** does the same
  for folder names. (The lab password above is a
  throwaway for a lab that holds nothing; yours
  should be long, unique, and written down somewhere
  that is not only your config file.)

## Write through it, then look from underneath

Copying to `secret:` looks completely ordinary:

```
$ rclone copy fixture-src/notes secret:notes -v
INFO  : new-note.txt: Copied (new)
INFO  : todo.txt: Copied (new)

$ rclone lsf secret:notes
new-note.txt
todo.txt
```

Now look at the *same place* through the underlying
remote — this is what the storage provider sees:

```
$ rclone lsf local1:store/encrypted --recursive
q8rvfbteevaqt9j6qcha1epjfs/
q8rvfbteevaqt9j6qcha1epjfs/8tbne872jfbudtv32cos43heps
q8rvfbteevaqt9j6qcha1epjfs/sd0h3g6l2dopg4pmg35fk3s7s0
```

The directory name is ciphertext. The file names
are ciphertext. And the files themselves begin
with rclone's format header and then noise:

```
$ head -c 120 <a stored file> | od -c | head -4
0000000   R   C   L   O   N   E  \0  \0   K 360 205 200 ...
0000020 232   o 204   & 244   3 201 205   } 367 ...
```

That `RCLONE\0\0` header is the format introducing
itself; after it, nothing readable exists to find.

## Reading it back — and proving it

Copying *out* of `secret:` decrypts on the way:

```
$ rclone copy secret:notes restored-notes -v
INFO  : new-note.txt: Copied (new)
INFO  : todo.txt: Copied (new)

$ diff -r fixture-src/notes restored-notes
[exit 0]
```

`diff` is silent and exits 0: what came back out of
encrypted storage is byte-for-byte what went in.
`rclone cat secret:notes/todo.txt` prints the
plaintext directly, and the purpose-built verifier
agrees with both:

```
$ rclone cryptcheck fixture-src/notes secret:notes
NOTICE: Encrypted drive 'secret:notes': 0 differences found
NOTICE: Encrypted drive 'secret:notes': 2 matching files
```

## The wrong password, experienced

A second crypt remote over the same storage, with
a wrong password, doesn't produce a friendly
"access denied." It produces this:

```
$ rclone lsf wrongpass:notes
ERROR : error listing: directory not found
[exit 3]
```

That's name encryption doing its job from the other
side: with the wrong key, even the *directory name*
`notes` encrypts to something that doesn't exist,
so there is nothing to list. (Keep this symptom for
chapter 16 — on a real setup, "directory not found"
from a crypt remote usually means the config's
password, salt, or name-encryption settings don't
match the ones the data was written with.)

**Check:** after building any crypt remote, run
the lab's round trip on one small file before
entrusting it with real data — copy in through the
crypt name, view the underlying storage with the
base remote, copy back out to a fresh folder, and
`diff`. If all four steps behave as above, the
layer is sound.
