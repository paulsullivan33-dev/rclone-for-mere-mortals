# Bisync, the Two-Way Street

**Scope:** `rclone bisync`, the command that keeps
two places in step with *each other* — edits on
either side propagate both ways. It is the most
requested shape of sync and the one needing the
clearest warnings, so it gets its own short chapter
and a conflict you can watch happen.

**Status, stated plainly: rclone's own docs class
bisync as experimental.** It has been in the tool
for years and many people run it happily, but it
carries more sharp edges than the one-way verbs,
its behaviour is still evolving, and it is not the
tool to point at the only copy of anything. The
lab ran it between two throwaway folders. So should
you, first.

## The first run is a `--resync`

Bisync tracks state — it keeps listings of both
sides so later runs can tell "new here" from
"deleted there." The first run has no history, so
it needs `--resync` to build one, which makes the
two sides match (path 1 wins ties):

```
$ rclone bisync side-a side-b --resync -v
INFO  : Synching Path1 "side-a/" with Path2 "side-b/"
INFO  : from-a.txt: Copied (new)
INFO  : shared.txt: Copied (new)
INFO  : Bisync successful
```

## Then both sides change

The lab made three edits: a new file on side B, an
extra line in side A's copy of `shared.txt`, and a
*different* extra line in side B's copy. The
uncontested changes flowed both ways — `from-b.txt`
arrived on side A without being asked twice. The
contested one produced the instructive part:

```
ERROR : shared.txt: md5 differ
NOTICE: - WARNING  New or changed in both paths - shared.txt
NOTICE: - Path1  Renaming Path1 copy - side-a/shared.txt.conflict1
NOTICE: - Path2  Renaming Path2 copy - side-b/shared.txt.conflict2
INFO  : Bisync successful

$ ls side-a side-b
side-a:
from-a.txt
from-b.txt
shared.txt.conflict1
shared.txt.conflict2

side-b: (identical)
```

And the two conflict files hold the two versions,
intact — one ends in the line `milk`, the other in
`eggs`. Read the outcome carefully, because it is
bisync's whole philosophy in one listing:

- **Nobody's edit was lost.** Both versions survive
  on *both* sides.
- **Nobody's edit won, either.** The name
  `shared.txt` no longer exists until a human picks
  a winner, renames it back, and lets the next run
  propagate the decision.
- The run still reports **Bisync successful** —
  a conflict handled by the rules *is* success, so
  a script watching exit codes will not notice.
  Watching for `.conflict` files is the operator's
  job.

## Rules for living with it

1. **Two-way is a commitment.** A deletion on
   either side is a change like any other and will
   propagate. Bisync with a careless moment on one
   machine is a faster way to lose a file in two
   places.
2. **Conflicts are a normal output, not an error.**
   If both sides edit the same files often, you
   will collect `.conflict` files steadily; budget
   the tidying time or choose one-way sync with a
   designated primary instead.
3. **Keep the state healthy.** Bisync keeps its
   listings and a lock in a work directory; a run
   interrupted at the wrong moment can demand a
   fresh `--resync` **(documented)** — which
   re-imposes "path 1 wins," so read the state of
   both sides before running it.
4. **Start with data you can afford to hand-fix.**
   A documents folder you actively edit on two
   machines is the honest use case. An archive is
   not — archives want chapter 15's one-way `copy`.

**Check:** after any bisync run in anger, `ls`
both sides for `.conflict` files before assuming
the trees agree. Silence is not agreement here.
