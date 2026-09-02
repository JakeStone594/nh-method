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
| **T0** | `/root/CLAUDE.md` | every session, in full | **~65k tokens** — operator raise **2026-08-26**, the FOURTH, and ⭐ **the first set from a MEASUREMENT rather than a division** (harness token accounting; T0 measured ≈64k). ⛔ **The byte figure is DERIVED, never authoritative — and `÷ 4` UNDERSTATES THIS CORPUS BY ~1.7×, because `**`, backticks, ⛔/⚠/✅, ALL-CAPS runs and full paths all tokenise badly.** Convert when you need one (`wc -c` ÷ ~4 B/token) and say that you converted; ⚠ **the divisor is itself an approximation, so where the margin decides the answer the honest instrument is a tokenizer, not a division** | constraints that change *what you do*, conventions, action-changing traps, and the pointer index to T1 |
| **T1** | `/root/docs/*.md` + the existing `/root/*-MAP.md` | on demand, by pointer | no cap; one topic per file | procedures, verification evidence, tool inventories, per-domain deep dives |
| **T2** | `~/.claude/projects/-root/memory/` | on recall, one file per fact | ≤ 4,096 B per file — **except a declared accumulator**, §*T2 size* | durable facts about the user, their feedback, project state, external references |
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

⛔ **AND THE CEILING GOVERNS `/root/CLAUDE.md` ALONE, WHICH IS NOT WHAT A SESSION ACTUALLY PAYS —
STATED HERE BECAUSE THIS IS WHERE A COMPACTION PASS READS THE BUDGET.** Added 2026-08-19. **Three
artefacts load UNCONDITIONALLY at session start, not one:** T0, the T2 index `MEMORY.md`, and every
skill `description:` line (§T1.5). Measured 2026-08-19: **136,788 + 6,434 + 8,083 = 151,305 B**, i.e.
**~11 % more than T0 alone** — re-derive rather than quoting these
(`wc -c /root/CLAUDE.md ~/.claude/projects/-root/memory/MEMORY.md`;
`grep -h '^description:' ~/.claude/skills/*/SKILL.md | wc -c`). ⚠ **The direction that matters: a
pass can report *"T0 unchanged"* truthfully while the unconditional load grew.** That happened the
day this was written — T0 was `cmp`-identical across five passes at 136,788 B while `MEMORY.md` went
**5,183 → 6,434 B (+24 %)** in the same day. ⛔ **No number here is a second ceiling and none is
proposed** — a ceiling raise has twice been an operator decision on the record, and inventing one
from a measurement is the trap §*Retirement* and the `KB` note above both record. **What this clause
changes is only the instrument: measure all three, and say which you measured.**

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

 ⛔ **AND TOOL SOURCE — added 2026-08-24.** The sweep is **three** roots, not two: add
   `/usr/bin/grep -rn '<claim>' /usr/local/bin /usr/local/lib/nh`. A retired claim survived in
   **four** sites after a correction pass whose proposal named **one**, and the fourth was a
   **source comment** (`/usr/local/bin/rogueap`) carrying **both** retired claims at once. ⭐ **A
   PROPOSED ANCHOR BOUNDS THE EDIT, NOT THE DEFECT** — a curator hands over the anchor it verified,
   the applier's `n == 1` guard passes on it, and the pass reads as landed. §*Safety*'s *the guard
   protects the anchor, not the row* is this failure inside one file; this is the same failure
   crossing an agent boundary, where nobody holds both halves. **Hand over the SITE LIST from a
   sweep of the retired PHRASING, not a single anchor** — and a proposal that names one site is
   asserting an absence it did not check.

   ⛔ **AND A SWEEP OF THE RETIRED PHRASING ONLY REACHES A SITE THAT USED THAT PHRASING — A
   RESTATEMENT OF THE SAME QUANTITY IN DIFFERENT UNITS IS INVISIBLE TO IT. Added 2026-08-26.** A
   2026-08-21 correction settled a quantity at **2 bits / 4 states**, annotated the section it was
   about, and left it restated as *"~3 bits per frame"* in a comparison table further down the
   **same** file and as a **5-bit** premise in an `Open` register row in **another** file. Neither
   shares an anchor with the corrected sentence, so a sweep of the retired wording returns a
   confident empty — and one of the two survived a sibling sweep run **specifically to find it**.
   ⭐ **Correcting a measured QUANTITY means sweeping for the QUANTITY — every numeral that could
   express it — not for the sentence.** ⚠ **A comparison TABLE and an OPEN-QUESTION row are the two
   shapes most likely to hold one**: a table compresses the claim into a cell the corrected wording
   never fitted, and an open row states the quantity as a *premise*, where it reads as a question
   rather than a claim and so invites someone to go test a ceiling already measured.

 ⚠ **A SECOND INSTANCE, FOUND BY THIS VERY ROOT ON THE DAY IT WAS PROPOSED — which is what makes
   it a register rather than an anecdote.** A false buffering REASON (*"stdout block-buffers when
   piped"*) was live in **three** sites; the two the existing two-grep set cannot reach were
   **`apclients` and `authcatch`, both in their `warn()` helper**, identical comments, the
   second copied from the first. ⭐ **Copy-paste is why source needs its own root: a wrong reason
   in a helper propagates with the helper**, and no doc sweep follows it. T2 [[guard-reasons-rot]].
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

### T0 admission test — all three must hold for a NEW admission

1. **Action-changing.** Not knowing it makes you do the *wrong thing*, not merely a slower thing.
   `pkill -f` self-matching, `--no-canonicalize`, `getenforce` returning `Disabled` in the chroot,
   `df /` describing all of Android userdata — these belong in T0 forever.
2. **Cross-cutting.** It bites in more than one domain, or in a domain you would not have
   thought to open a reference doc for.
3. ⛔ **REFUSAL-CHANGING. Operator ruling 2026-08-19 — this clause replaced *Irreducible*, and it
   GATES NEW ADMISSIONS ONLY.** Not knowing it makes a session **refuse wrongly, or fail to refuse
   when it should**. It is deliberately narrower than clause 1: every refusal-changing fact is
   action-changing, so clause 1 is implied for anything new, while most action-changing facts are
   **not** refusal-changing. ⛔ **A wrong-action trap discovered from now on goes to T1 with a
   pointer naming what the file answers — however good it is, and however much you want it in T0.**
   **Why this and not the weaker gate that was tabled** (*"is there a pointer whose text would make a
   reader open that file at the moment this bites?"*): T0 sits close to its ceiling (~98 % when this was written; **~100 % against the 2026-08-26 measured ceiling**), and a weaker
   admission test at the ceiling is the wrong direction. This clause is aimed at T0's growth
   **RATE**, which is the one property an admission gate can change.

   ⛔ **IT RUNS IN BOTH DIRECTIONS, AND A READER TAKING ONLY THE FIRST HALF WOULD GUT T0 WHILE
   FOLLOWING THE TEXT.** *Refusal-changing* means it changes **whether you refuse** — either by
   **stopping a refusal that would have been wrong**, or by **compelling one that would otherwise not
   have happened**. The second half is most of T0's ⛔ markers: *do NOT reboot on a failed
   `usbgadget restore`*, *never `iptables -F` these tables wholesale*, *never `mount -t bpf`*, *do not
   charge the phone during USB gadget work*, *KPROBES is a stop-the-world text patch on this build*.
   ⚠ **Read narrowly as "prevents wrong refusals", this clause would evict every one of them** — the
   stale-instruction shape from §*Classification order*, manufactured fresh in the file that warns
   about it.

   ⭐ **THE TEST, so this is a gate and not an adjective.** Write one of these two sentences about the
   candidate. **If you cannot write either, it is T1:**
   (a) *"Without this, a session would tell the operator that **X cannot be done here** — and X can."*
   (b) *"Without this, a session would **go ahead with X** — and X is destructive, irreversible, or
   out of scope."*
   ⚠ **The sentence must name a concrete X.** *"It would make someone cautious"* is not (b), and
   *"it would confuse someone"* is not (a). Same enforcement logic as §*T2 size*'s declared shape: an
   unwritable test is one every curator applies differently.

   **The class this protects is on this box's record, not invented for the occasion** — all three are
   in T0 today, verbatim: the 2026-08-06 USB-HID row that *"said HID was UNAVAILABLE … and that cost
   a wrong refusal"*; the standing both-radios requirement, *"do not refuse an attack on the grounds
   that the internal chip cannot do it — check the mechanics first"*; and `modinfo` being inert here,
   which *"put a false 'the kernel lacks bnep' claim into three skill files for days"*. **Wrong
   refusals are the failure this corpus records as costing whole sessions.**

   **Irreducible — KEPT, demoted from a test to the method.** Once clause 3 has decided *whether*,
   it decides *how*: a fact that cannot be compressed to a pointer without losing the warning stays
   whole; **a procedure *can* be a pointer, a trap usually cannot.** It stopped being an admission
   test because it never excluded anything — every author believes their fact is irreducible.

⛔ **CLAUSE 3 IS NOT RETROACTIVE, AND THIS PARAGRAPH IS THE LOAD-BEARING HALF OF THE RULING.** It
gates what **enters** T0. It is **not** a licence for an eviction pass over what is already there,
and no such pass has been authorised — that is a separate and much larger decision. **Clause 1's four
named permanents are grandfathered by clause 1's own words** (*"these belong in T0 forever"*), and
they are the proof that the two tiers are real rather than a convenience: **`pkill -f` self-matching
and `df /` describing all of Android userdata both FAIL clause 3 outright** — they are wrong-*action*
facts, not refusal facts — **and `getenforce` returning `Disabled` is borderline.** ⚠ **A curator who
applies clause 3 backwards would evict the content clause 1 calls permanent, and would be following
the text.** Whole sections would go with them: §*Output locations*, §*hashcat*, §*Installed tooling*,
the vulnscanner gates, the `nproc`/`core_ctl` row, the root-filesystem row, and much of
§*Conventions*. ⛔ **Do not.** **No total is quoted here** — a span-based estimate is exactly what
§*Retirement* records misprojecting in both directions, and none has been measured.

Everything failing the test goes to T1 with a one-line pointer left in T0 naming the file **and
what it answers**. A pointer with no promise of content is worthless — write
`see docs/BLUETOOTH.md for the six BadBT preconditions`, not `see docs/BLUETOOTH.md`.

### T2 admission test

One fact per file, frontmatter per the memory spec, type `user` / `feedback` / `project` /
`reference`. **Not** what the repo, git history, or T0/T1 already record. If a fact is about the
*device*, it is T0 or T1 — memory is for what cannot be re-derived by reading the box.

### T2 size — the 4,096 B cap, and the one exemption

**≤ 4,096 B per file.** A T2 body is injected **whole** on recall, so a file that has grown into a
mini-T1 taxes every recall that needed one line of it. That is what the cap protects — recall
budget, not disk.

⛔ **`4 KB` HERE MEANS 4,096 B, NOT 4,000 — OPERATOR RULING 2026-08-26, WRITTEN OUT AT EVERY SITE
BECAUSE THE AMBIGUITY HAD ALREADY BITTEN TWICE.** A single-decision memory measured **4,083 B** and
was *simultaneously* compliant on one reading and **83 B over** on the other; the session holding it
reported *"13 B of headroom"* without saying which reading it had assumed, which is the same
unstated-denominator shape §*A verification claim must name the artefact it was checked against*
catches elsewhere. ⛔ **AND IT WAS NEVER ABOUT ONE FILE: swept 2026-08-26, **EIGHT** T2 files sit
in the 4,000–4,096 band and **none** carries a line-anchored accumulator marker — so the unit
reading alone decided whether seven single-decision memories plus one register were compliant or
in breach, all at once.** They cluster just under 4,096, which is authors writing to the cap.
⚠ **The sweep's first pass mis-detected one of them as exempt** by testing for the marker string
anywhere in the file rather than at line start — prose *about* the marker matched — which is the
defect §*T2 size*'s own line-anchored note exists for, committed while applying this ruling. ⚠ **THE 2026-08-19 PRECEDENT IN §*The four tiers* DOES NOT TRANSFER, AND READING
IT ACROSS WOULD DESTROY THIS CAP.** There the remedy was to **delete** the byte figure — correctly,
because it was a convenience conversion of a **token** ceiling at an assumed 4 B/token, and tokens
are what the context window charges. ⛔ **Here the byte figure IS the cap: there is no token
quantity behind it to fall back on, so deletion would leave the rule with no number at all.**
**Disambiguation was the only remedy available.** ⚠ **A `KB` written anywhere in this contract that
is NOT this cap is a historical record of what a cell once said — §*The four tiers*' `~140 KB` is
one — and must not be "fixed" to match this ruling.**

⚠ **EXEMPT: a DECLARED ACCUMULATOR.** Some facts here are not a line but a **pattern**, and a
pattern is only legible from its instances — one instance reads as an anecdote and is dismissed as
one. Splitting such a file does not improve retrieval, it **destroys the fact**: the reader recalls
one instance and never learns it was the fourth. Adjacent to §*Retirement*'s stale-saving rule and
**not** the same failure — there the saving had already been banked; here the saving would destroy
the artefact.

**A file is an accumulator only while ALL of this holds:**

0. ⛔ **IT CARRIES THE LITERAL MARKER `**DECLARED ACCUMULATOR.**`, AT THE START OF A LINE IN ITS
   FIRST PARAGRAPH, EITHER IMMEDIATELY FOLLOWED BY ITS SHAPE SENTENCE OR IMMEDIATELY NAMING WHERE
   THAT SENTENCE IS — MANDATORY SINCE 2026-08-19, AND IT IS THE AUDIT'S PROBE.** This makes
   disqualifier **(a)** mechanically checkable instead of a judgement:

   ```
   grep -lE '^\*\*DECLARED ACCUMULATOR\.\*\*' ~/.claude/projects/*/memory/*.md
   ```

   ⚠ **Why it exists: the exemption had been written TWO ways and an audit that grepped one silently
   missed half.** Measured 2026-08-19 — `accumulator` matched 8 files, `declared shape` matched 5,
   and neither set was the true set of 7. **The two phrasings were never synonyms**: `accumulator` is
   the **category**, `declares its shape` is **condition 1 of three**, so four files satisfied the
   substance while never naming the category and were invisible to a category probe. **Cost: a
   coordinator's baseline table listed a declared accumulator as undeclared, and acting on it would
   have split the memory carrying a live cross-reference.** ⛔ **Both wrong rows were MENTION HITS,
   not declarations** — `MEMORY.md` (which this section says explicitly is *not* an accumulator) and
   a single-fact memory that merely referenced *another* file's declared shape. **That is why the
   marker is line-anchored**: prose about an accumulator does not begin a line with it, so the probe
   cannot be confounded the way the loose greps were. ⚠ **`declared shape` remains CORRECT PROSE for
   condition 1 and nothing was reworded** — what is standardised is the **category marker**, not the
   wording of the declaration. ⚠ **A marker on a file that is not an accumulator is a worse defect
   than a missing one** — it launders an over-cap file into an exemption. Read the file before
   adding it; do not add one to tidy a count.
   ⚠ **The *"immediately followed by"* half was WIDENED to *"or naming where it is"* on 2026-08-19,
   the same day, because the corpus written to satisfy it did not:** **3 of the 7** marked files
   (`nh-method-repo`, `nh-tools-mirror-exclusions`, `nh-tools-repo`) follow the marker with *"Its
   shape is declared in the `description:` frontmatter above"*, with the shape sentence a paragraph
   below. ⛔ **The greppable half worked 7/7; the READABLE half would have failed 3/7 on a clean
   store** — a future audit scoring the clause as first written manufactures three regressions, which
   is the `REGRESSION.md` §*Method* false-regression shape arriving in this file instead. **The
   clause was widened rather than the three files reordered**, because the declarations are correct
   and only the adjacency rule was over-tight. ⭐ **The transferable half: a rule written and applied
   in the same pass is not thereby self-consistent — check the rule against the artefacts you just
   wrote for it, not only against the ones you inherited.**
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
argument.** Any of: **(a)** over 4,096 B with no `**DECLARED ACCUMULATOR.**` marker and no declared shape; **(b)** an entry that is not an
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
   cannot go stale, *"three"* always will.
   ⛔ **AND AN IDENTIFIER IN A PERMISSION OR SCOPE DOCUMENT MUST BE SELF-DESCRIBING — AN ARBITRARY
   LABEL INVERTS SILENTLY AND ITS OWN AUTHOR DOES NOT NOTICE. Added 2026-08-27.** The sibling clause
   above is about a value going STALE; this is about one being read BACKWARDS, which no re-derivation
   catches because nothing is out of date. **Measured instance:** T0 §*Scope*'s two laptops were
   written as `Laptop 1` / `Laptop 2`, and **the operator INVERTED them within ~20 minutes of
   approving that exact wording** — asking whether the main machine was 2 and the vulnerable one 1.
   ⚠ **The author of the grant could not hold it, and a cold session has strictly less context**;
   renamed to *the MAIN laptop* / *the VULNERABLE laptop* the same day. ⭐ **The name must carry the
   property the rule turns on** — here *which machine may have credentials harvested off it*.
   ⚠ **Scope it to identifiers a RULE DISCRIMINATES ON**, not to every name: `hci0`, `wlan1` and
   `P-102` are fine, because no permission or refusal hangs on the numeral. ⛔ **A half-rename is
   worse than either name**, so sweep every tier in the same unit — and note this is the document-side
   twin of `PRECONDITIONS.md` **P-67** (*classify a radio by DRIVER, never by a netdev name*): there
   an instrument matched the wrong object, here a **reader** does. ⭐ **The artefact-level form of the same rule, RELAYED from
   the laptop peer 2026-08-23 and not verifiable from this box: SHIP THE GENERATOR, NOT A POINTER TO
   WHERE IT WAS.** A 7.1 MB index became unreproducible because its generator lived in a deleted
   session scratchpad and the README pointed at a recipe that did not exist. ⚠ **The artefact was
   never the problem; irreproducibility was** — and a pointer to a generator is a claim about another
   place, which is the same defect §*Classification order* records for a T3 pointer written before
   the entry exists. **A sweep finds what it is scoped to find, and the
   finding that matters is often adjacent to it.**
   ⛔ **A RECORD AND A PIECE OF GUIDANCE CAN CARRY THE SAME STALE STRING AND MEAN OPPOSITE THINGS BY
   IT — AND A SWEEP THAT FIXES EVERY OCCURRENCE CANNOT TELL THEM APART. Added 2026-08-23.** One
   document routinely holds both: **current-state instructions**, where a superseded value is a
   defect to correct, and **evidence records** (a provenance row, a dated measurement, a "what this
   was checked against" line), where the superseded value **is the content** and correcting it
   destroys the record. ⛔ **The corpus cannot distinguish them by text, because they are the same
   text.** ⭐ **THE COUNTERINTUITIVE HALF, AND IT IS THE REASON THIS IS A RULE: THE CRUDE SWEEP WAS
   SAFE AND THE CAREFUL HAND EDIT WAS NOT.** Measured on-device 2026-08-23: a 25-site mechanical
   sweep printed every candidate line before touching it, so every record in the set was seen and
   spared; the **single-row edit done carefully by hand**, with no such print, rewrote a
   *"Commits on top"* **provenance row** into a **current-state list** — landing
   *"8, peer-measured 2026-08-23"* three rows under a *"Date of this map | 2026-08-08"* stamp, which
   is now two claims that cannot both be about the same moment. **1 of 4 sites confirmed damaged;
   the other three were records that survived.** ⚠ **So *"be careful"* is not the remedy and volume
   is not the risk — PRINTING THE CANDIDATE LINES IS THE REMEDY**, at any scale, including a scale
   of one. **Before changing a value, read the sentence around it and ask whether it is telling the
   reader what IS or recording what WAS.** ⚠ **Adjacent to *a stated reason for an ABSENCE* below and
   NOT the same**: there the danger is a reader restoring a value that was removed on purpose; here
   it is an editor overwriting a value that was never a claim about today.

   ⛔ **AND WHERE NO VALUE CAN BE CORRECT, SAY SO IN PLACE — A REMOVAL WITHOUT A STATED REASON IS AN
   INVITATION.** Added 2026-08-23. A value can be worse than stale: **self-referential**, where
   recording it invalidates it in the same act. ⚠ **RELAYED from the laptop peer, not reproducible
   from this box:** a handoff recorded the commit hash of the branch the handoff is itself committed
   to, and their first fix — reading the value programmatically rather than typing it — was stale
   again on the very push that carried the fix. ⛔ **That is not staleness; it is not FIXABLE, only
   removable.** ⭐ **The landable half is the SECOND move, not the diagnosis: replace the value with
   the command that reads it, AND state in place that none is recorded there on purpose.** Otherwise
   the next reader sees a conspicuously missing value and helpfully restores it — **an absence
   cannot defend itself; only a stated absence can.** ⚠ **Scope it by SELF-REFERENCE, not by
   "hashes"**: that same file's kernel-repo hashes stay literal, because they name a repository its
   own commits do not move.

   ⭐ **THE CLASSIFICATION THAT MAKES THAT SCOPING CHECKABLE — THREE CATEGORIES, added 2026-09-01.**
   The same SHA, in the same file, can have three different lifetimes, and **only the VERB tells you
   which**:
   **(1) PROVENANCE** — *"the peer ran the tool at `d923e5d` and got the correct verdict"*. **True
   forever; no push touches it.** Keep it literal.
   **(2) STATE** — *"the repo is at X"*. **Stale the moment anything is pushed.** Replace with the
   command that reads it.
   **(3) STATE ABOUT A FROZEN ARTEFACT** — *"my clone's HEAD is `bab9836`"*, where the clone cannot
   fetch. ⛔ **Stale-proof BY CONSTRAINT, NOT BY GRAMMAR — and that is more dangerous than (2), not
   less, because the thing keeping it true is INVISIBLE IN THE SENTENCE.** Lift the freeze and it
   becomes ordinary stale state **with nothing marking the transition**. ⭐ **A guarantee that comes
   from a constraint rather than from the grammar expires when the constraint does, and the text
   cannot tell you that happened.**
   ✅ **THE OPERABLE HALF, AND IT IS AN AUDIT METHOD: you cannot grep for stale state, but you CAN
   grep for SHAs and then ask what each one is DOING.** Same string, same file, opposite lifetimes.
   ⛔ **AND CATEGORY 3 CANNOT BE SWEPT FOR — recorded because the first instinct is to try.** A sweep
   for `frozen` returns kernel docs where the word means a frozen *config*: ***frozen* is a word;
   *true only because a constraint holds* is a CONDITION**, and no string expresses it. **On being
   handed a new category, grepping for its name is the one move guaranteed to fail.**
   ⚠ **WORKED CATEGORY-3 INSTANCE, self-reported by the coordinating session:** it closed every
   message to a peer for hours with that peer's state — *"`d1b588a` clean, `bab9836` untouched"* —
   carefully tensed, **true only while the peer's freeze held, with no route on its side to detect
   the change.** ⛔ **It built a running log of exactly the claim type that had just been identified,
   while congratulating itself on the tense.** ✅ **Fix: say *"as last reported, under the freeze"*.**

   ⛔ **AND THE REFERENT RULE THAT GOES WITH IT: EVERY STATE CLAIM ABOUT A FROZEN MIRROR IS AMBIGUOUS
   BETWEEN THE COPY AND THE SOURCE, AND THE DEFAULT READING IS THE SOURCE — the half the author
   cannot see.** ⭐ **The pair is the evidence, because it is the same sentence structure with the
   luck removed:** one claim where both readings happened to be true — `bin/android-browser` is
   byte-identical across both repos and the device (`sha256` `024e6fcd…`, curator-measured
   2026-09-01) — and one where they now **diverge**, a size table true of the frozen clones and false
   of the repos, since `contract/RULES.md` is byte-identical at both HEADs (`0a79d9f0…`, measured the
   same day). ✅ **When a mirror is frozen, say WHICH of the two you measured, every time.**
   ⚠ **PROVENANCE: categories 1–2 and the failed `frozen` sweep are the coordinating session's, the
   sweep first-hand; category 3, the constraint-expiry framing and both referent instances ORIGINATE
   WITH THE PEER SESSION; the two byte-identity measurements are curator-measured on this device.** ⚠ **And it is NOT a licence to explain every deletion** — it binds a
   value a reader would EXPECT to find, and in tool source it stays inside `CODING-RULES.md` rule 1
   (one line, present tense): *"read it with `git rev-parse`"* is permitted, *"this used to hold the
   hash"* is history and is not. ✅ **The practice is already this corpus's, unnamed until now** —
   **89** stated-absence / anti-restoration markers across **20** files (curator-measured
   2026-08-23, positive and negative controls both correct), e.g. T0's *"No package total is quoted
   here on purpose — derive it"* and `REGRESSION.md` Q64's *"Do not re-add a stamp"*.
   ⛔ **AND THE SHARPER FORM, ADDED 2026-08-23: A PROBE INHERITS ITS AUTHOR'S ASSUMPTION, SO IT
   CANNOT FIND THE ERROR THAT ASSUMPTION CAUSED.** This is not *"my sweep was too narrow"* — it is
   that **the same wrong belief wrote the claim and wrote the pattern that was supposed to catch
   it**, so the two agree by construction and the sweep returns a confident empty. The instance: a
   kernel build stamp was recorded as `#1` for a build that is `#3`, and the sweep run to hunt
   exactly that class of error was itself anchored on `#1 SMP PREEMPT` — three of the four builds
   really are `#1`, so the empty result read as a property of the artefacts rather than of the
   probe. **Anchor on the invariant part (`SMP PREEMPT`), never on the field whose value is in
   dispute.** ⚠ **The remedy is a SECOND SCORER OR A CONTROL, not more care** — a positive control
   the pattern must hit is what separates *did not run* from *nothing there*
   ([[self-made-fix-needs-another-scorer]]).
   ⛔ **AND A CONTROL DRAWN FROM THE SAME SAMPLE AS THE PROBE INHERITS THE SAME ASSUMPTION — SO THE
   CONTROL PASSES AND THE SWEEP IS STILL BLIND. Added 2026-08-23.** This is the clause above arriving
   one level up: it is not enough that a control exists, it must come from a **different sample than
   the one that motivated the probe**. Two instances the same day, one on each machine. ⚠ **RELAYED,
   laptop-side, not verifiable here:** a MAC-shaped regex written from a certificate field — which
   renders **uppercase** — missed roughly fifty **lowercase** hardware MACs in pushed history; any
   control drawn from the same certificates would have hit. ✅ **On-device, the curator's own:** a
   whole-document identity scan was run over the **documents** and never over the **evidence tree**
   beside them, so the population was wrong and every control inside it passed.
   ⭐ **STATE WHAT A GREEN ACTUALLY CLAIMS, BECAUSE THE WEAKER SENTENCE SOUNDS LIKE THE STRONGER
   ONE:** *"the gate was run"* is nearly worthless; *"the gate would have caught a planted instance"*
   is the claim worth having, **and a planted positive line is the only cheap thing that separates
   them.** ⚠ **Note that this is NOT the same as the counted-edit assertion in §*Safety*** — that one
   proves your belief about a file; this one proves the instrument can see its target at all.
   ⛔ **THE ASYMMETRY THAT MAKES THIS WORTH A CLAUSE RATHER THAN A HABIT: A FALSE CLEAN ABOUT YOUR
   OWN CORPUS HAS NO NATURAL ADVERSARY.** A false *accusation* about someone else's is loud, arrives
   in front of a party who can refute it, and gets corrected within the hour. A false *clean* about
   your own is silent, agrees with what you wanted, and nobody is positioned to contradict it —
   **and nothing in the probe distinguishes the two cases.** Weight your scepticism by which of the
   two a result is, not by how carefully it was run.
   ⚠ **The mirror image is real and is the reason this is not simply *"widen the sweep"*:** the
   corresponding fix pass on the peer machine reached for a corpus-wide substitution on the wrong
   half of the string, which would have destroyed four legitimate unrelated captures. **One
   instrument too narrow to find it, one nearly too broad to fix it, both inheriting the same
   assumption.** *(The narrow-sweep instance is on-device; the broad-fix instance is relayed from
   the peer session and is not verifiable from this box.)*
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
  ⛔ **AND A ROW CAN BE STALE *BECAUSE ITS NEIGHBOURS WERE CORRECTED* — AN ANNOTATION PASS
  MANUFACTURES THE APPEARANCE OF COVERAGE OVER EXACTLY THE ROWS IT SKIPPED. Added 2026-08-23.** A
  reader scanning a table sees dated correction markers on the rows around one and reads the
  unmarked row as *checked and still true*, when it was simply **not looked at**. ⚠ **The more
  thorough the annotation pass, the stronger the false signal it leaves on its own gaps** — this is
  the *stale confidence rating* shape from §*A verification claim must name the artefact*, produced
  by omission rather than by assertion, and it is invisible to a contradiction sweep because the
  skipped row conflicts with nothing. ⭐ **When you annotate part of a table, say which part** — a
  one-line scope note above it costs less than the re-audit its absence buys.

   ⛔ **EXPLAINING SOMETHING WELL FEELS LIKE FILING IT, AND THE BEST-PUT INSIGHT IS THE ONE MOST
   LIKELY TO GO UNRECORDED.** Added 2026-08-17 from three instances in one session, two of them
   caught only by auditing outward claims against the corpus. **The symptom is specific and
   checkable: the items that went unfiled were the ones the author was most pleased with.** A rule
   articulated crisply in a message, a summary or a reply produces the satisfaction of having done
   the work, and that feeling is indistinguishable from having done it. ⚠ **This entry is itself an
   instance** — the signal was stated to a peer, called the most useful thing in the exchange, and
   filed nowhere until a later audit went looking.
   ⛔ **AND THE MECHANISM IS WORSE THAN SATISFACTION — AN ACKNOWLEDGED MESSAGE IS A COMPLETED
   TRANSACTION. Relayed from the laptop peer 2026-08-23 and sharpened jointly.** A finding that
   **lands well** is *more* likely to go unrecorded, not less: the acknowledgement closes the loop
   that filing would otherwise close, and filing is what you do with something that still feels
   loose. ⚠ **So the population at risk is not the marginal findings — it is the BEST ones**, and a
   corpus built by filing what nags you accumulates the mediocre and loses the sharp. ⛔ **Nothing
   about being more careful touches this: COUNT A MESSAGE AS ZERO.** Five instances in one evening
   across two machines, every one a sentence its author had called the most useful thing in the
   exchange.
   ⭐ **THE OPERATIONAL HALF — AN UNFILED FINDING BOTH PARTIES *KNOW* IS UNFILED IS A QUEUE; THE
   FAILURE IS ONE BOTH PARTIES *BELIEVE* IS FILED. The state on disk is identical and only the
   belief differs**, which is why nothing softer than a grep closes it. ⇒ **Say which state it is
   in, every time: *"I have told you"* and *"it is written down"* are different claims, and only
   the second is checkable.** ⚠ **And a decision NOT to file is also a fact about the corpus — it
   is the one nobody reports.** Silence after *"I will consider it"* is indistinguishable from
   having filed it: two states, one output.
   **The check: after any pass, grep the corpus for every claim you made ABOUT the corpus** — not
   your memory for having made it. `/usr/bin/grep -rl '<the claim>' <tiers>`, one line per claim.
   ⚠ **Give that audit a positive control** (a string you know is present) **and a negative control**
   (one that cannot be), and ⛔ **distrust a UNIFORM verdict in either direction — all-pass as much
   as all-fail.** A clean result from an uncontrolled instrument is not evidence: on 2026-08-17 a
   13/13 "all missing" came from a broken glob, not a broken corpus, and acting on it would have
   rewritten nine correct entries. `PRECONDITIONS.md` **N-81**.
   ⛔ **THE SAME VERB, POINTED AT STRUCTURE: A CLAIM ABOUT A DOCUMENT'S SHAPE IS AS UNVERIFIABLE
   FROM MEMORY AS ONE ABOUT ITS CONTENTS.** Added 2026-08-23 after the peer predicted where an
   oversized memory file would split — *"the seam is already visible"* — and, on opening it, the
   real cluster was different and pulled in two ORIGINAL bullets they had not counted as part of
   the theme at all. ⭐ **A seam predicted from a summary is a claim about structure you have not
   re-read**, and the file in question already carried *never critique a citation from a summary,
   open the file*: **the bullet naming the error stayed in the retained half while the error was in
   the message about it.** ⚠ **A wrong seam costs MORE than an oversized file** — two coherent
   halves is a structure people trust, and it does not announce itself the way a size does.
   ⭐ **AND A SPLIT IS A DIAGNOSTIC, NOT ONLY A SIZE REMEDY:** grouping by theme is what makes a
   corpus tell you a new finding is old. The three recording failures of 2026-08-23 turned out to
   be three instances of a bullet that predated all of them, invisible until a split put them side
   by side.

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

⛔ **AND THE LABELS BIND WHAT YOU SEND, NOT ONLY WHAT YOU FILE — A CORRECTION NEEDS ONE AS MUCH AS A
CLAIM DOES. Added 2026-08-23.** A correction and a claim arrive through the same channel and get the
**same reflexive acceptance**, so an unlabelled *"actually, it's X"* is adopted exactly as fast as an
unlabelled assertion. ⛔ **The failure mode is BUNDLING: an item you reasoned to, sent in the same
packet as one you measured, inherits the measured one's credibility — and nothing in the packet
distinguishes them.** ⭐ **The fix is SENDER-SIDE and costs one word.** It cannot be receiver-side:
**the receiver is precisely the party with no way to tell**, which is why *"they should have tested
it"* is not a remedy. ⚠ **And an unlabelled claim you send lands somewhere your own T3 cannot
reach** — a retraction filed here does not un-install it there. Instance, and the mechanism it
corrupted in a peer's tool: T2 [[announced-is-not-done]] instance 12.

### A PEER-SOURCED MEASUREMENT CARRIES A DEVICE TAG — added 2026-08-31

⛔ **A PEER-SOURCED MEASUREMENT CARRIES A DEVICE TAG AT THE MOMENT IT IS WRITTEN, OR IT IS
UNUSABLE.** This corpus is **single-device by construction** — T0, `KERNEL-V2.md`, both kernel maps,
`PRECONDITIONS.md` and `TOOL-TEST-RESULTS.md` all say *"this device"* and mean one handset. A peer's
finding about `con_mode`, a driver, a kernel config or a tool version can be **entirely true and
about a different machine**. ⚠ **The failure is silent and it is exactly the shape T2
[[kernel-capability-codebase-maps]] accumulates** — a wrong-machine fact reads identically to a
right-machine one, and no contradiction sweep reaches it. **No peer-sourced claim is promoted into a
kernel or precondition file without its tag.**

**Operator decision 2026-08-31**, taken with the sibling-handset estate entry that made a peer
instrument reachable (T0 §*Scope and authorization*). The instrument half is
`CLAUDE-HARNESS.md` **`H-9`** — *a peer with different artifacts is a different instrument, not a
second opinion*; **this is the filing rule that follows from it, and neither is much use alone.**

⭐ **RE-DERIVATION BEATS THE TAG, AND IT COMES FIRST: RE-DERIVING A PEER'S FIGURE ON THIS DEVICE COLLAPSES
THE CHAIN RATHER THAN ANNOTATING IT.** A reader who can re-derive should not be reaching for a label at
all; **the tag is the fallback for what you cannot check.** ⚠ **And *"relayed, and I checked it"* and
*"relayed"* are DIFFERENT CLAIMS — a figure you re-derived is filed FIRST-HAND and untagged, not as
relayed-and-confirmed.**

⛔ **NAME THE ORIGINATOR, NOT JUST THE CHANNEL — added 2026-09-01, and it is a defect in the token as
first specified.** *"Relayed from a paired session"* records the channel and loses the one thing the
round-trip hazard below turns on: a figure that went **coordinator → peer → curator** and one the **peer
measured** are not the same claim, and the original wording rendered them identically.

⛔ **NAME THE PACKAGE THE EVIDENCE CAME FROM, NOT THE TOOL YOU WERE USING WHEN YOU FOUND IT.** Worked
example, measured on both boxes 2026-09-01: a `res.Status` finding is about the contents of a JS file that
ships in **`bettercap-caplets`**, a separately-versioned `Architecture: all` package whose version scheme
is not even the same kind as the binary's (`0+git20250401-0kali1` against `2.41.5-0kali1`). ⭐ **So two
boxes can MATCH on the binary and DIVERGE on the caplets with nothing in `bettercap -version` hinting at
it** (`PRECONDITIONS.md` **P-124**). **The artefact is the one the EVIDENCE came from, which is frequently
not the one you invoked.**

⭐ **PROVENANCE IS NOT ALWAYS DIVERGENCE — the tag records provenance and does NOT assert difference.**
A `PROVENANCE:` clause that reads as *"therefore distrust this"* over-applies the rule. **The
discriminator has three arms:** a claim about the **handset, the kernel or the radio** is divergent by
default; a claim about a **shared userspace artefact** is transferable **once the artefact is named,
versioned and hashed**; and the artefact to name is the one the evidence came from. **Verified instance:**
`/usr/bin/bettercap` and the `proxy-script-test.js` caplet are **byte-identical across the two boxes**,
sha256 computed independently on each, so a bettercap API-level finding transfers between them with the
divergence **nil**.
⚠ **AND THE UPGRADE IS RECORDED RATHER THAN SUBSTITUTED, because the substitution is the tempting move.**
That claim was first made as *"identical binary"* — **an inference from a printed version string and a
file date, about to be filed as a fact.** The peer refused it and supplied hashes. ⛔ **In an evening whose
whole subject was probes that agree without measuring the same thing, that one nearly went in — inside the
rule written to prevent exactly that.**

⭐ **THE TAG IS A LITERAL TOKEN, NOT A STYLE — `PROVENANCE:`.** Free prose was tried for one evening
and produced three correct rows worded three different ways, which is an *editorial* audit. A fixed
token makes it mechanical: `grep -c 'PROVENANCE:'` against the count of peer-sourced rows. Name (i)
which parts are this device, (ii) which are relayed and from what kind of machine, (iii) the
instrument the peer used where it differs from ours, and (iv) that it was not re-derived here.

⛔ **THE WORKED EXAMPLE IS THIS RULE FINDING A DEFECT IN THE WORK OF THE AGENT THAT WROTE IT, WITHIN
THREE HOURS, ON A ROW ALREADY REPORTED AS CORRECTLY LABELLED.** In one apply on 2026-08-31 the
curator filed three peer-sourced items — `TOOL-BACKLOG.md` **G-28**, `PRECONDITIONS.md` **P-119**
and **P-120** — and reported to the coordinator that all three were labelled. **Two were.**
**`P-119` carried no device tag at all:** its general mechanism and its `LIVE INSTANCE` are genuinely
this-device, which is why it passed the author's eye, **but its enumerated list of intermediaries —
HTTP cache, service worker, HSTS upgrade — is peer-sourced and sat in the same untagged voice as the
on-device material.** ⚠ **A row that is mostly right is the hard case: the true parts vouch for the
relayed part, and nothing in the text marks the seam.**
⭐ **The transferable half, and it is why the token exists: THE AUTHOR SCORED THEIR OWN LABELLING
FROM MEMORY AND IT PASSED; THEY SCORED IT AGAINST THE FILE AND IT DID NOT.** Same failure as
§*Safety*'s *treat a zero on a file you wrote as a probe failure until proven otherwise*, pointed at
provenance instead of at text. T2 [[self-made-fix-needs-another-scorer]], instance 3.

⛔ **LIMITATION OF THIS RULE, IN THE DANGEROUS DIRECTION — IT READS AS SUFFICIENT AND IS NOT. Added
2026-09-01.** ⭐ **THIS CLAUSE IS PROPHYLACTIC ONLY. ONCE A CLAIM HAS ROUND-TRIPPED THERE IS NO DETECTION
PROBE.** An unsourced fact appearing in both sessions' output is **indistinguishable** from two independent
measurements of it — **that is not a gap in our instruments, it is the hazard's definition.** Every other
rule in this file earns its keep by naming an honest probe; **this one has none, and binds at the moment of
writing or not at all.** ⚠ **A reader who skims it as *"be careful about sourcing"* has taken the wrong
thing from it.**

**The mechanism:** device-tagging defends against **wrong-machine** facts. Here **both copies really are
about the right machine — they are the same copy twice.** A tag records who said a thing and has nothing to
attach to at the moment one session **repeats a peer's claim in its own voice**. ⛔ **RESTATING A PEER'S
FACT IS NOT CONFIRMING IT, AND A LATER READER CANNOT TELL THOSE APART.** Either attribute it in the
sentence — *"per the peer's capture"* — or go and check it and say which you did. **What must not happen
is repeating it in your own voice.**
⚠ **It generalises past its instance, which is why it is a rule: every fact one session relays and the
other repeats acquires a second apparent witness for free** — that is how a corpus assembled from two
sessions manufactures agreement it never earned, **and the echo is the thing that makes it look checked.**

**The instance, 2026-09-01, with all three parts because no one of them would have shown the shape:** the
coordinating session asserted a regression case *"matching what `lanmitm` reported loading"* — unsourced,
from session scratch; **the peer wrote it back in its own voice with no independent source**; and the
curator's check of the run directory found **no artefact on disk carrying that line**. ⛔ **The original
unsourced claim was the coordinator's; the echo was the peer's, which filed it against itself; the outside
check was the curator's.**
⭐ **SAME FAILURE ONE LEVEL UP FROM §*Classification order*'s *a control drawn from the same sample as the
probe inherits the same assumption, so the control passes and the sweep is still blind* — with SESSIONS
substituted for SAMPLES.** A reader who has internalised the probe version should get the agent version
free; each makes the other memorable.

⭐ **THE POSITIVE FORM, ADDED 2026-09-01, AND IT IS THE ONLY THING THAT SURVIVES THE LIMITATION ABOVE:
CONVERGENCE IS EVIDENCE ONLY IF INDEPENDENCE WAS RECORDED BEFORE THE FACT.** Everything above says what
a round-tripped claim looks like and that no probe finds it afterwards; **this says what the good case
looks like, and without it a reader is left treating ALL agreement as suspect, which is the opposite
over-correction.** **The instance, 2026-09-01:** two sessions produced the same `android-browser` verdict
structure independently — one holding the peer's symptom report but not its code, the other holding
neither the code nor the commit — **and that counts as two witnesses only because the independence was
stated at the time.** ⛔ **Had the patch been sent first and adopted, the result would look IDENTICAL and
be worth nothing; afterwards the two cases are indistinguishable.** ⇒ **The record is made at the moment
of DIVERGENCE, not at the moment of agreement** — which is the same *binds at the moment of writing or
not at all* the limitation clause states, pointed at the case worth keeping rather than the case worth
fearing.
⚠ **THE GENERAL FORM OF ALL OF THIS IS NOT HERE — it is `CLAUDE-HARNESS.md` §8.6**, widened the same day
to *a claim loses its qualifier while crossing between sessions*, of which restatement-as-corroboration
(this section) is one of three instances. **Deliberately a pointer and not a restatement:** three rows
describing one shape is how a corpus loses the shape.

⛔ **THE HAZARD ALSO OPERATES ON AN ERROR, NOT ONLY ON A FINDING — AND THAT IS WORSE, BECAUSE NOBODY
AUDITS A MISTAKE'S PROVENANCE. Added 2026-09-01.** Everything above describes a *finding* acquiring a
second apparent witness. **An error does it too, and survives longer for it.** Instance: a wrong
instrument — *"check `rc`, not the message text; 127 is a link failure"* — originated with the peer
session, was relayed and amplified by the coordinating session, and came back **attributed to the
coordinator**, who checked its own transcript and corrected the attribution. ⛔ **It survived hours
precisely BECAUSE it round-tripped:** the echo made it sound established enough that neither party
re-derived it, and it was written into a device file as a fix. **A finding that round-trips is merely
over-credited; an error that round-trips gets applied.**
⚠ **TAKING UNDUE BLAME IS THE SAME DEFECT AS TAKING UNDUE CREDIT, and it is the one nobody guards
against.** The coordinator's *"the bad instrument was mine"* was itself an **unverified claim**, made
in the direction that feels like accountability, and it would have put the wrong originator in the
corrections file. ⭐ **Ownership of an error is a claim about the world and takes the same evidence as
any other** — it was settled by reading the transcript, not by whoever volunteered first.
⭐ **Mirror of the credit-declined instance in `CLAUDE-HARNESS.md` §8.6: both are SENDER-SIDE, which is
the half that does the only work that gets done.**

⭐ **AND THE NEGATIVE FORM OF THE POSITIVE FORM ABOVE, because it is the case that actually arises:
A CONFIRMING MEASUREMENT TAKEN WITH THE ANSWER IN VIEW IS NOT A SECOND WITNESS, AND SAYING SO IS THE
ONLY THING THAT DISTINGUISHES IT FROM ONE.** Instance the same day: the curator re-derived a peer's
five-shell table and reproduced it **exactly**, while holding that table — and declined to call it
independent confirmation. ⛔ **A matching result is precisely when nobody looks**, so this is the
hardest direction to apply the rule and the one where it is worth the most. **File the reproduction
and the genuinely new part separately**: there, the matrix was a primed reproduction and the
*construction of the condition* was first-hand, and only the second could carry a retraction.

⛔ **A RELAYED PREDICTION IS NOT A RELAYED MEASUREMENT, AND EVERY INSTRUMENT IN THIS SECTION IS BUILT
FOR THE WRONG ONE. Added 2026-09-01.** Re-derivation, the device tag, naming the artefact and hashing
it all assume the claim is about a state that **exists**. **A prediction has no artefact to name and
no revision to state** — it fits any outcome until one arrives, and by then it has usually been
written down as though it were the outcome. ⚠ **It also arrives PRE-FORMATTED AS A FINDING**, because
that is how the sender phrased it, so the receiving pass has nothing to strip.
⭐ **THE PLACEMENT IS THE POINT — THIS IS THE SEAM WITH §*An AUTHORIZATION is not a claim* BELOW.**
That section works because a permission can **never** be re-derived; this file's count rule works
because a count **can** be. **A prediction is the third case: NOT YET.** ⛔ **So the `PROVENANCE:`
tag does not save you here — tag it and it still reads as established.** ✅ **The remedy is the
TENSE: write *"X predicts Y"*, never *"Y"*, and name who predicted it.**
⛔ **TWO CLAIMS WERE REFUSED IN THE FILING OF THIS ONE, AND BOTH REFUSALS ARE THE CONTENT.**
**(1) NOT UNIQUE TO A PAIR.** It was offered as *"the one hazard a paired arrangement CREATES rather
than catches"*; the clause above — *an error that round-trips gets applied* — is already one. ⚠ **The
uniqueness claim was asserted without checking the file it was being inserted into, four paragraphs
away**, which is the same shape as the summary overstatements in `CLAUDE-HARNESS.md` §8.6: **the
superlative was more quotable than the true statement.**
**(2) THE RELAY IS AN AGGRAVATING FACTOR, NOT A PRECONDITION — AND THIS IS THE MORE USEFUL CLAIM.**
It was offered as *"required both parties and required the relay"*. `CORRECTIONS.md` 2026-08-19
records a session writing its **own** prediction into T0 in the voice of a measurement, with no
second party involved. ⭐ **What the relay removes is the ONE DEFENCE: you can remember making your
own prediction; you cannot see the sender's tense.**
⚠ **PROVENANCE: the measurement/prediction asymmetry ORIGINATES WITH THE PEER SESSION, relayed by
the coordinating session, which re-derived neither refused claim before relaying it — an instance of
the asymmetry filed here, arriving inside the entry that files it, and self-reported as such. The
two supporting instances are on-device and curator-read: `PRECONDITIONS.md` **P-127**'s retracted
*rises* caveat, and `CORRECTIONS.md` 2026-08-19 §*A PREDICTION IN THE VOICE OF A MEASUREMENT*. Both
refusals are curator-checked against this file and against T3. Nothing here is a measurement.**

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

⛔ **AND SOME EVIDENCE CANNOT BE NAMED BECAUSE IT CANNOT BE RE-OPENED — added 2026-09-01. This section
assumed the evidence is re-openable and never said what to do when it is not.** **Tool stdout, a run's
console output and a message are evidence that EXPIRES with the session that saw it.** ⭐ **Where an
artefact can carry the same fact, cite the artefact.** ⚠ **The worked example is instructive precisely
because the claim was TRUE and correctly transcribed:** a regression case was sourced from a tool's stdout
line (`--inject: … (2677 B)`) and cited as though a later reader could open it; **the run directory holds
no such line.** The same fact is settled from the file alone by **size, mtime, content, and the mtime
predating the run.** ⛔ **The failure is UNRE-OPENABILITY, not inaccuracy, and the two look identical in a
report.** **The test: does a later reader have something to open?**

✅ **It is mechanically checkable, which is why it earns a place here:** grep the verification verbs
(`verified`, `re-verified`, `measured`, `machine-verified`, `re-executed`, `confirmed`) and ask
whether a commit hash, a path, a build dir or a date sits within a line of each. *"Avoid blanket
claims"* admits no such probe.

⛔ **AND THE ARTEFACT IS ONE OF *FIVE* COORDINATES — NAMING ONLY THE FILE IS THE COMMONEST WAY TO
NAME A BASELINE AND STILL MISS. Added 2026-09-01, and the enumeration is the point: three of the
first four were already filed, separately, and the fourth was missed BECAUSE nothing listed them
together.** A measurement's identity is
**(artefact × revision × invocation × device × unit)**:
⚠ **It was written as FOUR and a fifth arrived the same day — so read the count as the current
length of a register, never as a closed set.**

1. **ARTEFACT** — the path, commit, build dir or date. **This section.**
2. **DEVICE** — §*A PEER-SOURCED MEASUREMENT CARRIES A DEVICE TAG*. A true finding about the wrong
   handset reads identically to a right one.
3. **REVISION** — `PRECONDITIONS.md` **P-128**: ⛔ *a re-derivation across revisions measures LAG
   and looks exactly like ERROR*. **When re-deriving a RECORDED measurement, reconstruct the
   revision it was taken at** — that row's own correction fell to this and was corrected back only
   after reconstructing the commit.
4. ⭐ **INVOCATION — NEW, AND IT IS THE ONE WITH NO EXISTING HOME: A PROBE RUN IN A DIFFERENT MODE
   IS NOT A MEASUREMENT OF THE SAME THING, AND ITS OUTPUT IS INDISTINGUISHABLE FROM ONE.** Instance,
   2026-09-01: `scan-secrets.sh`'s self-match set was derived **by measurement and correctly** —
   **against the default probe set** — and missed a check that runs under `--public` only. **A
   derived set is scoped to the MODE it was measured in and reads complete either way.**
5. ⭐ **UNIT — NEW 2026-09-01. THE RULE IS *NAME THE OBJECT AND THE UNIT*: A NUMBER IS NOT IN THE
   UNIT THE READER ASSUMES, AND NOTHING IN IT SAYS SO.** ⛔ **AN INSTRUMENT IS ONE WAY A UNIT GOES
   UNNAMED; AN ENCODING IS ANOTHER; THERE WILL BE MORE — DO NOT LET THE EXAMPLES BELOW BECOME THE
   RULE.**
   ⛔ **THAT WARNING RESTS ON ONE READING OF ONE DOCUMENT AND HAS NO DISCONFIRMING ARM — READ IT AS
   A FRAMING, NOT AS A RESULT.** The peer's own version of this entry states the general form in its
   opening line and then narrows to *two instruments* in its illustrating paragraph. ⛔ **That is
   the whole of what is claimed. No cause is offered for the narrowing and none is checkable; no
   prediction is made about what a reader does with it.** ⚠ **It is not readable from this box at
   all, so even the one reading is relayed.**
   ⛔ **AND DO NOT LET IT DRAW CREDIBILITY FROM THE NUMBERS BELOW.** The two mechanisms that follow
   have arms — an archive to extract, a `diff` to re-run — and the framing above has none; **an
   entry that lists measured instances and then states a framing lends the framing the measurements'
   standing, and the framing is the part nobody could have falsified.** ⚠ **Whether *arm
   availability* is the right general split is CONTESTED between the two seats and is deliberately
   NOT filed as a taxonomy here** — what is filed is the per-claim marking, which survives either
   way. The two mechanisms seen so far — ⚠ **only the second is measured on this device** —
   **leading with the one that proves this is an axis at all rather than a footnote to §4**:
   **(i) TWO ENCODINGS, ONE FILE — NO FLAG, NO MODE, AND NEITHER INSTRUMENT WRONG.** ⚠ **RELAYED
   from the sibling handset; UNFILED THERE AS WELL — found during verification after that entry was
   written, so it exists in transcripts only and is corroborated by no filed record anywhere. Not
   checkable from this box.** A T0 verified as untouched read **14,032** against **13,898** logged
   earlier and was nearly reported as GROWN — **14,032 BYTES against 13,898 UTF-16 UNITS**, one
   unchanged file with an mtime predating the whole session. ⛔ **It would have filed a phantom edit
   and sent someone hunting a cause that does not exist**, which is a worse outcome than a wrong
   sentence. ⛔ **Same artefact, same revision, same device, no mode difference — naming all four
   coordinates above would have PASSED, and so would *state the instrument*, because a length
   reported without its encoding names an instrument and still no unit.**
   **(ii) ONE TOOL, TWO MODES** — ✅ **curator-verified on this device 2026-09-01, and it is the
   member a reader can open:** plain `diff` prints **three** change specs (`624c624`, `629c629`,
   `920a921,1105`) where `diff -u` merges the adjacent pair into **two** hunks. Same three changed
   regions, two readings; with the unit unstated the two seats read arithmetic agreement as a
   disagreement. ⚠ **This one is arguably reducible to §4 INVOCATION — (i) is not, which is why the
   order matters.**
   ⚠ **Partial homes exist and are NOT coverage:** §*T1.5* (*state the instrument or do not state
   the number*, `du -sb` vs `du -sh`) and §*T2 size* (4,096 vs 4,000) each catch one way. **Name the
   unit, not only the instrument.**

✅ **The mechanical check above extends unchanged**: beside each verification verb, look for the
path/commit **and** the arguments the probe was run with. ⚠ **A flag that turns checks ON is the
dangerous shape** — the default run is the one people repeat, so the extra checks are exactly the
ones never re-derived.

⛔ **AND A CLAIM ABOUT THE OTHER MACHINE'S STATE IS UNVERIFIABLE IN BOTH DIRECTIONS — PRESENCE IS
THE EASIER SLIP, BECAUSE IT SOUNDS LIKE HELPFULNESS RATHER THAN A CLAIM. Added 2026-08-23.**
**Neither machine may assert ABSENCE about the other's corpus** — that half was agreed on 2026-08-23
and, ⛔ **checked before writing this, HAD NEVER BEEN FILED: `grep` over this file and
`REGRESSION.md` returned 0.** The inverse — *"you are holding X"* — is the one that actually fired.
⚠ **Aggravating, and the reason this is a clause and not a note: the peer's message saying they did
NOT have the file had already arrived, was QUOTED in the same reply, and was contradicted in it.**
It changed a decision — the operator was told a fix would cost a re-copy, and the cost was zero.
⭐ **WHY IT WAS INVISIBLE TO ITS AUTHOR, WHICH IS THE TRANSFERABLE HALF: A VERSION TABLE IS A CLAIM
ABOUT WHAT YOU MADE; ONLY A COVERAGE CHECK MEASURES WHAT THEY HOLD.** Three editions of a document
were announced and **zero arrived**, while the real file sat unchanged on their disk for two hours —
**every message in between described a state of the world that was never true anywhere.** The table
was accurate about authorship and was never evidence about possession, so consulting it felt like
checking. **Ask what they hold; do not compute it from what you sent.** Instance: T2
[[announced-is-not-done]] 13.

⚠ **Three failure shapes this rule alone does not catch — check for them by hand.** *(The third failure shape was added 2026-08-23; citations elsewhere name it by that phrase.)*

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

3. ⛔ **BOTH TRUE SOMEWHERE, CONTRADICTORY HERE — A THIRD SHAPE, ADDED 2026-08-23, AND IT IS THE ONE
   NEITHER INSTRUMENT CAN REACH.** Two sites state values that were each **correct in their own
   scope**, disagree with each other, and **neither is stale**. ⛔ **A contradiction sweep finds
   nothing, because it needs a claim that contradicts a MEASUREMENT and both halves cite real
   probes. An artefact comparison finds nothing, because it needs a STALE value and neither is
   stale.** **Only reading the corpus against itself finds it, and nothing automates that on a
   100 KB reference document.**
   ⚠ **It comes in two grades and the cross-FILE one is worse.** Within one file a careful reader
   may notice; **across T0 and a large T1 doc nobody reads both halves in the same sitting.** Both
   grades occurred on 2026-08-23: the peer's reference document carried the right build banner in
   its body and a contradicting one **in the header whose whole purpose was to stop readers trusting
   stale values** *(relayed; that copy is not readable from here)*; and, measured here, T0 and
   `docs/nethunter-app/evil-twin.md` asserted **opposite scopes** for the same `grep` shadow — T0
   *"the scope is the assistant, not the device"*, the T1 doc *"the chroot's `grep` is ugrep … it
   matters if you copy the idiom into a chroot script"* — each with a genuine `[PROBED]` transcript
   behind it.
   ⭐ **The cheap partial defence, and it is the only mechanical one: enumerate every occurrence of
   the value across the corpus and `sort -u` it.** More than one distinct string is the finding. It
   catches the *value* grade and **not** the *scope* grade, which has no value to enumerate — that
   one is found only by asking, of a claim you already believe, *"does another file say the opposite
   about the same mechanism?"*

**Scoring a verification — three rules from one two-machine transport check, 2026-08-23.**

- ⭐ **THE DIAGNOSTICS EXIST TO EXPLAIN A MISMATCH, NOT TO ESTABLISH A MATCH.** Where a check has one
  authoritative verdict (a hash) and several auxiliary readings (byte, character and line counts, a
  final byte), **the verdict decides and the auxiliaries only ever explain a disagreement.** A
  transport failure was nearly declared on a file whose hash matched, because an auxiliary count
  disagreed — **and the auxiliary was the broken thing.** ⛔ **A wrong diagnostic outranking a right
  verdict costs you a resend of a perfect artefact, and worse, it teaches the next reader to
  distrust the one reading that was sound.** **Name the verdict before you run the check.**
- ⛔ **A MATCHING HASH PROVES FIDELITY TO THE SOURCE, NOT CORRECTNESS OF THE SOURCE.** The same
  exercise: the first hash exchanged was of a file containing a **wrong** build stamp. Byte-identical
  mirroring would have reproduced it faithfully and **both sides would have shown green.**
  **Verify the VALUES you care about separately from the transport**, and say which of the two a
  green result covers. ⚠ **Filed here and deliberately NOT in T2 `true-verdict-wrong-set`**, whose
  declared shape is a true verdict about a wrongly-derived *set*; here the set is right and the
  *question* is different. The exclusion is recorded so that shape stays enforceable (§*T2 size*,
  disqualifier (b)).
- ⭐ **A MODEL THAT HAS TO CLOSE BEATS A PROBE THAT HAS TO PASS.** A disputed multi-byte count was
  settled without trusting any `grep`: the occurrences were classified by width, the byte delta they
  predict was computed, and the prediction was checked against the measured before/after difference
  — **it balanced.** A probe that "passes" has one degree of freedom and a bad probe passes too; a
  model that must **reconcile two independently measured quantities** has none. ⭐ **Same shape as
  the pre-flash check where *config identical* PLUS *image bytes differ* together separate "Kconfig
  untouched" from "the build did nothing" — neither half proves it alone.** ⚠ **This is also the
  answer when the instrument itself is in dispute** (see `PRECONDITIONS.md` **P-93**, where three
  engines return three different counts of the same thing): **when you cannot trust the ruler, find
  two measurements that must add up.**
- ⭐ **PREDICT, THEN MEASURE — THE ONLY DEFENCE AGAINST DATA THAT IS STABLE, REPRODUCIBLE AND WRONG.
  Added 2026-08-23.** ⛔ **AN EXPECTATION WRITTEN AFTER THE RUN CONFIRMS NOTHING.** Derive, from
  something independent of the run, what the answer *has to be*; then run it. **The MISMATCH is the
  finding, and only a prediction can produce one.**
  ⚠ **RELAYED FROM THE LAPTOP PEER, NOT REPRODUCIBLE FROM THIS BOX — recorded as their measurement,
  not ours.** Regenerating a large provenance dataset, they predicted from git that only two files
  could have moved since the data was last validated, and named the exact pair of counts that
  implied. **The run returned a different pair: the 2026-08-08 data had misclassified 238 files** —
  every file byte-identical to mainline **and** mode `100755` was listed as *modified*; all 238
  byte-identical executables wrong, **zero** non-executables wrong, the discrepancy set exactly the
  byte-identical executables. ⛔ **That dataset had been re-checked repeatedly and PASSED EVERY
  TIME**, because the check asked *"does the run reproduce its expected output"* — and it did.
  **The number was stable, reproducible and wrong for fifteen days, and nothing that re-ran it could
  ever have noticed.** ⚠ **The CAUSE is labelled HYPOTHESIS BY THEM AND MUST NOT BE UPGRADED** — a
  join on `mode+sha` rather than `sha` alone would produce exactly that set; they note the published
  join script parses the blob SHA correctly, **so whatever ran in 2026-08-08 was not the script that
  was written down, and that session's script is unrecoverable.**
  ✅ **There is a device-side instance of the practice already, and it is worth citing because it is
  ours**: the `netem delay` result was predicted as an explicit falsification condition and written
  down **UNVERIFIED before the test** — and it held (`KERNEL-VERIFICATION-LOG.md`, the netem row).
  ⛔ **THE POINT OF THIS BULLET IS THE SET, NOT THE FOURTH ITEM. State the four together, because
  what makes the gaps visible is what each one is BLIND to:**

  | what went wrong | the defence | what that defence cannot see |
  |---|---|---|
  | **broken instrument** — it cannot see the subject at all | a **positive control in the same invocation** | a working instrument aimed at the wrong thing |
  | **wrong subject / wrong extent** — an honest measurement of something else | **a model that must balance** two independently measured quantities | data that was never looked at |
  | **never having looked** | an **unconditional scheduled gate** | data the gate reads and passes |
  | **stale-but-consistent data** — stable, reproducible, wrong | ⭐ **PREDICT BEFORE YOU MEASURE** | nothing in this table; it is the outer one |

  ⛔ **The fourth is the only one that catches a dataset which is stable, reproducible and wrong,
  because EVERY OTHER DEFENCE IS SATISFIED BY IT**: the instrument works, the subject is right, the
  gate runs and passes. ⚠ **Read it beside its negative half rather than instead of it** — T2
  [[true-verdict-wrong-set]] records that *a correct measurement over the wrong extent is the harder
  error, because the number survives every re-check*. **That says re-reading cannot catch it; this
  says what can. Neither is complete alone.**

- ⭐ **A STATE CHECK CANNOT ANSWER A BEHAVIOUR QUESTION — added 2026-08-23, and it is the cheapest
  of these to get wrong because both premises come out TRUE.** *What is currently tracked*
  (`git ls-files`) describes the **past**; *what a future `git add` would do* (`git check-ignore`)
  describes the **behaviour of the guard**. For any question of the form *is this protected?*, only
  the second answers. The instance: *"the operator said keep those docs offline"* (true) plus
  *"they are already untracked"* (true) yielded *"they are therefore safe"* (**false** — nothing was
  ignoring them; they were merely never added). ⚠ **It fails toward reassurance, and the reassuring
  reading is the one both true premises support.** ⭐ **The general form, which is not git-specific:
  a property that RESEMBLES the one you need is a different property** — same family as
  `PRECONDITIONS.md` **P-91** (*writable* answers *can I change it*, never *can I change it back*).
  **Name the question as past-tense or future-tense before choosing the probe.**
- ⭐ **WITHHOLD WHAT THEY CAN DERIVE INDEPENDENTLY; SUPPLY WHAT YOU ARE THE ONLY SOURCE OF — AND
  DO NOT APPLY ONE POLICY TO BOTH. Added 2026-08-23.** In a two-party check, withholding a value the
  other side can derive **from a file they already hold** is what creates real independence: they
  compute it, you compute it, the comparison means something. **Withholding a value you are the sole
  source of is not caution — it is refusing to run the test**, because the only expectation left for
  them to compare against is one derived from the artefact under test, which is circular.
  ⚠ **Worked pair, cross-machine 2026-08-23: the CIPHERTEXT hash was rightly withheld** (each side
  derives it from its own copy — that is the transport check) **and the PLAINTEXT hash had to be
  SUPPLIED** (only the sender's device had the original; without it the receiver can only hash what
  they just decrypted and confirm it equals itself). ⛔ **The trap is CONSISTENCY: withholding both
  "for the same reason" is consistency with the wrong thing.** ⭐ **The question is not *how secret
  is this value* but *where would their expectation come from if I do not send it?* — if the answer
  is "from the thing being tested", send it.**
  ⛔ **WITHHOLDING IS NOT ALTERNATING TURNS — THE RECEIVER MUST COMPUTE BEFORE THE SENDER DISCLOSES,
  added 2026-08-23.** Because transfers are sequential, that duty always falls on **whoever already
  holds the file**, which is not whoever is "due a turn". ⚠ **Fairness is satisfied by alternating;
  independence is not** — a value disclosed before the other side has computed theirs cannot be
  un-seen, and the check silently becomes a confirmation.
  ⛔ **AND AN ABBREVIATED HASH USED AS A NAME DEFEATS THE WITHHOLD IN THE SENTENCE THAT CLAIMS IT.**
  Measured instance: *"archive `1d94a7bb…` (withheld from you as agreed)"* — **32 of 256 bits
  disclosed while asserting the value was withheld.** ⚠ **The shorthand arrives wearing the grammar
  of a LABEL, not of a value**, and hash prefixes had been in use as conversational names all
  evening. ⭐ **The mechanism is the durable half: A CONVENTION ADOPTED FOR CONVENIENCE SILENTLY
  OVERRODE A RULE ADOPTED FOR RIGOUR, BECAUSE THE TWO WERE NEVER BROUGHT INTO CONTACT** — neither
  party had said which wins, so there was nothing to violate and nothing to notice. **Refer to a
  withheld artefact by FILENAME ONLY.** ✅ **And score what you actually got: the comparison was
  reported at 224 independent bits, not 256.**
- ⭐ **A CONTROL PROVES THE INSTRUMENT FIRED. RULING OUT A RIVAL EXPLANATION IS A SEPARATE
  REQUIREMENT — AND THE REPORT OF A REAL RUN OFTEN ALREADY CONTAINS IT. Added 2026-08-23.** The two
  get conflated because both are called "controls". A deleted control file proves the cleaner ran
  and recognised that file shape; it says nothing about the rival explanation *"it never traverses
  that subtree at all"*, under which the subjects' survival is meaningless. ✅ **The instance, and
  the reason this is worth stating: the rival was killed by READING WHAT ELSE THE SAME RUN DID** —
  it had deleted files under a different `/data` subtree — **which cost nothing and beat designing a
  second probe.** ⭐ **Before building another instrument, read the output of the one that already
  ran: a real run touches more than your subject, and the surplus is free evidence.** ⚠ **Ask both
  questions explicitly — *did my instrument fire?* and *what else could produce this result?* — or
  a fired control will be taken as an answer to both.**
- ⛔ **ONCE A FIX IS APPLIED, THE INSTRUMENT THAT CARRIES IT CAN NO LONGER TEST THE ARTEFACT MEANT TO
  CARRY IT — SO THE TESTER HAS TO BE BUILT IGNORANT. Added 2026-08-23.** A recovery document was
  written to make an encrypted archive openable by someone who has only the document. **Verifying it
  by hash would have proved only that the bytes arrived.** The honest check is to **USE it cold** —
  and the peer's existing harness could not perform that check, because it had learned the missing
  parameter an hour earlier and **would have succeeded whatever the document said.** ⭐ **A separate
  harness had to be BUILT TO BE IGNORANT: nothing hardcoded, every parameter parsed from the document
  at runtime and ECHOED BEFORE USE** — the echo is what makes it checkable that the document, and not
  the harness's memory, supplied the value. ✅ **Both archives then opened; both discriminator members
  unanimous on both.**
  ⭐ **The uncomfortable general form: the moment you fix something, you lose the ability to test the
  fix's CARRIER with the instrument you just fixed.** Knowledge contaminates the tester, and **the
  contamination is invisible because the run PASSES.** ⚠ **It is a blind spot the four-defence table
  above does not name** — the instrument is not broken, the subject is right, the gate runs, and the
  data is fresh; the tester simply already knows the answer. ⚠ **Distinct from *a matching hash
  proves fidelity to the source, not correctness of the source*, and the pair is worth holding
  together: that one says a green transport result does not vouch for content; this one says a green
  CONTENT result does not vouch for the artefact when the scorer was pre-loaded.** Related:
  [[self-made-fix-needs-another-scorer]], of which this is the instrument-side case — there the
  scorer must not be the author, here the scorer must not already hold the answer.
  ⚠ **AND A COLD TEST THAT PASSES PROVES MACHINE-SUFFICIENCY, NOT HUMAN-SUFFICIENCY.** A parser
  extracting the parameters shows the document CONTAINS them; it says nothing about whether **a
  person under pressure can find and read them**, and a recovery document's reader is by definition
  having a bad day. ⛔ **Its prose is tested far less than its parameters** — evidenced the same day,
  on this box, by the document's own author failing twice within the hour to locate content in it by
  `grep`. **Where an artefact has two audiences, say which one your green result covers.**
  ⭐ **SO WHAT DOES SUCH A DOCUMENT SAY ABOUT ITSELF? A FILE CANNOT STATE ITS OWN HASH — IT STATES
  ITS COVERAGE, AND THE READER CHECKS THAT AGAINST THE DIRECTORY THEY ARE STANDING IN. Added
  2026-08-23.** For the reader a recovery document is written for there is **no harness and no hash
  table**; a self-referential hash is unverifiable and a hash of it kept elsewhere is one more thing
  to lose. **Coverage — *this document describes these N artefacts, by name* — needs no external
  reference and fails loudly when the directory has moved on.**
  ⚠ **COROLLARY, AND IT IS THE HALF MOST WOULD DROP: STALE IS NOT WRONG. Separate what LAPSES from
  what NEVER CHANGES.** The decrypt command has never changed and is correct even on the oldest
  copy; only the hashes and the snapshot table lapse. ⛔ **Without that split, *"this document is out
  of date"* impugns the one part that has never been wrong** — and a reader who distrusts the
  command is left with nothing.
  ⛔ **AND DO NOT GIVE IT AN ORDINAL. A version identifier two parties compute differently is worse
  than none.** Measured: an edition header claimed *"edition 1 covered one archive, edition 2 covered
  two"* — **there was never a one-archive edition**; both existed when the first version was written,
  and the history was reconstructed from the author's memory of their own edits **inside a document
  whose entire job is being trustworthy alone.** Two parties then counted it differently (coverage
  generations vs hash releases), making one file simultaneously edition 3 and edition 4. ✅ **Fixed
  by DELETING the ordinal, not renumbering it** — the coverage check never needed one. *(A deletion
  with a stated reason: §*Never delete*, a stated reason for an ABSENCE.)*
  ⛔ **AND THE INSTRUMENT WAS APPLIED TO EVERYTHING EXCEPT THE INSTRUCTIONS FOR THE INSTRUMENT.**
  Ciphertexts and plaintexts were hashed at both ends for hours, with withheld values and negative
  controls — **and the document explaining what the hashes were for was never hashed once.** It
  surfaced only because an *"it is unchanged"* was retracted; **nothing in the protocol would have
  found it.** ⚠ **`PRECONDITIONS.md` P-79 owns one instance of this** (the secret gate skips itself,
  so the one unscanned file in the public tree is the densest identity string in it); **this is the
  general form — the artefact that DESCRIBES a procedure is systematically outside it.**

## Never delete

- **Traps and anti-patterns.** Highest value per byte on this box. They may move T0 → T1, never
  to T3 and never out.
- **Correction narrative.** It exists to stop a wrong conclusion being re-derived. Move it to T3
  with a dated entry; leave a one-line stub at the original site if the correction is still
  surprising (e.g. "USB HID works — see CORRECTIONS.md 2026-08-06").
- **Secrets.** Referenced by path only, never by value, in any tier. `~/.config/secrets/*`,
  `/etc/wpa_supplicant.conf`, `~/.claude/.credentials.json`, `~/.msf4/`, `~/.ssh/`. The curator
  never reads or echoes a secret value, and never proposes an edit that inlines one.
- **A stated reason for an ABSENCE.** *"No package total is quoted here on purpose — derive it"*,
  *"do not re-add a stamp"*, *"`--band 6` was dropped — do NOT restore it"*. It reads like narrative
  and is not: it is the only thing defending the absence, and cutting it invites a reader to restore
  the value the removal existed to prevent. §*Classification order* owns the rule.

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
  pointer*, not by span; and **do not promise a total** — report each cut as it lands.
  ⛔ **AND IT MISPROJECTS IN BOTH DIRECTIONS — THE ADDITION CASE UNDER-SHOOTS BY ABOUT THE SAME
  FACTOR THE CUT CASE OVER-SHOOTS.** Added 2026-08-19: a harvest projected **+177 B** into T0 by span
  arithmetic and measured **+600 B** on apply, **3.4×**, in a pass that was already at the ceiling.
  ⚠ **The clause above is scoped to *savings* and reads as advice about being disappointed by a
  trim; the risk it does not cover is the one that spends budget you do not have.** Same cause —
  markers, wrapping and the surrounding prose an edit drags with it are not in the span you counted.
  **`wc -c` before and after, per edit, in both directions**, and treat a projected addition at the
  ceiling as an upper bound on the *benefit* and a lower bound on the *cost*. Same failure
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
  ⚠ **`\b` IS A GNU `grep` EXTENSION, NOT POSIX — it is not a word boundary in `awk`, which reads it
  as backspace and answers 0 with no error.** So this clause steers you into a silent zero the moment
  you reach for `awk` instead of `grep`: `PRECONDITIONS.md` **N-89** owns the A/B and the honest
  forms (`\y` in gawk, or count with `/usr/bin/grep -cE` and say which binary).
- **Quote a number only from the artefact it describes** — not from a doc about the artefact, and
  not from an earlier pass over it. That single property is what both failures lacked.
  ⛔ **THIS CLAUSE GOVERNS SOURCING AND NOT RECONCILIATION, AND BOTH SEATS CAN SATISFY IT WHILE THE
  EXCHANGE STILL FAILS — added 2026-09-01, do not read it as covering a number HANDED ACROSS A COPY
  BOUNDARY.** A count of an annotated **fork** honestly describes the artefact it was taken from and
  is still not a count of the file that was forked, so the comparison reads as **agreement**.
  §*Citations into T0 rot* rule 8, *the `wc -l` half of that probe is the weak member*, owns the
  measured instance and the remedy.
- **This is not scepticism about the sender.** Re-deriving is part of accepting the job; the sender
  is not in a position to have re-measured, which is the whole reason the work was delegated. Both
  of the above were self-reported by the coordinator as soon as they were shown the probe.
- It applies with equal force to a number the curator is about to *quote as a saving*. See
  *Retirement*, where the same failure is recorded from the other direction.
  ⚠ **AND RE-DERIVING HAS ITS OWN FAILURE, WHICH THIS CLAUSE WALKS YOU INTO — added 2026-09-01: a
  re-derivation run against a MOVED artefact measures LAG and is indistinguishable from finding an
  ERROR in the original.** Reconstruct the revision the recorded figure was taken at before calling
  it wrong; the coordinates a measurement has to name are enumerated in §*A verification claim must
  name the artefact it was checked against* — **that section owns the count, which moved 4 → 5 on
  2026-09-01; do not restate a number here** — and the worked instance is `PRECONDITIONS.md`
  **P-128**.

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
   filename can be a different object on each**: `HANDOFF.md` is a **per-session scratch file,
   overwritten from scratch every session and explicitly not a knowledge tier** here, and **the
   persistent entry point** there. ⛔ **DERIVE BOTH LINE COUNTS, NEVER QUOTE THEM** — `wc -l` on each
   side. ⚠ **This clause said *"70 lines … and 475 lines"* until 2026-08-19, and the 70 was a dated
   measurement written as a property of the file** (`TOOL-BACKLOG.md` §*How to read a row* clause 2,
   occurring inside the clause that teaches citation discipline): **the local file measured 151 lines
   that day.** The **475** had no on-device provenance at all — it appeared nowhere but in this
   sentence — so it is **reported by the laptop session, not measured here**, and is recorded that
   way rather than repeated as fact. **Both figures are deleted rather than refreshed, because a
   fresh number rots the same way.**
   So `HANDOFF.md:147/154/182` — cited from `KERNEL-CODEBASE-MAP.md` when this clause was written —
   were **never valid on this machine**: not drift; the name resolves elsewhere. ✅ **Those citations
   have since been converted in place to a prose cross-machine marker and no `HANDOFF.md:NNN`
   citation survives in that file** (0 matches, 2026-08-19); **the only occurrences left in the
   corpus are this clause and T2 `correct-constraint-general-inhibition`, both of which are talking
   ABOUT them.** ⚠ **So the check below now matches its own description of the defect and not the
   defect** — the Q58 shape, and a reason to read every hit rather than count it. Earlier instance:
   `SECTION-D-DATA.md`, cited for "full per-symbol results" and absent from this device entirely.
   ⚠ **This class is invisible to every other check in this file** — the citation is well-formed, the
   target exists, the artefact is named. It fails only on *on which machine?*
   ⭐ **It is also the DOMINANT one: 3 of the corpus's 4 past-end-of-file `.md:NNN` citations are this
   single class**, and unlike rules 1–7 it has a cheap mechanical check — **`NNN` greater than
   `wc -l` of the local target**, which scans the whole corpus in about a second.
   ⭐ **AND THE SPLIT EARNS ITS COST BEYOND ERROR-CATCHING — added 2026-08-23. NEITHER PARTY WROTE
   THE VERSION OF THEIR OWN FINDING THAT WAS KEPT.** This box's *inertness* rule landed in the
   peer's corpus in **their** wording; their **UNDETERMINED** rebuild landed here in theirs.
   **The originator has the insight; the receiver has to make it work against an artefact the
   originator does not hold, and the FITTING is where the sharpening happens.** ⇒ **A finding that
   never crosses to someone holding a different artefact stays in its first, roughest form** —
   which is a reason to relay a finding **even when the peer cannot verify it**, and not only when
   you want it checked.
   **Mark a laptop-authority pointer as such rather than deleting it**; a pointer that says
   "laptop-only, not here" is the correct end state.
   ⛔ **THAT MECHANICAL CHECK COVERS ONLY THE `:NNN` FORM — A CROSS-MACHINE **PATH** CITATION HAS NO
   LINE NUMBER TO OVERFLOW, SO NOTHING IN THIS RULE FIRED ON ONE UNTIL 2026-08-21.** Its probe is now
   **`PRECONDITIONS.md` P-86**, and the trap is that the obvious test passes: **`/home/kali` EXISTS on
   this box** — a 136 K distro stub, dotfiles only — while `/home/kali/nh-kernel` and `/home/kali/keys`,
   which four T1 kernel files cite, do **not**. **So `test -d /home/kali` exits 0 and certifies nothing
   about what was cited.** ⭐ **Test the CITED LEAF, never the home directory it hangs off** — a
   home-dir test is a positive control that cannot fail. ⚠ **Note the direction, because it is the
   opposite of the `:NNN` disarm above:** there the check goes quiet as the local file grows; here the
   check answers **yes** and always did. **Same rule, two forms, and only one of them was instrumented.**

   ⛔ **THAT CHECK IS SELF-DISARMING, IT DISARMED ITSELF ON 2026-08-19, AND IT NOW RETURNS ZERO HITS
   ON A CORPUS THAT STILL CONTAINS THE DEFECT.** It fires only while the cited line **overflows** the
   local file, so **it stops working as the local file GROWS — silently, and toward a clean bill of
   health.** ⛔ **Past that point it is worse than useless: the citation begins resolving to
   UNRELATED LOCAL CONTENT, which misleads harder than a dangling one.** Measured that day:
   `HANDOFF.md` went **139 → 151 lines** in one session's updates, and **`147` stopped overflowing
   and started landing on a real sentence about hardware asks** — plausible text, no signal.
   ⛔ **AND THERE IS A SECOND, INDEPENDENT DISARM THAT HAS NOTHING TO DO WITH DRIFT — THE NOTATION.**
   The citation is written compound, `HANDOFF.md:147/154/182`, and any `\.md:[0-9]+` extraction sees
   **only `147`**; **`154` and `182` were never visible to this check at any file length.** Verified
   2026-08-19 against a **positive** control — `HANDOFF.md:9999`, a line number no local copy can
   reach, which **fires**, while the compound form yields one number. ⚠ **This clause first said
   *"negative control"* and that was wrong terminology: a POSITIVE control is a string the instrument
   should catch, a NEGATIVE one is a string it must not.** ⭐ **That control string now LIVES IN THIS
   CLAUSE ON PURPOSE, which makes the check self-testing: a corpus-wide sweep returning ZERO hits is
   reporting a BROKEN INSTRUMENT, because this line is always a hit.** ⛔ **Do not delete the `9999`
   as noise and do not "fix" it as a rotten citation** — reading the hit, which every mechanical check
   in this file already requires, settles it in one line.
   ⭐ **Stacked, the two mean the sweep reads CLEAN: two of the three were never checked, and the
   third fell inside the file the same day.** **Write one citation per number**, and **compare
   against a line count taken in the same command as the grep** — never against a figure in prose.
   ⭐ **THE GENERAL FORM, and it is the durable half: A DETECTOR WHOSE TRIGGER DEPENDS ON A PROPERTY
   OF THE THING IT WATCHES DISARMS ITSELF WHEN THAT PROPERTY DRIFTS — and the drift that disarms it
   is ORDINARY USE, not neglect.** Here the watched file is *designed* to be rewritten every session,
   so the decay was scheduled from the day the check was written.
   ⭐ **THE REMEDY, ADDED 2026-08-23 — THIS CLAUSE HAD THE DIAGNOSIS AND NO FIX, AND THE GAP COST A
   SECOND INSTANCE.** A discriminator built on values that *happen* to differ is an **assumption
   about what has not been written yet**. Instance: a two-member snapshot check was warned to be
   fragile, and **four hours later a pass left both members untouched** — it would have returned a
   confident *unanimous* verdict on two different archives. ⛔ **THE FIX IS NOT MORE ROWS.** Score
   against **every known candidate** and report **the SET that fits: exactly one match is a verdict ·
   zero is UNKNOWN · MORE THAN ONE IS UNDETERMINED and must never be resolved by picking.** ⭐ **And
   mark any row that is identical across all candidates as BLIND, so the degradation is VISIBLE
   instead of silent** — that single line is what turns a self-disarming detector into one that
   reports its own disarming. ⚠ **Same shape, second form: matching on a property that merely
   happens to be unique today** (basenames, 92/92 at the time) — **use full paths and REMOVE the
   assumption rather than re-validating it each pass.**
   ⛔ **AND A RELATED MECHANISM FROM THE SAME HARNESS, WHERE THE COMPARISON STOPPED DISCRIMINATING
   FOR A DIFFERENT REASON: THE SENTINEL AND A LEGITIMATE VALUE SHARED A REPRESENTATION.** A parser
   emitted `path|v1|v2|v3` while the consuming loop still read `member pre post`, so both variables
   were **empty**, the member lookup returned **nothing**, and the actual value was empty too —
   **and `[ "" = "" ]` is TRUE.** ⛔ **Six rows, six confident WRONG verdicts, no error**: *not found*
   and *matches expectation* had become the same string, so a failed lookup was indistinguishable
   from a successful match. ⭐ **The fix is specific and cheap: never let a MISSING value and a REAL
   value share a representation — guard emptiness explicitly before comparing.** ⚠ **The closing
   verdict in that same tool was an unconditional `echo`, asserting success regardless of any check
   — which this contract already forbids** (§*Safety*, *a result nothing branches on is decoration*);
   ⛔ **it is recorded here because the author had written BOTH governing rules into their own memory
   THAT DAY and shipped both violations anyway** (`REGRESSION.md` §*Method*, the just-explained-it
   window). *(Relayed, laptop-side; not reproducible from this box.)*
   ⚠ **Cross-referenced with `PRECONDITIONS.md` P-84 (a symlink at a device path makes `cmp` compare
   a file with itself and report SAME forever) because both are instruments that stop working through
   ordinary activity and CANNOT REPORT THEIR OWN DISARMING — but they are NOT the same mechanism, and
   the differences are why the link is worth making rather than tidy.** **(1)** P-84 needs an **act**
   aimed at the artefact — someone symlinks a file, usually as a tidy-up; this one needs **nobody to
   do anything unusual**. **(2)** A disarmed `cmp` returns a **silent null** (`SAME`); a disarmed
   line citation **resolves to confident wrong content**, so it degrades from *no answer* to *a false
   one*. **(3)** This one carries a **notation** disarm with no analogue in P-84 at all. **Treat them
   as one FAMILY to sweep for and two mechanisms to fix.**

   ⛔ **AND THE SAME FILENAME CAN BE THE SAME OBJECT AT AN OLDER REVISION ON THE OTHER MACHINE — A
   CASE THE `NNN > wc -l` CHECK ABOVE STRUCTURALLY CANNOT SEE, BECAUSE THE CITATION IS WELL-FORMED,
   THE TARGET EXISTS AND THE HEADING RESOLVES. Added 2026-09-01.** Rule 8 covers a name resolving to
   a **different object**; this is a name resolving to an **older** one.
   ⭐ **CURATOR-MEASURED ON THIS DEVICE 2026-09-01, and the peer's relayed figure was re-derived
   rather than tagged** (§*A PEER-SOURCED MEASUREMENT…*, *re-derivation beats the tag*): the copy
   handed to the sibling handset — `/sdcard/peer-bootstrap-2026-09-01/…tar.gz`, mtime 01:01 — holds
   `CLAUDE-HARNESS.md` at **924 lines / 94,100 B**, **`cmp`-identical** to the curation snapshot
   taken 2026-08-31 23:54; the live file is **1,109 lines / 110,527 B**.
   ⛔ **THE DRIFT IS NOT WHERE IT LOOKS, AND THIS IS THE WHOLE VALUE OF THE ROW.** `diff` returns
   **three changed regions — two HUNKS under `diff -u`, which merges the adjacent pair, and the
   instrument has to be named or the two readings look like a disagreement**: `920a921,1105` — **+185 appended lines inside §8.6, the last section** —
   and `624c624`/`629c629`, **two rewritten rows in §7's OPEN register (`H-9`, `H-7`)**. ⭐ **The 185
   are the SAFE half: an anchor phrase into absent text fails loudly. The 2 are the dangerous half —
   the peer holds the SUPERSEDED wording, which reads as current and announces nothing**, and they
   are the very rows §8.6's own limitation-claim rule caused to be reworded (*"no route found"*, not
   *"no route"*). ⛔ **So an appended section is the visible drift and an EDITED line is the silent
   one; a tail-only account of a fork is the wrong way round.**
   ⭐ **THE FORM THAT SURVIVES IT IS RULE 1's, AND THIS IS WHY RULE 1's SECOND HALF IS LOAD-BEARING
   RATHER THAN DECORATIVE: HEADING *PLUS A DISTINCTIVE ANCHOR PHRASE*.** A heading alone resolves in
   the stale copy and reads as success. ⛔ **NEVER ADD A LINE NUMBER AS A THIRD ELEMENT — an anchor
   is CONTENT and crosses copies; a line number never does**, and on the receiving machine it is
   wrong by construction.
   ⚠ **AND READ THE FAILURE CORRECTLY WHEN IT FIRES: *"your citation does not resolve"* from a peer
   is evidence about THEIR COPY at least as much as about your citation.** One such report on
   2026-09-01 was attributed to a changed heading; the heading was byte-identical
   (T2 [[agent-measurements-vs-judgements]], the observation-vs-attribution instance).
   ✅ **The settling probe needs no shared filesystem and no line numbers: exchange `wc -l`, the LAST
   heading, and a fingerprint of the section you are citing.** ⚠ **There is no version string, no
   hash and no update route in the file, and the stale copy is internally consistent and reads as
   complete** — nothing on either side announces the gap, which is why the probe has to be asked for.
   ⛔ **AND THE `wc -l` HALF OF THAT PROBE IS THE WEAK MEMBER — IT WAS EXCHANGED AND IT PRODUCED
   FALSE AGREEMENT. Added 2026-09-01, and it is a correction to the sentence directly above.**
   ⭐ **A COUNT IS A CHECKSUM ONLY IF BOTH SIDES KNOW WHICH OBJECT IT COUNTED, AND A FORK IS NOT THE
   FILE IT FORKED FROM.** A number carries no self-description: it reconciles against whatever
   object the reader assumes, so the failure surfaces as **agreement** rather than as the loud
   mismatch the probe was added to manufacture. ⛔ **A REMEDY THAT FAILS WHILE BEING FOLLOWED IS
   WORSE THAN NO REMEDY, BECAUSE COMPLIANCE BECOMES THE EVIDENCE THAT IT WORKED.**
   **The instance:** a peer's entry read *"944 here against 1,109 there, the extra 185"* — and
   **1,109 − 944 = 165**. The `944` counts that box's **annotated fork** (the pristine 924 plus ~20
   lines of its own local annotation); the `185` is the delta on the **pristine 924**. One number
   measured locally, one relayed, set side by side as one comparison. ⚠ **It stood as FILED T2
   MATERIAL, not as a draft — that, and not how long it stood, is the load-bearing part.**
   ⛔ **NOTE THAT §*One tier owns a number*'s *quote a number only from the artefact it describes*
   WAS SATISFIED BY BOTH SEATS THE WHOLE TIME**: `944` is a true count of the artefact it describes.
   **That clause governs SOURCING; nothing governed the RECONCILIATION, which is what this adds.**
   ✅ **The remedy is in the probe already: the LAST HEADING and the SECTION FINGERPRINT are
   CONTENT and cross copies — `wc -l` is the only member that cannot describe its own subject.**
   **Send the count with the object named — *pristine, as received* vs *my working copy* — or send
   the other two.**
   ⛔ **AND IT LIMITS THE ONE SELF-CATCHABLE CHECK THIS CORPUS HAS**
   ([[agent-measurements-vs-judgements]], *print two quantities whose relationship is CONSTRAINED
   and let the constraint do the checking*): **all three constrained quantities WERE printed, in one
   sentence, on both seats, and nobody performed the subtraction.** A printed constraint only checks
   when the quantities are of the **same object**, and here the arithmetic was the only thing that
   could have shown they were not.
   ⛔ **DO NOT READ THIS CLASS AS RARE — that reading is the one that stops people checking.** **Five
   CATCHES from one seat over about one hour**: the object case above; the `diff`-mode unit case
   (§*A verification claim must name the artefact*, coordinate 5(ii)); **three unqualified *"hunks"*
   written into that seat's own paperwork WHILE IT WAS WRITING THE RULE AGAINST EXACTLY THAT**; and
   the UTF-16 encoding case (coordinate 5(i)). ⚠ **Two surfaced only because something else forced
   the arithmetic, not because anyone was looking.** ⛔ **THEY ARE CATCHES, NOT A RATE — THERE IS NO
   DENOMINATOR AND NONE CAN BE RECONSTRUCTED.** The claim is only that the class is common enough
   that treating it as an occasional slip is wrong in the direction that stops people checking.

   ⛔ **TWO KINDS OF CLAIM IN THIS ENTRY, AND THE SECOND MUST NOT BORROW THE FIRST'S STANDING.**
   **Everything with a number has an ARM** — an archive to extract, an arithmetic to redo, a file to
   count — **so for those the tag below says which was done, and ⛔ *not checked* is written as a
   GAP rather than omitted.** ⛔ **The generalisations carry NO arm and are tagged with nothing on
   purpose:** *a count is a checksum only if both sides know which object it counted*, *a fork is not
   the file it forked from*, and *a remedy that fails while being followed is worse than no remedy*
   are **framings drawn from the instances, not results of them** — the only responses available are
   agreement or a competing formulation. ⚠ **A verification tag on a claim nobody could have
   falsified is a FALSE ASSURANCE and is worse than no tag**, because it recruits trust for a check
   that was never available. ⚠ **The scoping claim that §*One tier owns a number* was satisfied
   throughout is HALF-ARMED: the clause was read here, the `944`'s honesty about its own fork was
   not and cannot be.**
   ⛔ **PROVENANCE — AND THE PEER'S AGREEMENT IS NOT CORROBORATION OF ANY OF IT.** The object
   instance, the encoding instance and the general formulation ORIGINATE WITH the paired session on
   the operator's **SIBLING HANDSET** (session `kali-logical-zebra` and its
   post-compaction successor `kali-giggly-diffie`), 2026-09-01. ⛔ **NAMED BY ROLE ONLY — the model
   and board strings were written here on 2026-09-01 and reached the PUBLIC mirror before the gate's
   rc was read; see the `scan-secrets` clause below.** ⛔ **BOTH SEATS' CORPORA ARE BEING
   WRITTEN FROM THE SAME EXCHANGE, SO TWO FILED HOMES ARE TWO COPIES OF ONE FRAMING AND NOT TWO
   CHECKS — a defect in the framing lands twice and nothing anywhere disagrees with it.** ⚠ **Over
   the rounds that produced this entry the receiving seat accepted each claim on arrival: that is
   ASSENT, and this entry must never be read as *confirmed on two boxes*.** **Three footings, and
   they must not be blurred:**
   - ✅ **RE-DERIVED HERE** — the `diff`-mode case, reproducible in this file; and, from
     `/sdcard/peer-bootstrap-2026-09-01/peer-bootstrap-2026-09-01.tar.gz`, pristine **924 lines /
     94,100 B** against the live `CLAUDE-HARNESS.md` **1,109 / 110,527 B**, delta **185**, and
     `1,109 − 944 = 165`.
   - ⚠ **RE-DERIVED THERE, RELAYED** — the object case itself. That seat states it re-derived the
     `-u` merge arithmetic; **its file is not readable from here and the `944` and its composition
     are not checkable on this box.**
   - ⛔ **RELAYED, UNFILED, UNCORROBORATED — the ENCODING case (14,032 B vs 13,898 UTF-16 units).**
     Filed on **neither** box; it exists in two transcripts, and the originating seat has given it a
     durable footing outside its own tiers while being explicit that **this is not filing**.
     ⚠ **It is the instance with the most teeth and the weakest footing at the same time, which is
     exactly where the temptation to lean on it is highest. Do not upgrade it without a probe.**

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
  ⭐ **AND THE ABORT IS THE GUARD WORKING, NOT AN OBSTACLE TO ROUTE AROUND — added 2026-08-23,
  because the temptation at an abort is to widen the pattern until it matches.** **A uniqueness
  assertion is a claim ABOUT THE FILE, and it is the claim an author is most likely to get wrong from
  memory**; the abort is the file contradicting the author. **The failure it prevents has NO signal:
  an edit that matches somewhere unintended, or matches nothing and silently changes nothing.**
  ⚠ **Two instances the same day, and the labels differ.** ✅ **On-device, curator's own:** a
  `PRECONDITIONS.md` edit aborted at `count 0` on a **one-space indentation** difference — the
  replacement text was correct and would have been written nowhere. ⚠ **RELAYED from the laptop
  build session, NOT verifiable from this box — recorded as claimed:** two edits asserted `count == 1`
  on `status = -ENOMEM;` and on `hidg->write_pending = 1;` in a file containing **each three times**;
  their words, *"both times the assertion was the defect while the edit was fine."*
  ⛔ **So an abort is evidence about your BELIEF, not about your edit — re-read the file, do not
  loosen the pattern.**
  ⛔ **AND THE SAME MISREMEMBERING BREAKS A GREP, WHERE THERE IS NO ASSERTION TO CATCH IT — added
  2026-08-23, and it is the reason this clause is not only about edits.** An `n == 1` guard turns a
  wrong belief about a file into a loud abort; a **probe** of the same file turns it into a silent
  zero that reads as **ABSENT**. Measured across two passes: the curator hit `count 0` twice on its
  own anchors (a one-space indent, a `THAT`/`That` case difference) — **caught both times** — and in
  the same window missed two `grep`s on prose it had written minutes earlier, once by
  misremembering a word (`HALF OF THE CORPUS` where the file says `HALF OF THE BACKUP`) and once on
  a phrase split across a line break, **and was one step from reporting a delivered file
  incomplete.** ⭐ **Authorship is the aggravating factor, not the protection: you probe your own
  text from memory and check it least.** **Grep for the shortest distinctive fragment, normalise
  whitespace, and treat a zero on a file you wrote as a probe failure until proven otherwise.**
  ⛔ **AND THE GUARD PROTECTS THE ANCHOR, NOT THE ROW — ADDED 2026-08-23, FROM THE CLAUSE ABOVE
  FAILING TO SAVE SOMEONE FOUR HOURS AFTER IT WAS WRITTEN.** A rename asserted `n == 1` on one
  string, **passed**, and was read as *"the reference is updated"* — while the `TOOL-BACKLOG.md` row
  being edited held **three** references to that name, plus an `OPEN` marker and a `NOT DONE` verdict
  that the rename had just falsified. ⭐ **`n == 1` is a claim that the ANCHOR is unique. It is not a
  claim that the anchor is the only place the FACT appears** — and the second is what an edit
  usually means. ⚠ **The failure is the more dangerous direction of the two: the guard fired
  correctly and answered a NARROWER question than the editor believed they had asked**, so the pass
  reads as verified. ⭐ **The cheap addition: after a rename or a status change, `grep -c` the OLD
  token across the edited file and require the count you expect — the counted edit and the
  post-edit count answer different questions and you need both.** *(Same day, same corpus, two
  actors: this is §*Classification order*'s "a row can be stale because its NEIGHBOURS were
  corrected" produced by a single-anchor edit rather than by an annotation pass.)*
- ⛔ **WRITING THIS CORPUS'S PROSE THROUGH A SHELL CONTEXT THAT HONOURS BACKTICKS EXECUTES IT — AND
  THE TOKENS IT EXECUTES ARE THE ESTATE'S OWN TOOLS. Added 2026-09-02, first-hand, a curator's own.**
  ⛔ **IT IS NOT A HEREDOC RULE — THREE CONTEXTS SUBSTITUTE, TWO DO NOT, AND A RULE WRITTEN ABOUT
  HEREDOCS DOES NOT REACH THE OTHERS.** Curator-measured on-device 2026-09-02, one command, four
  arms: `<<EOF` **substitutes** · `<<'EOF'` **literal** · double quotes **substitute** · single
  quotes **literal**. **A double-quoted `echo` carrying corpus prose has the identical defect.**
  ⚠ **The first diagnosis named the CONSTRUCT instead of the MECHANISM** — the same error shape as
  the rest of this family, keyed to a form rather than to what the form does.
  **THE INSTANCE:** a `regression-log.md` entry was written through an **unquoted** heredoc *so that
  `$TS` would expand* — which also armed every backtick in the payload. One pair ran and **deleted
  the word**, leaving `Mode , applied…`. ✅ **Repaired with a counted `n == 1` edit and re-diffed to
  identical; the file is correct** (`regression-log.md`, the 2026-09-02-19-06-29 entry, which
  carries the narrative). ⛔ **DETECTION WAS LUCK, NOT METHOD: the token that fired is not a
  command, so it errored VISIBLY. Any backticked token that IS a command substitutes at rc 0,
  leaving the command's output where the word was, with no error anywhere.** ⚠ **It fired AGAIN
  during the pass that filed it** — a double-quoted `echo` in a curator tool call printed
  `Command '<token>' not found`, reproducing the incident in a construct the first diagnosis had
  not named. **Two firings, two different constructs, one hour apart.**
  ⛔ **WHY THIS CORPUS SPECIFICALLY: ITS MOST-BACKTICKED TOKENS ARE LIVE COMMANDS, AND THE TOP TEN
  ARE THE ESTATE'S OWN TOOLS.** Curator-measured 2026-09-02 across the 73 corpus files (T0,
  `/root/docs/*.md`, T2, `memory-curation/*.md`), extracting single-word backticked tokens and
  testing each with `shutil.which`: **order-400 distinct live commands over order-4,000
  occurrences**, led by `rogueap`, `lanmitm`, `wificonnect`, `cmp`, `grep`, `usbgadget`,
  `hcxcapture`, `hidrun`. ⛔ **So the failure is not text corruption — it is BARE INVOCATION of
  radio, gadget and MITM tooling from inside a documentation edit.** ⚠ **NO EXACT FIGURE IS
  RECORDED HERE ON PURPOSE, AND IT IS NOT TIDINESS:** two independent runs within the hour,
  differing only in the extractor, returned **3,140 vs 7,298** distinct tokens and **366 vs 466**
  live commands — **the ranking was stable to ±1 and the magnitude was not.** **The SHAPE is the
  durable fact; the count is a probe artefact. Re-derive it, and name the extractor when you do**
  (§*One tier owns a number*).
  ⚠ **ONE SIDE EFFECT IS ESTABLISHED AND THE REST ARE NOT — DO NOT LEVEL THEM.**
  `catch-boot-warn` writes a dmesg capture to `/root/boot-logs/` on a bare run: **verified by
  source** (unconditional write, and the tool's own comment says an accidental invocation still
  writes) **and observed on-device 2026-09-02**. ⛔ **What `diagcap`, `usbgadget` or `rogueap` do on
  a bare invocation is UNTESTED, is not asserted here, and must not be resolved by running one.**
  ⭐ **THE REMEDY IS NOT "ALWAYS QUOTE", BECAUSE THE UNQUOTED FORM IS REACHED FOR ON PURPOSE.** You
  choose it when you want ONE legitimate expansion, and that single convenience arms every backtick
  in the payload — so *"always quote"* is advice that loses to the reason you deviated.
  **The form: QUOTE THE DELIMITER AND INJECT THE VARIABLE ANOTHER WAY** — build the string first,
  or `sed` a placeholder afterwards. ⭐ **Better still, keep the payload out of the shell entirely:
  read it from a file in the same program that writes it.**
  ⭐ **AND THE DETECTION METHOD IS WORTH MORE THAN THE RULE: STAGE THE DRAFT, THEN `cmp` AFTER THE
  WRITE.** ⛔ **Reading it back and finding it PLAUSIBLE detects nothing** — a substitution that
  deletes a word or splices in a command's output leaves prose that still reads. It is
  *assert that what you did NOT edit survived* pointed at the **payload** instead of the file, and
  *the load-bearing check runs on the far side of the irreversible step* with the write as the
  irreversible step. ⛔ **AND THE STOP CONDITION IS THE LOAD-BEARING HALF: ON A FAILED `cmp`,
  RESTORE FROM THE SNAPSHOT — DO NOT REPAIR IN PLACE.** A repaired file and an undamaged one are
  indistinguishable afterwards, which is this hazard's entire subject.
  ⚠ **PICK THE RIGHT CONTROL, AND THE WEAKER ONE WAS USED FIRST.** `$`-survival proves only that a
  **delimiter was quoted**: it covers the heredoc arm and is **silent on the double-quote arm**,
  which is the live one. ⛔ **AND THE CONTROL THIS ENTRY FIRST NAMED — BACKTICK *BALANCE* — CANNOT
  FAIL FOR THIS DEFECT AND MUST NOT BE USED.** A substitution consumes the whole ``` `token` ```,
  **both backticks**, so it changes the count by an EVEN number and **parity is preserved under any
  number of substitutions.** Proven by arithmetic 2026-09-02, hours after this same corpus catalogued
  two peer simulations whose positive controls could not fail: **a control that cannot fail was
  written into the entry about detection, in the entry about detection.**
  ✅ **What IS valid from that measurement is TOKEN SURVIVAL — the damaged pair was checked and found
  intact by NAME.** ⚠ **And whole-file parity is worse than useless: `REGRESSION.md` is legitimately
  ODD (1723 before an edit, 1751 after — delta 28, even), so reading parity raised a false alarm that
  only the snapshot settled.** ⭐ **The instrument is the DELTA across the edit against a known
  reference, or `cmp` against a staged draft — never a property of the file alone.** ⚠ **A pass that appends
  DIRECTLY has no staged draft to `cmp` against and has therefore run no check** — the corpus after
  such a pass is **un-contradicted, not known-clean**, and that is the honest way to report it.
- ⛔ **A DESTRUCTIVE READ MUST NOT SHARE A PIPELINE WITH AN OUTPUT-SHORTENING STEP — the READ-side
  twin of *stage the draft, then `cmp`* above. Added 2026-09-02, first-hand.** A delete-on-read
  capture was piped through `sed -n '1,30p'` for readability: **the shortening survived and the data
  did not.** The run directory was already removed, so the truncated report was the only remaining
  record. ⭐ **It INVERTS the remedy of T2 [[derive-from-the-artefact-not-a-report]] — you cannot go
  back to the artefact, because reading it is what destroyed it, so the report IS the artefact and
  must not be cut.** **Write the full output to a retained file and read sections FROM the file**;
  never `| head`, `| sed -n`, `| tail` downstream of a destructive step. ⚠ **Scope it by
  IRREVERSIBILITY, not by tool** — a delete-on-read capture, a consumed pipe, a one-shot ring read.
- ⛔ **NEVER `git checkout` TO UNDO A SCRATCH EDIT — copy the file aside instead.** Added
  2026-08-11 after a `git checkout` intended to discard a temporary change **reverted uncommitted
  work in the same file**. `git checkout -- <path>` restores the whole path from the index; it has
  no notion of "only the bit I was experimenting with", and the loss is silent and unrecoverable.
- ⚠ **Editing a T1 doc breaks the `nh-tools` repo mirror (BT-0.10) until it is committed.** A
  **named subset** of T1 docs is mirrored byte-for-byte alongside `bin/` and `lib/`, so a
  doc-only curation pass can violate the invariant without touching a tool. ⛔ **The repo's own
  `.gitignore` OWNS that set and its count — `grep '^!docs/' /root/tools/nh-tools/.gitignore` —
  and it CHANGES IN BOTH DIRECTIONS: it read `four` here, in `LAYOUT.md` and twice in T2
  `nh-tools-repo` until 2026-08-18, by which time it was six** (`CORRECTIONS.md` 2026-08-18) —
  ⛔ **and it has since SHRUNK**, `docs/APK-PAYLOAD.md` having left both the set and the device at
  operator direction (`git log -p -- .gitignore` is the record). **No current count is stated here on
  purpose.** **Do not act on a
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
  ⛔ **AND THERE ARE TWO `contract/` MIRRORS WITH OPPOSITE INVARIANTS — SYNC PER FILE, NEVER PER
  DIRECTORY. Added 2026-09-01.** The PRIVATE `nh-tools` copy is byte-identical to the device on all
  three files (curator-`cmp`'d that day), so a blanket `contract/*` loop is CORRECT there. **The PUBLIC
  `nh-method` copy carries a permanently SANITISED `contract/REGRESSION.md`**, so `cmp` reporting drift
  on that one file is the CORRECT state and copying the device version over it republishes this
  handset's identity. ⛔ **A `contract/*` loop MUST EXEMPT that file BY NAME** — and the exemption also
  travels in-band in the file's own header (`head -10 | grep -q 'DELIBERATELY NOT BYTE-IDENTICAL'`).
  ⚠ **Three imperatives forbidding the copy were already in place and it was overwritten anyway that
  day: a prohibition written about a FILE is unreachable from a loop written about a DIRECTORY.**
  T2 `nh-method-repo`.
- ⛔ **A CHECK THE CURATOR RUNS BEFORE A WRITE IS THE WRITE'S PRECONDITION, NOT A LINE ABOVE IT.**
  Added 2026-08-19, generalising the counted-edit bullet above — `n = s.count(old); if n != 1: abort`
  is that rule for one specific check, and the general form is that **a result nothing branches on is
  decoration, and it reads as rigour.** The instance: a verification printed
  *"CONTENT DIFFERS — investigate before syncing"* and the **same shell block then ran `cp`, `git
  add` and `git commit` unconditionally**, because the sync was never gated on the check. **The
  commit happened while the author's own gate said stop.** ⚠ **The content turned out fine, and that
  is the point — the outcome was fine, the process was not, and only the outcome is visible
  afterwards.** ⭐ **It is the third mechanism in a family `CODING-RULES.md` rule 8 already names
  twice** — *a `die` inside `$( )` exits the subshell* (**the message prints and the caller
  continues**) and *validate where the argument is PARSED, not where it is consumed* (a guard on a
  consuming call site fires only if that site is reached). **This one is neither scoping nor routing:
  there is NO CONSUMER AT ALL.** ⛔ **Rule 8 does not reach here, and that is why this clause exists**
  — it declares itself binding on *"whoever writes or edits a tool"*, so an agent's throwaway shell
  block gets no `bash -n`, no help-screen review and none of rule 8's commit checks. **The form:
  compute the check into a variable and make the write `[ "$ok" = yes ] || exit 1`, or put the write
  inside the branch. If you cannot say which statement consumes the result, there is no check.**
  ⛔ **AND THE TRANSCRIPT AFTERWARDS IS IDENTICAL EITHER WAY — added 2026-08-23, which is why a track
  record cannot substitute for a mechanism.** A check that ran and **gated** and a check that ran and
  was **ignored** leave the same evidence, and the ignored one leaves evidence that *looks like
  diligence*: the scan output is right there in the log above the commit. ⚠ **So *"it has always been
  run"* and *"it cannot be skipped"* are different properties, and only the second survives a tired
  session.** ⚠ **RELAYED, laptop-side, not verifiable from this box:** a peer's secret scan **printed
  a hit and the commit proceeded**, because the scan was a `printf` and nothing branched on it —
  their own error, their words. ⛔ **The live counterpart is on THIS box and is now filed:
  `scan-secrets.sh` is a SEPARATE COMMAND from `git push` and nothing enforces the ordering** —
  curator-measured 2026-08-23, **no `pre-push` hook in either repository and `core.hooksPath` unset
  in both**. `TOOL-BACKLOG.md` **G-20** owns it as a gap; this clause owns the rule.
  ⛔ **AND THE ARTEFACT IT LEAVES BEHIND IS WRONG IN THE DIRECTION A READER TRUSTS — added
  2026-08-23, RELAYED from the laptop peer, NOT verifiable from this box.** Their edit script
  asserted on an `old` anchor before writing; **the assertion FAILED and correctly refused to
  write** — and the next line, `git commit && git push`, ran anyway, because nothing branched on the
  script's exit status. **Commit `743e55c08` shipped with a message describing a paragraph that is
  not in it.** ⛔ **That is not a gap, it is a FALSE RECORD — and a commit message is precisely what
  a reader consults when they do not re-read the file.** ⚠ **Note what is different from the two
  instances above: the check WORKED.** This is not a broken instrument and not an optional gate; it
  is a **correct verdict discarded by the chaining around it**, so *"make the gate mandatory"* does
  not fix it and a green transcript above the commit is not evidence either way. **The form:
  `python3 patch.py || exit 1`, never `python3 patch.py; git commit`.**
- ⭐ **WHEN A SECRETS GATE BLOCKS A MIRRORED DOC, GENERALISE THE GUIDANCE — NEVER SCRUB THE EVIDENCE,
  NEVER TOUCH THE GATE. Added 2026-08-27.** Three actions are available and **two of them fail toward
  a different harm**: loosening the gate's filter so your own push passes is
  [[self-made-fix-needs-another-scorer]] exactly — **you would be editing the thing that scores you**
  — and scrubbing the campaign record destroys the only artefact that can still answer a question
  nobody has asked yet. ⭐ **Only the third is correct, and the reason it is correct is not
  compliance: A `P-`/`N-` ROW IS GUIDANCE AND A CAMPAIGN RECORD IS EVIDENCE, so the row never needed
  the literal in the first place** (§*Classification order*'s record-vs-guidance clause, applied to a
  SECRET rather than to a stale value). **Worked instance, 2026-08-27:** `scan-secrets.sh` failed on
  two literals of a VPN tunnel address inside a new `PRECONDITIONS.md` row; replacing them with
  *"the provider's standard tunnel address"* **made the row BETTER — it now generalises to any
  provider that hands every client the same address**, which was the actual lesson. The octets stayed
  in the unmirrored evidence file. ⚠ **State the absence in place**, or the next reader restores the
  literal to be helpful (§*Never delete*, *a stated reason for an ABSENCE*). ⛔ **And read the gate's
  verdict BARE — `PRECONDITIONS.md` P-104: behind a pipe it reports the pipe.**
- ⛔ **A COPY HAS TWO ENDS, AND YOU WILL CHECK THE ONE YOU ARE ALREADY THINKING ABOUT. Added
  2026-08-23.** Asked where a recovery sidecar was, the curator enumerated all four files of that
  name on this device and **warned the operator in as many words that the name was not unique —
  "four ways to grab the wrong one"**. ⛔ **That entire analysis was about the SOURCE. Nobody asked
  what was already at the DESTINATION.** The copy landed on the peer's arrival log: **15,313 B
  replaced by 7,330 B, silently, no warning, no prompt.** ⚠ **It was recovered by replaying writes
  from their session transcript to an exact byte-count match — a COINCIDENCE, not a backup.**
  ⭐ **The rule is NOT "obvious names collide", which merely tells you to worry about names — it is
  that THE END YOU ARE NOT CURRENTLY THINKING ABOUT IS THE ONE YOU WILL NOT CHECK.** Being alert to
  the ambiguity is no protection at all when the alertness is pointed at the wrong end; **the
  warning issued here was correct, specific, and aimed one direction away from the damage.**
  ⛔ **AND THE COROLLARY IS SHARPER THAN THE RULE — the peer's, adopted verbatim: A DOCUMENT THAT
  DESCRIBES A DIRECTORY IS THE WORST THING TO LOSE SILENTLY FROM IT, AND IT IS THE MOST LIKELY TO BE
  OVERWRITTEN, BECAUSE ITS NAME IS THE ONE EVERYONE INDEPENDENTLY REACHES FOR.** `README`,
  `MANIFEST`, `READ-ME-FIRST`, `INDEX` — the more useful the file, the more collision-prone its
  name, and **the loss is exactly the loss that removes the record of what was lost.** ⚠ **Note the
  recursion, because it is the whole warning: the file that would have told anyone what was in that
  directory WAS the file destroyed.**
  ⭐ **The forms, in order of preference: `cp -n` (or `mv -n`), which refuses rather than
  overwrites · `ls -la <dest>` before the copy, not after · a destination name that cannot collide.**
  ⚠ **This is the cross-file twin of *assert that what you did NOT edit survived*, one bullet below,
  and neither reaches the other:** that guard watches the file you are writing; this one watches the
  file you are not.
- ⛔ **THE LOAD-BEARING CHECK RUNS ON THE FAR SIDE OF THE IRREVERSIBLE STEP. Added 2026-08-23.**
  **Re-hash AFTER the copy, not before · verify the decrypt BEFORE the shred, not after · hash at the
  DESTINATION, not at the source.** Everything on the near side tests the **plan**; only the far side
  tests the **result**, and the near-side check is the one that feels like rigour because it is the
  one you can run without committing to anything. ✅ **Confirmed in practice 2026-08-23**: an
  encrypted artefact was moved off-device and back and returned byte-identical — **a round trip
  measured here, not a hash reported from the far end.** ⛔ **The instance that makes this a rule and
  not advice is `PRECONDITIONS.md` P-94**: an `openssl enc` output with a valid header, the right
  `file(1)` type and a size matching the padding arithmetic **to the byte**, which would not decrypt —
  and whose failed decrypt then produced an output within 11 bytes of the true plaintext size.
  **Header, size, format and output length are all PROXIES; the round trip is the only check that is
  not.**
  ⚠ **It is NOT a fifth row of the four-defence table above, and adding it there would dilute a set
  whose value is that it is closed.** That table answers *which defence catches which error*; this
  answers *where in time the load-bearing check sits*. **A defence on the wrong side of an
  irreversible step is not a weak defence — it is a defence of a different claim.**
  ⭐ **TRANSPORT COROLLARY, corrected in the same pass — the rule was over-generalised before it was
  ever written down here.** The standing form was *"send bytes, never a description"*, derived from
  one failure where a paraphrase differed from its original on 14 of 98 lines, and it had hardened
  into *"always paste the whole file"*. **Corrected: send BYTES for a REWRITE; send a PATCH PLUS A
  TARGET HASH for an EDIT.** A patch + hash is **strictly more verifiable than a paste**, because a
  paste's practical check is re-reading it — exactly the check that misses a subtle misapplication —
  while a hash does not care how the content arrived. Confirmed in practice: a one-line replacement
  plus a target hash landed byte-perfect on the peer's machine at 12.8 KB saved. ⛔ **What is not
  negotiable in either form is the DESTINATION RE-HASH.**
  ⭐ **AND THE DEEPER REASON TO SEND THE ARTEFACT, ADDED 2026-08-23: IT DOES NOT REQUIRE YOU TO KNOW
  WHAT THE RECEIVER'S INSTRUMENT ASSUMES.** Raw `tar -tzv` output was pasted rather than retyped,
  purely because it was less work — and the members carried a leading `root/` component while the
  peer's harness anchored every path probe at the top (`^docs/`). **On a PERFECTLY GOOD archive it
  would have reported five mismatches and sent them hunting a corrupt transfer.** ⚠ **The sender did
  not spot that assumption; the sender merely failed to filter it out** — which is exactly the
  property worth having, because **a paraphrase silently removes the evidence of an assumption
  mismatch, and the raw artefact preserves it.** ⭐ **The receiver-side half, and it is theirs:
  DETECT the common leading component rather than hardcoding one, and PRINT what you found** — the
  same *make the tool say which artefact it read* remedy T2 [[true-verdict-wrong-set]] records. ⚠ **File the over-generalisation as an
  INSTANCE, not a new shape** — it is the same failure as *the `grep` escape hatch is per-defect*
  (`PRECONDITIONS.md` **P-93**; `CORRECTIONS.md` 2026-08-23): **a remedy derived from one failure,
  applied one step outside the case that produced it.**
- ⛔ **ASSERT THAT WHAT YOU DID *NOT* EDIT SURVIVED — NOT ONLY THAT WHAT YOU EDITED IS RIGHT. Added
  2026-08-23, RELAYED from the laptop peer and not verifiable from this box.** Their snapshot script
  silently deleted three README sections (**78 → 57 lines**): a `re.sub(…, flags=re.S)` made `.` match
  newlines, so a table-row pattern `\|.*\n` swallowed to end of file. ⛔ **A flag added for one part
  of a pattern changed the behaviour of another part.** ⚠ **Every check they ran passed** — entry
  counts, table-row counts, byte-identity of all 33 entries against the live corpus, the secret scan,
  the identity gate — **and not one asked whether the rest of the file still existed.** ⭐ **The blind
  spot is in the CHECK SET, not the edit method**: the counted `n == 1` guard above makes their exact
  mechanism unlikely here, and would not have noticed the loss either. **Cheap forms: a line or byte
  count that can only GROW across an additive pass, or a section-heading list compared before and
  after, per file.** ⭐ **Their fix is the durable half — GENERATE THE FILE IN FULL RATHER THAN PATCH
  IT IN PLACE**, which removes the failure mode instead of guarding it. ⛔ **SCOPED 2026-08-23, THE
  SAME DAY — THAT EXEMPTS A PROGRAMMATIC GENERATOR AND *INVERTS* THE RISK FOR AN AUTHORED REWRITE,
  AND THE UNQUALIFIED SENTENCE ABOVE READ AS COVERING BOTH** (`CORRECTIONS.md` 2026-08-23). A
  generator cannot silently drop a section it is responsible for emitting; **an authored rewrite is
  responsible for emitting whatever its author happens to remember**, which is a WEAKER guarantee,
  not a stronger one. **Run the guard against the prior artefact regardless of how the new one was
  produced.** ⚠ **How it was found is the part worth keeping: an unrelated verification probe
  returned 0 where 1 was expected. The claim they
  were checking was TRUE — checking it is what surfaced the damage** — which is *predict, then
  measure* paying out on a question it was not aimed at.
  ⛔ **SAME FAMILY, SECOND RELAYED INSTANCE: `sort -u` RUN ON A `.gitignore`** whose comments carried
  the reasoning for each rule, **including the device-identity rule written after a repository had to
  be deleted and recreated.** **The patterns still functioned; the document was destroyed.**
  ⭐ *Right tool, wrong subject — `sort -u` is correct on a list of patterns and destructive on a
  document that happens to contain one.* ⚠ **This box is exposed the same way**: `.gitignore` is the
  file §*Safety* above sends you to `grep '^!docs/'` for, i.e. it is load-bearing **as a document**.
  **Never run a whole-file transform on a file that is also prose.**
  ⭐ **THE USABLE FORM IS A PROMPT TO READ, NOT A PASS/FAIL GATE.** The signal is not *"nothing was
  dropped"*, it is ***"here is what was dropped — do you recognise it?"*** Any legitimate edit that
  moves or condenses text trips it, so ⛔ **do not tune it until it stops firing — a conservation
  check that never fires is untested**, and suppressing it turns it back into a check that runs,
  looks clean and measures nothing. ⛔ **A pass/fail gate invites reasoning that is TRUE AND FATAL:
  *a from-scratch rewrite is supposed to drop things*.** ⚠ **RELAYED, the peer's half:** a probe over
  dropped text that finds nothing is the same false comfort as any other silent pass, **and it fails
  in the direction that feels like good news** — a keyword match asks *does this contain a token*,
  reading asks *what was this for*, and **the second cannot degrade gracefully into the first**.
  ⛔ **AND THE DROPPED LIST IS EVIDENCE, NOT A VERDICT — RESOLVE EVERY ENTRY BY READING THE NAMED
  ITEM BACK OUT OF THE NEW ARTEFACT, NEVER BY JUDGING THE DIFF. Measured on-device 2026-08-23, twice
  in one night, by two different actors.** The check is **line-scoped** and this corpus is
  **hard-wrapped**, so **moving a line boundary re-emits an item that is entirely intact**: a
  `REGRESSION.md` Q95(c) edit reported **3** dropped lines and the third was sub-item **(d)**,
  untouched, which had merely shared a line with the end of old (c). ⛔ **A quarter of the question
  going missing and a re-wrap produce THE SAME OUTPUT — severity is not in the diff.** It was settled
  by reading (a)–(d) back **by name**, all four present. **Same root cause as `REGRESSION.md`
  §*Method*'s whitespace-normalisation clause: a line-scoped instrument on hard-wrapped prose.**
  ⚠ **Two false positives in one night is exactly the pressure *do not tune it until it stops firing*
  forbids acting on** — the resolution is per entry and by reading, never a threshold.
  ⛔ **COPY THE PRIOR ARTEFACT SOMEWHERE DURABLE *BEFORE* A FROM-SCRATCH REWRITE — WITHOUT IT THE
  RULE IS NOT SKIPPED, IT IS UNENFORCEABLE BY CONSTRUCTION**, because the artefact it would compare
  against no longer exists anywhere. Cost: one `cp`. ⚠ **The snapshot bullet at the head of this
  section does not reach it** — that governs writes made by the CURATOR, and the file most likely to
  be rewritten from scratch is rewritten by an ordinary session, which nothing routes through it.
  ✅ **ON-DEVICE INSTANCE, 2026-08-23 — the rule above is RELAYED; this is MEASURED here.** Applied
  to the `/root/docs/HANDOFF.md` from-scratch overwrite: **441 → 198 lines, 10 → 9 `##` headings, six
  sections dropped** (a dated measurement — the file has been appended to since; the pre-overwrite
  copy is `/root/tools/backups/HANDOFF-pre-v7-close-2026-08-23.md`). Five were retellings that had
  since landed in T1. **The sixth was `### ⛔ 568 is NOT a fixable bug — it is a feature
  incompatibility. OPERATOR DECISION OWED.`** — it resolved benignly, the decision **had** been taken
  (Option A, `CONFIG_KPROBES` dropped at the v6 build, absent on v7), **but only because someone went
  and looked.** ⭐ **It is the strongest case for the rule precisely because it looks like the weakest:
  `HANDOFF.md` is overwritten from scratch by design, is local-only and is in NEITHER mirror — so it
  is at once the file where the check feels most redundant and the file where nothing would ever have
  noticed the loss.** The backup existed **before** the overwrite, which is the only reason the
  comparison was runnable at all.
- **Propose, then apply.** The curator returns a diff summary; the operator approves. Only the
  `/curate apply` path writes.
- After any T0 rewrite, re-run `REGRESSION.md`. Every question must still be answerable from T0
  plus one pointer hop. An unanswerable question blocks the change.
