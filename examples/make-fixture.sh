#!/bin/sh
# make-fixture.sh -- build the small source tree used across the guide.
# Usage: sh make-fixture.sh [target-dir]   (default: fixture-src)
# Everything in it is planted and deterministic, so every output in
# the guide can be reproduced by running the same commands.
set -eu

SRC="${1:-fixture-src}"

mkdir -p "$SRC/notes" "$SRC/logs" "$SRC/photos" "$SRC/drafts" "$SRC/archive"

printf 'Buy filament\nWater the plants\nBack up the laptop\n' \
    > "$SRC/notes/todo.txt"

printf '# Ideas\n\n- A shelf for the router\n- Labels for the cable box\n' \
    > "$SRC/notes/ideas.md"

printf '2026-10-19 08:00 backup started\n2026-10-19 08:01 backup finished ok\n' \
    > "$SRC/logs/2026-10-19.log"

printf '2026-10-20 08:00 backup started\n2026-10-20 08:01 12 files copied\n2026-10-20 08:01 backup finished ok\n' \
    > "$SRC/logs/2026-10-20.log"

# A photo stand-in: the lab deals in names and sizes, not real images.
printf 'stand-in for a photo of the cat\n' > "$SRC/photos/cat.jpg"

# One file big enough to be split by the chunker demo (2.5 MiB of zeros).
dd if=/dev/zero of="$SRC/photos/big-scan.bin" bs=1024 count=2560 2>/dev/null

printf '# Weekly report\n\nDraft in progress.\n' > "$SRC/drafts/report.md"
printf 'scratch numbers, safe to lose\n'        > "$SRC/drafts/scratch.tmp"
printf 'an old note from 2020\n'               > "$SRC/archive/old-note.txt"

# Plant an old modification time so age filters have something to bite on.
touch -d "2020-06-15 12:00:00" "$SRC/archive/old-note.txt"

find "$SRC" | sort
