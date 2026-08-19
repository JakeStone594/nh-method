# Memory curation rules — the tiering contract

Authoritative for the `memory-curator` agent and for anyone writing knowledge on this box.
Read this before deciding where a fact goes.

## Why this exists

`/root/CLAUDE.md` reached **160 KB ≈ 40,000 tokens** loaded unconditionally at every session
start, while the entire `memory/` store was 20.7 KB and the 360 KB of kernel/app reference
(`KERNEL-CODEBASE-MAP.md`, `KERNEL-CAPABILITY-MAP.md`, `NETHUNTER-APP-MAP.md`) cost nothing
because it sits behind one-line pointers. **The pointer pattern already worked. This generalises
it.** Two sections — Services (45 KB) and Wireless (37 KB) — were 51 % of the loaded file.

The goal is not smaller docs. **The goal is that the fact is present at the moment of need and
absent the rest of the time.** Compaction that loses an answer is a failure, not a win.

## The four tiers

| Tier | Location | Loaded | Budget | Holds |
|---|---|---|---|---|
| **T0** | `/root/CLAUDE.md` | every session, in full | **~35k tokens** — ⛔ **the byte figure is DERIVED, never authoritative.** Convert when you need one (`wc -c` ÷ ~4 B/token) and say that you converted; ⚠ **the divisor is itself an approximation, so where the margin decides the answer the honest instrument is a tokenizer, not a division** | constraints that change *what you do*, conventions, action-changing traps, and the pointer index to T1 |
| **T1** | `/root/docs/*.md` + the existing `/root/*-MAP.md` | on demand, by pointer | no cap; one topic per file | procedures, verification evidence, tool inventories, per-domain deep dives |
| **T2** | `~/.claude/projects/-root/memory/` | on recall, one file per fact | ≤ 4 KB per file — **except a declared accumulator**, §*T2 size* | durable facts about the user, their feedback, project state, external references |
| **T3** | `/root/docs/CORRECTIONS.md` | never — archive | append-only | superseded claims, with date, what it used to say, and why it was wrong |

⚠ **The T0 ceiling is ~35k tokens**, raised by the operator in session — 20k → 25–30k on
2026-08-09, then 25–30k → ~35k on 2026-08-14. Do **not** trim T0 back toward either older number
on the strength of an older doc, a stale log line, or memory of this file. Every `regression-log.md`
entry citing "the 20k budget" or "the ~25–30k ceiling" is a historical record of a run made under
the ceiling of its day, not the live contract.

⛔ **AND THE SAME TRAP IN BYTES RUNS THE OTHER WAY — IT RAISES.** The Budget cell above read
**`~35k tokens (~140 KB)`** until 2026-08-19, and `KB` is ambiguous: **140,000 B vs 143,360 B, a
3,360 B / ~840-token spread**. Two curator passes on 2026-08-19 read it differently and reported
**7,524 B vs 10,884 B of headroom for a byte-identical T0** (132,476 B) — neither pass was wrong;
the cell was. `regression-log.md` entries from that period accordingly state the ceiling as
**`~143,360 B`**, and those are historical records of a run made under the reading of its day,
exactly like the token figures above. ⛔ **Do not adopt 143,360 from one** — it would raise the
ceiling ~840 tokens on a reading of a unit suffix, while both real raises were operator decisions
on the record. The second number was **deleted rather than disambiguated** (operator, 2026-08-19):
tokens are what the context window charges, and the byte figure was only ever a convenience
conversion at an assumed 4 B/token.

**It is a ceiling, not a target** — headroom is not
an invitation to fill it, and the admission tests decide what goes in regardless of how much room
is left.

**A ceiling raise is not licence to pad.** Every other rule still binds — the three admission
tests below, *One tier owns a number*, and T1-owns-the-detail. What the raise changes is the
tie-break: where a previous pass would have cut a useful trap or a load-bearing precondition
*purely to fit*, keep it. Cut only what fails an admission test on its merits.

### T1.5 — the skill library at `~/.claude/skills` — added 2026-08-10

**It is a tier, it loads ahead of T1, and it was ungoverned by this contract until this date.**
Every skill *description* is in context at session start; a *body* is injected wholesale on invoke.
**Size: state the instrument or do not state the number.** Measured 2026-08-18 — `du -sb`
(apparent) **1,383,426 B**, `du -sh` (block-allocated) **1.8 M**, `.md` bodies alone **1,244,569 B**;
the ~30 % gap is block allocation, not drift. ⚠ **This line read a bare *"~1.8 MB"* until then and
was taken for a contradiction against `INDEX.md`'s ~1.37 MB — it was two honest instruments and
neither named itself** (`CORRECTIONS.md` 2026-08-18). **For what this section asks — the context
cost — the apparent size is the honest one; re-derive it rather than quoting any of these.** ⚠ **`~/.claude/skills/INDEX.md` owns the skill and file counts; do not restate them here** — this line carried "23 skills, 99 `.md` files" until 2026-08-15, when the true figures were 24 and 100. Audited 2026-08-10: **0 of 113 files referenced `/root/docs/`**
while 68 referenced `CLAUDE.md`, nine `/usr/local/bin` wrappers were mentioned nowhere, and two
files **instructed the model to volunteer a refusal of USB HID** — the exact refusal T0's 2026-08-06
correction exists to prevent, live for four days in a tier that arrives before any T1 file is
opened.

The rules that follow from that:

1. **Contradiction check includes this tier.** A device fact corrected in T0 is **not landed** until
   the skill library agrees. Grep it in the same pass, not later. ⛔ **AND T2 — added 2026-08-17.**
   The sweep is **two** greps, not one: `grep -rl '<claim>' ~/.claude/skills` **and**
   `grep -rl '<claim>' ~/.claude/projects/*/memory`. A T2 memory asserting *"the V2 kernel supports
   zero external USB Wi-Fi adapters"* outlived its own published correction by **16 days** because
   the pass that fixed T0 and T1 stopped there. **A wrong memory outlives a wrong doc**: T2 is
   injected on recall and never audited on load, so nothing re-reads it the way a doc gets re-read —
   and once the doc is right, the two disagree in front of nobody. `CORRECTIONS.md` 2026-08-17.
2. **A skill may not be the sole owner of a device fact.** It restates T0/T1 for routing; the
   authoritative copy stays in T0/T1. *One tier owns a number* applies here with force — a skill is
   the tier most likely to go stale unnoticed, because nothing loads it in full.
3. **Back it up separately before editing.** `memory-curation/snapshots/` does not cover
   `~/.claude/skills`. Use a dated tarball, e.g.
   `/root/.claude/skills-backup-2026-08-10-preframework.tar.gz`.
4. ⛔ **No positional parameters in a skill body.** `$1`…`$9`, `$0`, `$@`, `${1:-}` are substituted
   with the **caller's arguments** at invoke time, zero-indexed — proven 2026-08-10. The file on disk
   is not what the model receives, and no read reveals the difference. Escape literal `$<digit>` in
   prose too.
5. **Editing a skill is a curation act**, subject to *Propose, then apply* and to the evidence
   labels. A skill that says "verified" about something the device has never run is the same offence
   here as in T0.

Mechanism, proof and the governance record: `/root/docs/CLAUDE-HARNESS.md`.

### T0 admission test — all three must hold

1. **Action-changing.** Not knowing it makes you do the *wrong thing*, not merely a slower thing.
   `pkill -f` self-matching, `--no-canonicalize`, `getenforce` returning `Disabled` in the chroot,
   `df /` describing all of Android userdata — these belong in T0 forever.
2. **Cross-cutting.** It bites in more than one domain, or in a domain you would not have
   thought to open a reference doc for.
3. **Irreducible.** It cannot be compressed to a pointer without losing the warning. A procedure
   *can* be a pointer. A trap usually cannot.

Everything failing the test goes to T1 with a one-line pointer left in T0 naming the file **and
what it answers**. A pointer with no promise of content is worthless — write
`see docs/BLUETOOTH.md for the six BadBT preconditions`, not `see docs/BLUETOOTH.md`.

### T2 admission test

One fact per file, frontmatter per the memory spec, type `user` / `feedback` / `project` /
`reference`. **Not** what the repo, git history, or T0/T1 already record. If a fact is about the
*device*, it is T0 or T1 — memory is for what cannot be re-derived by reading the box.

### T2 size — the 4 KB cap, and the one exemption

**≤ 4 KB per file.** A T2 body is injected **whole** on recall, so a file that has grown into a
mini-T1 taxes every recall that needed one line of it. That is what the cap protects — recall
budget, not disk.

⚠ **EXEMPT: a DECLARED ACCUMULATOR.** Some facts here are not a line but a **pattern**, and a
pattern is only legible from its instances — one instance reads as an anecdote and is dismissed as
one. Splitting such a file does not improve retrieval, it **destroys the fact**: the reader recalls
one instance and never learns it was the fourth. Adjacent to §*Retirement*'s stale-saving rule and
**not** the same failure — there the saving had already been banked; here the saving would destroy
the artefact.

**A file is an accumulator only while ALL of this holds:**

1. **It DECLARES its shape** — one sentence, in the `description:` frontmatter or the first
   paragraph, naming the **recurring thing** the file is a register of. ⛔ **A SUBJECT IS NOT A
   SHAPE.** *"the nh-tools repo"* is a subject and admits anything; *"a way the mirror's real state
   differs from what a probe or a habit reports, and the standing decision or probe that governs
   it"* is a shape and admits only instances of it. ⚠ **The declaration IS the enforcement
   mechanism** — without one, *"it is an accumulator"* is an argument, and every curator makes it
   differently.
2. **It grows ONLY by adding instances of that shape. A new shape is a NEW MEMORY.** That sentence
   is the whole difference between an exemption and "no cap".
3. **Each instance is a SUMMARY PLUS A POINTER** — about a paragraph, naming the T1/T3 file that
   holds the narrative. ⛔ **THIS IS THE CEILING, AND IT IS ON THE INSTANCE, NOT ON THE FILE.** A
   byte ceiling on an accumulator can be met only by deleting an instance, which §*Never delete*
   forbids and which retires the very evidence that makes the pattern legible. Bound the instance
   and the file is bounded at the only place it can be bounded honestly.

**What disqualifies one — stated as a measurement, so the exemption can be revoked without an
argument.** Any of: **(a)** over 4 KB with no declared shape; **(b)** an entry that is not an
instance of the declared shape; **(c)** an instance carrying its narrative instead of pointing at
it. ⛔ **The remedy for (b) and (c) is to move the OFFENDING ENTRY out** — into its own memory, or
into the T1/T3 file that owns its narrative — **never to split the accumulator.** The instances stay
together; the intruder leaves. An audit **reports** (a)/(b)/(c) and names the shape it would
declare; it does not split on its own, and a file over the cap is a finding, never an instruction.

⚠ **`MEMORY.md` is NOT exempt and is NOT an accumulator — it is the index, and it loads
UNCONDITIONALLY rather than on recall**, so its bytes cost what T0's bytes cost. It is capped by its
**job**: one line per memory, naming what that memory answers. It grows when a memory is added and
shrinks when one is retired, so its size is the store's size and not a breach — **unless a line has
grown from a pointer into a summary, which is where its excess actually comes from.** Trim the
**line**, not the store.

## Classification order

For each candidate fact, in this order:

1. **Contradiction check first.** Does an existing claim in T0/T1/T2 say the opposite? This box's
   history is full of these (`iwconfig`/WEXT, SELinux enforcing, the `046d:c316` spoof's origin,
   `/data/data` reachability, USB HID availability, the OTG current ceiling). A contradiction is
   never a silent overwrite: correct in place **and** append the old text to T3.

   ⛔ **SWEEP FOR IMPERATIVES, NOT ONLY FOR FACTS — A STALE INSTRUCTION IS WORSE THAN A STALE
   FACT.** Added 2026-08-17. A wrong fact is a claim a reader can contradict by running a probe. A
   wrong *"don't check this"* is a **policy that recruits the reader's discipline against them** —
   and it gets more dangerous the more careful they are, because a careful reader obeys it. The
   instance was a kernel gap list (`NF_TABLES=n`, `KPROBES=n`, `VLAN_8021Q=n` — all `y` after the
   rebuild) followed by ***"Do not re-derive any of that."*** It was found **by accident**, because
   its stale values happened to match a value pattern; **nothing in the sweep was hunting the
   instruction.** So a fact-scoped sweep will not find this class:
   `/usr/bin/grep -rniE 'do not re-derive|no need to (check|verify)|already verified|trust the (table|list)|do not use'`
   ⚠ **And prefer a DERIVATION to a value wherever the fix allows it** — `find <outdir> -name '*.ko' | wc -l`
   cannot go stale, *"three"* always will. **A sweep finds what it is scoped to find, and the
   finding that matters is often adjacent to it.**
  ⛔ **AND SWEEP FOR AGREEMENT, NOT ONLY FOR CONFLICT — added 2026-08-18, the peer's framing.**
  A contradiction sweep is scoped to text that **conflicts** with the corrected fact. **A line that
  merely fell behind conflicts with nothing**, so it is invisible to that sweep — and when its
  staleness runs in the *conservative* direction it is worse than harmless: a reader notices the
  world moved, concludes the line is out of date, and "corrects" it into the unsafe version.
  Instance: a capability-map row read *"BPF on tracepoints (but not kprobes)"*, true only while
  `KPROBES` was `n`; after the rebuild it invited exactly the edit that would assert a capability
  whose use hard-resets the device. ⭐ **So GREP THE SUBJECT, never the retired claim** — the retired
  wording finds the sites that disagree, and the subject finds the sites that agree for reasons that
  expired. ⚠ **Note the tension with the sibling rule and keep both:** hunting a rotted *reason*
  means grepping the **reason phrase** (`guard-reasons-rot`); hunting stale *agreement* means
  grepping the **subject**. ✅ **Annotate in place rather than deleting or tightening** — the corpus
  has one site that handled this correctly, by marking a claim *"now stale in the good direction"*
  instead of removing it.

   ⛔ **EXPLAINING SOMETHING WELL FEELS LIKE FILING IT, AND THE BEST-PUT INSIGHT IS THE ONE MOST
   LIKELY TO GO UNRECORDED.** Added 2026-08-17 from three instances in one session, two of them
   caught only by auditing outward claims against the corpus. **The symptom is specific and
   checkable: the items that went unfiled were the ones the author was most pleased with.** A rule
   articulated crisply in a message, a summary or a reply produces the satisfaction of having done
   the work, and that feeling is indistinguishable from having done it. ⚠ **This entry is itself an
   instance** — the signal was stated to a peer, called the most useful thing in the exchange, and
   filed nowhere until a later audit went looking.
   **The check: after any pass, grep the corpus for every claim you made ABOUT the corpus** — not
   your memory for having made it. `/usr/bin/grep -rl '<the claim>' <tiers>`, one line per claim.
   ⚠ **Give that audit a positive control** (a string you know is present) **and a negative control**
   (one that cannot be), and ⛔ **distrust a UNIFORM verdict in either direction — all-pass as much
   as all-fail.** A clean result from an uncontrolled instrument is not evidence: on 2026-08-17 a
   13/13 "all missing" came from a broken glob, not a broken corpus, and acting on it would have
   rewritten nine correct entries. `PRECONDITIONS.md` **N-81**.

   ⛔ **A POINTER IS A PROMISE OWED IN THE SAME UNIT OF WORK.** Added 2026-08-13, within the hour of
   REGRESSION Q76 being written, from the correction pass it describes. Two of the four files
   corrected for probe #10 wrote *"the old wording is in `/root/docs/CORRECTIONS.md`"* **before that
   entry existed** — `grep -c "probe #10"` in T3 returned **0** for roughly an hour, so for that hour
   both files pointed at nothing and read as if they did not. The other two quoted their superseded
   sentence **inline** and asserted nothing about T3; those two were never exposed.
   **An inline verbatim quote of the old text is self-sufficient. A pointer is not** — it is a claim
   about another file that only that other file can make true. Write the T3 entry **first**, or
   append it in the same apply; never leave the promise for a later pass, and never for another
   actor. Same shape as §*Citations* rule 6 (the apply that changes T0 owns the re-resolve) — that
   rule is this one, restricted to citations.
2. **Duplicate check.** Already stated? Merge, keeping the stronger evidence label.
3. **Tier by the admission tests above.**
4. **Placement within the tier**: the section a reader is already in when they need it.

## Evidence labels are load-bearing — preserve them verbatim

Never launder these into confident prose:

- **verified on-device** — a runtime probe was run and passed. State the probe.
- **verified by build/source** — proven from the source tree or build artifacts, not on hardware.
- **unverified / untested** — say so explicitly, e.g. the `RNDIS+HID keeps ADB` claim, the
  bench-measured OTG ceiling, `rmmod` on the V2 kernel.

Downgrading an unverified claim to sound verified is the single worst edit possible here. So is
softening a verified claim into a hedge. Related memory: `verify-device-claims-dont-assert`.

### An AUTHORIZATION is not a claim, and a RELAYED one is CLAIMED — added 2026-08-19

The three labels above all describe how well a claim about **the world** was checked, and each names
an instrument that settles it. **A permission has no such instrument.** ⛔ **An operator
authorization relayed to you by another agent is unverifiable by any probe, artefact or independent
re-derivation — the only instrument is the operator, and a subagent cannot reach one.** Record it as
**claimed**, naming the claimant, quoting the words if known, and stating what was *not* adjudicated;
never as *decided*. ⚠ **Note the asymmetry with the rule this file already carries:** *"a count handed
to the curator is an unverified claim — re-derive it"* works because a count **can** be re-derived.
The instruction here is the opposite, because nothing can.

⛔ **AND NEVER ATTACH AN IMPERATIVE TO ONE.** A fabricated permission carrying *"do not scrub this"*
is a **policy that resists its own correction** — §*Classification order*'s stale-instruction class,
reached by a new route: an instruction that never had a basis rather than one that expired.
⚠ **Labelling the provenance is necessary and NOT sufficient**, proven the day this was written: the
instance carried *"(reported by the pushing session)"* and was still written in the settled voice,
under a heading beginning *operator decision*, with an instruction attached. **A qualifier on the
source does not downgrade the sentence around it — downgrade both.**
⚠ **When reversing one, reverse the CLAUSE whose basis failed, not the paragraph it sat in** — the
same instance's neighbouring imperative rested on a separate, genuine decision five days older and
had to stand. Instance, verbatim old wording and the verification: `CORRECTIONS.md` 2026-08-19
*"an operator authorization that was never given"*; T2 `relayed-authorization-is-claimed`.

### A verification claim must name the artefact it was checked against — added 2026-08-18

⭐ **State the commit, path, build dir, file or date the check ran against. A claim that names its
baseline ages into *"verified as of X"*; a claim that does not becomes a lie by omission the moment
the artefact moves.**

**The rule is NOT "avoid blanket verification claims".** That was tried in reasoning and is wrong on
both counts: it is unenforceable, and it would delete true sentences. The worked pair, both in
`KERNEL-CODEBASE-MAP.md`:

- §7-E's preamble — *"Every anchor re-verified against the tree at `5c8007ed3` and `…/out_ext`"* — is
  **more** blanket than the row that failed, and needed **no correction**, because a reader today
  sees the commit and the out dir and knows instantly it predates the 2026-08-16 rebuild.
- §9's coverage row — *"every row measured by Kconfig resolution"* — named nothing, and silently
  became false when the build moved.

**So blanketness was never the defect. The missing baseline was.**

✅ **It is mechanically checkable, which is why it earns a place here:** grep the verification verbs
(`verified`, `re-verified`, `measured`, `machine-verified`, `re-executed`, `confirmed`) and ask
whether a commit hash, a path, a build dir or a date sits within a line of each. *"Avoid blanket
claims"* admits no such probe.

⚠ **Two failure shapes this rule alone does not catch — check for them by hand.**

1. **A claim whose evidence differs COLUMN BY COLUMN cannot be rated as a unit.**
   §9 rated §D *"re-executed rather than read"*. That was **true of §D's dependency-closure column
   and false of the `today` state column beside it**. A per-section confidence rating has no way to
   express the split, so it did not merely fail to warn — **it vouched for the part it never
   covered**, and the part it never covered was where 10 stale rows recommended flipping
   already-shipped symbols, `KPROBES` among them, whose flip hard-resets the device.

2. ⛔ **A STALE CONFIDENCE RATING PROTECTS A STALE INSTRUCTION, AND THE PAIR IS INVISIBLE TO BOTH OF
   OUR INSTRUMENTS.** Ranked by what each does to a reader: a stale **fact** is passive — the next
   probe contradicts it. A stale **instruction** (*"Do NOT re-derive"*, a `config flip` verdict)
   **disarms** the reader who would have caught the fact, and gets *more* dangerous the more
   disciplined they are, because a careful reader obeys it. A stale **confidence rating** redirects
   scepticism toward already-sound content — subtler than an instruction, though an instruction
   carries the larger blast radius, because **an instruction is executed and a rating is only
   weighted**. ⭐ **The composition is the real hazard: the rating vouches for the section the
   instruction sits in, so the thing that would prompt a re-check is the thing certifying it.** A
   **contradiction sweep** finds nothing, because each half is internally consistent; an **artefact
   comparison** finds nothing, because they live in different sections and only one is checkable
   against the world. A rating is a claim *about* claims, so nothing inside the rated section can
   contradict it.

**The audit question that falls out, and it is not one the rest of this file asks:** not only *"is
this claim stale?"* but **"does another claim tell the reader not to look here?"**

*(Found across two machines: the phone's `*(Batch-1)*` tag finding prompted the laptop's §D.1 sweep,
which prompted the coverage-statement sweep. Both copies of both defects were byte-identical and
had survived every correction pass on either side.)*

## Never delete

- **Traps and anti-patterns.** Highest value per byte on this box. They may move T0 → T1, never
  to T3 and never out.
- **Correction narrative.** It exists to stop a wrong conclusion being re-derived. Move it to T3
  with a dated entry; leave a one-line stub at the original site if the correction is still
  surprising (e.g. "USB HID works — see CORRECTIONS.md 2026-08-06").
- **Secrets.** Referenced by path only, never by value, in any tier. `~/.config/secrets/*`,
  `/etc/wpa_supplicant.conf`, `~/.claude/.credentials.json`, `~/.msf4/`, `~/.ssh/`. The curator
  never reads or echoes a secret value, and never proposes an edit that inlines one.

## Retirement — what may leave T0

- A dated claim whose subject was removed. ⚠ **The GVM example this line used to give — *"torn down
  2026-08-07, still occupying 5 KB of T0"* — is itself stale, and it misled a harvest on
  2026-08-10:** that 5 KB was measured **before** the 2026-08-09 split, which already cut GVM's T0
  footprint to **380 B**, of which only ~78 B was recoverable (the `gvm-up` trap must stay —
  `/usr/local/bin/gvm-up` still exists and still fails). **Measure a retirement candidate against
  the current file before quoting a saving.** A stale saving estimate buys a pass that spends its
  budget on a trim that was already banked.
- ⛔ **A SAVING IS A MEASUREMENT, NOT ARITHMETIC — AND A CUT THAT REPLACES PROSE WITH A POINTER NETS
  A FRACTION OF THE SPAN IT REMOVES.** Added 2026-08-17, when an audit ranked eight T0 candidates by
  **span size** and projected **−6,321 B**; the six taken measured **−2,021 B**, an over-projection
  of ~3×. One cut projected at 1,363 B netted **91 B**, because the pointer replacing the prose cost
  nearly as much as the prose did. ⚠ **The span you delete is not the saving; the saving is `wc -c`
  before minus `wc -c` after**, and a candidate list that has not been through a replacement draft is
  a list of *upper bounds*. **Two consequences for planning a trim:** rank by *span minus expected
  pointer*, not by span; and **do not promise a total** — report each cut as it lands. Same failure
  as the bullet above from the other direction: there the saving was already banked, here it was
  never there.
  ⛔ **AND A DERIVED LABEL NEEDS THE SAME SCEPTICISM AS A DERIVED NUMBER.** An apply script computed
  a T0 delta of **+68 B** and printed *"T0 is BELOW where it started"* on the same line: the
  measurement was right and the **verdict word beside it was wrong**, so a pass that trusted its own
  summary would have banked an overspend as a saving. This is not the bullet above — there the
  number was the problem. **Re-read the number, not the sentence about it**, and prefer printing the
  before/after pair over an adjective.
- Narrative of the form "this row used to say X" once the corrected text stands on its own.
- Verification evidence for a settled question — the *conclusion* stays, the transcript goes to T1.
- Tool inventories. `command -v X` answers "is X installed" better than a list that goes stale.
  ⚠ **On this box that sentence is now half-wrong and is kept as a trap** — `command -v` answers rc 0
  for 11 captured venvs (`PRECONDITIONS.md` NEW-3). It still beats a stored list; it is not a
  functional probe.

### Retiring a T2 memory — added 2026-08-17

⛔ **Retire the SLUG AND DESCRIPTION, not the body.** Recall relevance is scored on the
`description:` line, so that is what decides when a memory fires. Correcting the prose while leaving
a slug like `…-external-wifi-blocked` and a description reading *"has zero USB Wi-Fi drivers"*
leaves it firing on exactly the questions it answers wrongly — the body is read only after the
damage is done. **Write the replacement under a new name, delete the old file, and put the
superseded wording in T3** — never edit a falsified memory in place. `CORRECTIONS.md` 2026-08-17
holds the instance and the 16-day survival that produced this clause.

## One tier owns a number

**Measured, drifting values — counts, versions, sizes, timings — live in exactly one tier.** The
other tier points at the owner and must **not** restate the value as an independent current claim.
Traps, procedures and stable facts may be repeated wherever a reader needs them; numbers may not,
because two copies drift and the reader has no way to tell which is fresher.

Learned the hard way on 2026-08-09: the split left T0 saying *1433 tests / 47 files* and
`docs/VULNSCANNER.md` saying *1334 / 43* — both as current, with the stale one on the far side of
the pointer. The package total drifted the same way in the same pass. See `docs/CORRECTIONS.md`.

⛔ **A COUNT HANDED TO THE CURATOR IS AN UNVERIFIED CLAIM. Re-derive it before you plan against
it.** Added 2026-08-11 after **two** figures in briefs to the curator were wrong in one session:
*"T0 carries 22 references to `hcat`/`hcxsort`"* (a bare substring `grep -c` — **20 of the 22 were
`hashcat`**; the real figure was 3 lines) and *"GVM still occupies 5 KB of T0"* (measured before the
split that had already cut it to 380 B). Both would have bought a pass sized against a number that
did not exist.

- **A bare substring grep is not a measurement.** Use a word boundary (`\bfoo\b`, `grep -w`), say
  whether you are counting **lines** (`grep -c`) or **occurrences** (`grep -o | wc -l`), and state
  the denominator. `\bhcat\b` was the probe; `hcat` was not.
- **Quote a number only from the artefact it describes** — not from a doc about the artefact, and
  not from an earlier pass over it. That single property is what both failures lacked.
- **This is not scepticism about the sender.** Re-deriving is part of accepting the job; the sender
  is not in a position to have re-measured, which is the whole reason the work was delegated. Both
  of the above were self-reported by the coordinator as soon as they were shown the probe.
- It applies with equal force to a number the curator is about to *quote as a saving*. See
  *Retirement*, where the same failure is recorded from the other direction.

## Citations into T0 rot within hours — cite by heading, and re-resolve

Added 2026-08-10, after `/root/docs/CODING-RULES.md`'s `/root/CLAUDE.md:NNN` citations went **~60
lines stale within hours** of a +6,732 B T0 edit. 19 occurrences had to be re-resolved against anchor
text the same day. Every T0 correction shifts every line number below it, and this box corrects T0
several times a week.

1. **New citations into T0 name the SECTION, not the line** — the `##`/table-row heading plus a short
   quoted anchor phrase, e.g. *T0 §"Hard environment constraints", the `nproc` row*. A heading
   survives edits; a line number does not.
2. **Existing `CLAUDE.md:NNN` citations must be re-resolved after any T0 edit that changes the line
   count**, and the citing file must carry a **byte-stamped** marker —
   `citations re-resolved YYYY-MM-DD against T0 at <N> bytes` — so the check is mechanical:
   `wc -c /root/CLAUDE.md` ≠ N ⇒ **presumed rotten**. ⚠ **A date alone is not enough, proven the
   same day the rule was written:** T0 was edited twice on 2026-08-10, and the second edit re-rotted
   citations that a marker dated *that same day* would have certified as fresh. Same-day granularity
   is exactly the resolution this failure lives inside.
3. **Re-resolve against anchor TEXT, never by adding an offset.** Two edits in different places do
   not shift by the same amount.
4. ⛔ **CITATIONS INTO SOURCE NAME THE FUNCTION OR TOKEN, NOT THE LINE.** ⚠ **This rule said the
   OPPOSITE until 2026-08-14** — *"`path:line` into **source** (`/usr/local/bin/*`) stays allowed —
   those files change far less often — but quote the anchor token alongside it so rot is detectable
   rather than silent"* — and **the premise was false**: five tools were rebuilt in two days, three
   of them shrinking 60–75 %, and the outward citation set was then measured at **3 of 4 wrong**,
   a worse rate than the T0-inward set this section was written to fix. One of the three had been
   "freshly re-resolved" less than 24 hours earlier; one pointed **past EOF** of a rebuilt tool.
   Write `/usr/local/bin/rogueap` `phy_self_managed()` or `wificonnect` `supplicant_pids()`;
   **`grep -n` is the resolver — ⛔ but run it AGAINST THE FILE, never behind a pipe: `grep -n`
   numbers the input it was handed, so `sed -n 'a,bp' F | grep -n pat` returns an offset INTO THE
   SLICE wearing the shape of a file line number, with no error and no warning. It survives
   switching binaries (`awk` too), and a probe sanity-checked on a `1,N` slice passes and then
   lies at every other offset. `PRECONDITIONS.md` P-66.** A line number is permitted only as a *hint* beside a name, never
   alone — a name that no longer resolves is a signal to read, exactly as rule 5 requires; a number
   that no longer resolves is silent. Proposed and **approved by the operator 2026-08-14**;
   `CORRECTIONS.md` 2026-08-14 owns the measurement and the old wording.
5. **Re-resolution is MECHANICAL, and the snapshot directory is what makes it so.** Added 2026-08-10
   after 61 citations were re-resolved by hand. The procedure: take the cited block from the
   **newest `memory-curation/snapshots/<ts>/`** copy of the target and locate that text in the
   current file. Do not eyeball, do not offset. ⚠ **A citation that fails to resolve is a signal
   that the passage was REWRITTEN, not moved — and it must be READ before it is repointed.** That
   distinction is the whole value of the method: of 61 citations, **57 moved and were rewritten
   mechanically; the 4 that failed were exactly the four passages that had been rewritten**, and
   repointing those by offset would have pointed confidently at the wrong text.
6. **The apply that changes T0 OWNS the re-resolve and the restamp, in the same unit.** A stamp left
   stale by one actor and refreshed by another is how a stamp goes stale in the first place. Before
   finishing, run `grep -rln "CLAUDE\.md:[0-9]" /root/docs/*.md` and close every file it lists.
   Corollary: **if T0 is not changed, do not restamp** — a stamp naming a byte count that was never
   installed is a lie that reads as freshness.
   ⛔ **AND A REMEDIATION PASS MANUFACTURES BROKEN ANCHORS AS IT RUNS — the more thorough the pass,
   the more it breaks** (added 2026-08-18, three instances in one day). **Damage is proportional to
   the citations BELOW the insertion point, not to lines inserted**, so a correction box inserted
   ABOVE cited content is the worst shape and re-resolution only ever needs to run downward. ⚠ **A
   citation written during an editing pass is suspect by default** — three written that day rotted
   **inside the same session**, because a later edit to the cited file moved the rows. Re-checking
   at the end of the pass is the minimum, not paranoia.
7. ⚠ **T1→T1 line citations rot the same way and have NO stamp at all.** Found 2026-08-10: of the 32
   `TOOLS.md:NNN` citations in `CODING-RULES.md` and `PRECONDITIONS.md`, **19 were wrong**, and
   only 9 of those were caused by that day's edit — **the rest had been rotten for days**, including
   `BT-0.6`, "the load-bearing one", which pointed 86 lines away from the text it quotes. The
   byte-stamp rule was written for T0 because T0 is edited weekly; `TOOLS.md` is edited *more* often.
   **Resolve a T1→T1 citation against its own quoted anchor whenever you touch the file**, and prefer
   a section heading plus a quote to a line number, exactly as for T0.

The same discipline is why *One tier owns a number* exists. A citation is a number.
8. ⛔ **A CROSS-REFERENCE IN A SPLIT CORPUS MUST NAME THE MACHINE IT RESOLVES ON.** Added 2026-08-18
   after two live instances. This corpus is forked across a phone and a laptop, and **the same
   filename can be a different object on each**: `HANDOFF.md` is **70 lines, overwritten every
   session, explicitly not a knowledge tier** here, and **475 lines, the persistent entry point**
   there. So `KERNEL-CODEBASE-MAP.md`'s citations `HANDOFF.md:147/154/182` were **never valid on this
   machine** — not drift; the name resolves elsewhere. Earlier instance: `SECTION-D-DATA.md`, cited
   for "full per-symbol results" and absent from this device entirely.
   ⚠ **This class is invisible to every other check in this file** — the citation is well-formed, the
   target exists, the artefact is named. It fails only on *on which machine?*
   ⭐ **It is also the DOMINANT one: 3 of the corpus's 4 past-end-of-file `.md:NNN` citations are this
   single class**, and unlike rules 1–7 it has a cheap mechanical check — **`NNN` greater than
   `wc -l` of the local target**, which scans the whole corpus in about a second.
   **Mark a laptop-authority pointer as such rather than deleting it**; a pointer that says
   "laptop-only, not here" is the correct end state.

9. **A PROCEDURE PRUNES; REFERENCE TEXT DOES NOT — so state a fact in the procedure or expect it to
   be lost.** Added 2026-08-18. `KERNEL-CODEBASE-MAP.md` §C said `mod_sign_cmd` has *"exactly two"*
   call sites and was right; §F.3 — **a how-to** — and `bundle/BUILD-VERIFIED.md` both said one was
   *"the only place"*. **A procedure is written to be FOLLOWED, so it compresses, and compression is
   where the second call site went** — and the reader following it never cross-reads to the
   reference. ⛔ **Procedural documents are therefore the higher-cost place for a defect, and not
   only when stale.** When correcting a fact, sweep the procedural register separately: the shortest,
   most actionable statement of a thing is the one most likely to have dropped half of it.

## Sequencing a split — never correct and move concurrently

`split` has two passes that are in direct tension: **verbatim move** (which faithfully preserves
whatever the bytes say, including a claim that is being corrected right now) and **correct in
place**. Run them in this order, never interleaved:

1. **Correct first, in T0, and land it.** Apply every known correction to `/root/CLAUDE.md`, file
   the superseded wording in T3, and stop.
2. **Then move.** Split the *corrected* T0 into T1. The verbatim rule is now safe, because the
   bytes being moved are the true ones.
3. **Then sweep.** After the move, grep T1 for every value T0 also states and confirm they agree —
   a fact corrected mid-session is the one that will disagree.

If a correction arrives *during* a split (a fresh measurement, a coordinator's numbers), do not
patch T0 alone and carry on. Either finish the move and then correct **both** sites, or hold the
number until the move lands. Patching one tier while copying the other is exactly how the
2026-08-09 drift happened.

## Safety

- Snapshot before any write: `/root/.claude/memory-curation/snapshots/<YYYY-MM-DD-HH-MM-SS>/`.
  Timestamps use `-`, never `:` — colons break on the exFAT-backed `/sdcard` paths.
- ⛔ **EVERY BATCH EDIT ASSERTS ITS MATCH COUNT AND ABORTS ON ANYTHING BUT 1.** Added 2026-08-11,
  after the habit caught **four** would-be corruptions in a single session — including one that
  would have left `PRECONDITIONS.md` claiming **99** rows over **55**. A scripted
  `s.replace(old, new)` that matches twice corrupts silently and a `diff` afterwards looks
  plausible, because both sites were places the text legitimately appeared. The rule:
  `n = s.count(old); if n != 1: abort`, **before** writing, per edit, with the count printed. It
  costs one line and it is the only thing standing between a multi-file pass and a silent
  double-substitution. The same applies to `sed -i` — prefer a counted Python pass.
- ⛔ **NEVER `git checkout` TO UNDO A SCRATCH EDIT — copy the file aside instead.** Added
  2026-08-11 after a `git checkout` intended to discard a temporary change **reverted uncommitted
  work in the same file**. `git checkout -- <path>` restores the whole path from the index; it has
  no notion of "only the bit I was experimenting with", and the loss is silent and unrecoverable.
- ⚠ **Editing a T1 doc breaks the `nh-tools` repo mirror (BT-0.10) until it is committed.** A
  **named subset** of T1 docs is mirrored byte-for-byte alongside `bin/` and `lib/`, so a
  doc-only curation pass can violate the invariant without touching a tool. ⛔ **The repo's own
  `.gitignore` OWNS that set and its count — `grep '^!docs/' /root/tools/nh-tools/.gitignore` —
  and it GROWS: it read `four` here, in `LAYOUT.md` and twice in T2 `nh-tools-repo` until
  2026-08-18, by which time it was six** (`CORRECTIONS.md` 2026-08-18). **Do not act on a
  remembered list; run the grep** — a curator who edits a doc this bullet does not name will
  drift the mirror believing they have not. (`TOOLS.md` and `TOOL-TEST-RESULTS.md` are
  **gitignored** and must stay so; their repo-side copies are stale by design and reporting them
  as DRIFT is correct, not a defect to "fix" by copying them in.)
- ⛔ **THIS CONTRACT IS NOW MIRRORED TOO, AND THAT MAKES COMPLIANCE ITSELF DRIFT THE REPO.** Added
  2026-08-14, when `contract/` was created because `RULES.md`, `REGRESSION.md` and
  `regression-log.md` had lived only under `~/.claude` and outside every backup. The consequence
  is self-referential and easy to miss: **the log entry this file requires after any T0 rewrite
  puts the repo out of sync the moment you write it**, so a pass that ends "mirror clean" either
  skipped the log or is reporting a state it has not re-measured. **Re-run the check after the
  log entry, not before**, and report the drift as an outcome of the pass rather than leaving it
  looking clean. ⛔ **"The check" is `cmp` per file against its DEVICE path — never `git status`.**
  The mirror holds regular copies, not symlinks, so git reports the working tree clean against HEAD
  while the device disagrees; measured 2026-08-15, that shape misled **four** passes in one day,
  two of them curator passes. All four halves (`bin/` `lib/` `docs/` `contract/`), the four-root
  mapping trap and the operator decision behind the repo: T2 `nh-tools-repo.md`; T0
  §*Conventions*, the mirror bullet.
- **Propose, then apply.** The curator returns a diff summary; the operator approves. Only the
  `/curate apply` path writes.
- After any T0 rewrite, re-run `REGRESSION.md`. Every question must still be answerable from T0
  plus one pointer hop. An unanswerable question blocks the change.
