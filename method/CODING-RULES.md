# Coding rules — /usr/local/bin

Replaces the deleted `BUILDING-TOOLS.md`. If a rule is not here, it is not a rule.

## Making something normative is a decision

Extraction describes practice; it cannot create a rule. A clause binds only after the
operator has seen it.

Before writing "I extracted / documented / wrote down existing practice", check whether
the output will bind future work. If it will, it is a proposal — it goes to the operator
first.

## 1. Code contains code

A comment says why a non-obvious line exists. One line, present tense.

Never in a source file: dates · version names (`1.x`, `2.0`) · "this used to" · defect,
test or clause ids · measurements · what was probed, verified or reproduced · what a
session established · anything addressed to a future maintainer as narrative.

If a comment is longer than the code it explains, it is documentation. Move it.

## 2. Everything else already has a home. Put it there.

| What you want to write | Where it goes |
|---|---|
| how to run it, what it costs | `--help` — one screen |
| why it works this way, hazards, background | `docs/TOOLS.md` |
| what changed and why | the git commit message |
| what a test measured | `docs/TOOL-TEST-RESULTS.md` |
| what is broken or missing | `docs/TOOL-BACKLOG.md` |
| what happened this session | nowhere — it is in the transcript |
| what the tool did at runtime, if it must be kept | a log file the tool writes |

Writing it in the source does not make it more likely to be read. It makes the code
less likely to be read.

## 3. One help screen

No `--help-full`, no `--help-extended`, no second screen under any name. `--help` is:
usage, options, what it costs, exit codes. Nothing else.

If it does not fit one screen, either the tool has too many flags or the help has a
README in it. Both are the tool's problem, not the screen's.

## 4. Output is for acting on

Print what the operator must decide or do. Not what the tool is doing, not what it
verified, not what it decided not to do. An error says what failed and what to type next.

**The test, per sentence: it must carry a command, a value, or a choice the operator
has to make. If it carries none of the three, it is not output.** Applied to a message
that already looks reasonable, this is what it removes:

    not flushing wlan0 — the association is not ours; undoing only what is journalled
    refusing to run DHCP on it. A renew on somebody else's association takes a second
      lease and leaves an address nothing will clean up. Use 'wificonnect connect' ...
    $IFACE is type '__ap', not managed. rogueap leaves '__ap', hcxdumptool leaves
      'monitor'. Recover with: ...

Each keeps its first clause and its command, and loses the mechanism. The mechanism was
true, useful, and belongs in `docs/TOOLS.md`. "It is useful" is not the test — four
passes over one tool's output failed to catch these, because every one of them passed it.

Runtime output is not a record. If a record is needed, write a log file.

## 5. Nothing in the tool that is not the tool's job

No text-wrapping engine, no design document, no test register, no defect list, no
version history, no self-explanation. If it is not on the tool's one-line job
description, it is not in the tool.

## 6. The working version is the specification

When changing a script that works, every added line is itemised with a one-line reason
and can be removed on its own. A line never goes in because a rule "requires" it —
if a rule is producing lines nobody asked for, the rule is wrong. Say so instead.

## 7. Deleting is normal

Nothing is kept so that nothing is lost. git has the old version. A rewrite that only
adds is not a rewrite.

## 8. Safety is behaviour, not text

A tool that changes global state puts it back — on error, on Ctrl-C, on SIGTERM. That
is a trap and a restore function, not a paragraph about a teardown contract.

**No trap covers `SIGKILL`, so do the slow work BEFORE you arm.** A restore reached from
`EXIT`/`INT`/`TERM` is skipped entirely by `kill -9`, and the thing most likely to earn a hard kill
is a probe that hangs. `vpnleak` nearly demonstrated it on 2026-08-19: resolving the VPN app with
`for fd in /proc/[0-9]*/fd/*; do readlink "$fd"; done` forks once per descriptor — tens of thousands
— and did **not return in 2 minutes**; the run was SIGKILLed and nothing was left behind **only
because the kill landed before the chain was armed**. `find /proc/[0-9]*/fd -lname '/dev/tun*'` does
the same work in **0.17 s** (curator-measured 2026-08-19). Two rules fall out, and the second is the
durable one: **a per-file fork inside a `/proc` glob is a hang, not a slow loop** — push the
predicate into `find`; and **order the tool so every resolution, validation and probe finishes
before the first state change**, leaving the armed window as short as the work truly requires.
The strongest form of the same idea is a restore that is the **kernel's**, fired when the descriptor
closes — that one survives `kill -9` outright.

Verify a change by reading the state back, and only when getting it wrong is dangerous.
Say nothing when it worked.

**Report the achieved state, not the requested one.** A success line names a value read
back from the world — the frequency the radio reached, the route a reply resolves out of,
the link state after the restore. If the only source for a printed value is the argument
that asked for it, do not print it as a result. Where the read-back is free, it is not
optional: `hostapd_cli status` already returns `freq`/`channel` beside the `state=` the
tool was fetching anyway.

Before printing a success line, ask whether the value came from the world or from your own
argv. This is the mirror of the test method's *never count a value the tool under test
wrote* — that protects the tester; this protects the operator, who has nothing but the
output.

**A printed reason names the failure prevented, not the symptom of the day.** A guard's test
stays correct while the reason it prints is falsified by a change to the box, and nothing
mechanical catches that: `bash -n` passes, the guard fires on the right condition, the tool
behaves. Only someone reading the message notices.

An understated reason argues for the guard's own removal. `lanmitm` `do_prep()` refused with
*"nft cannot even read here"*; once the kernel shipped `CONFIG_NF_TABLES`, a reader hits that
refusal, runs `nft list ruleset`, sees it work, and reasonably concludes the guard is stale. It
is not — the failure it prevents is that nft writes a separate ruleset netd cannot see, which is
worse than a read failure, not better. That is what it says now. `rogueap`'s `iptables_legacy`
preflight prints the condition with no reason attached and rotted not at all: a reason is a
liability that has to be maintained, and naming the durable failure is what makes it survive.
Attaching none is the other safe option.

Applying it: when a precondition changes, audit the reasons guards print, not only the
conditions they test — and grep the superseded reason phrase, not the subject. Instances:
memory `guard-reasons-rot`; the `lanmitm` backend-guard entry in `docs/CORRECTIONS.md`.

## What "safe" costs, for reference

`hcxcapture` restores the radio on every exit path, drops and restores Android's Wi-Fi,
refuses a vif it cannot arm, and verifies both directions — in 58 lines on top of a
201-line script that did none of it.

## Checks before committing

    grep -nE '20[0-9]{2}-[0-9]{2}-[0-9]{2}|\b[12]\.[0-9x]\b|used to|help-full' <file>
    awk 'END{print NR}' <file>            # bigger than last time? justify each line
    comments ÷ lines                      # over ~15% means rule 1 or 2 is being broken


---

# The cross-tool conventions — moved here from T0 on 2026-08-16

⛔ **These are AUTHORING rules: they bind whoever writes or edits a tool, and a session that is only
*using* the tools never needs them.** That is why they live here rather than in `/root/CLAUDE.md`,
which loads in full at every session start. They were moved **verbatim**, by operator decision,
because T0 had passed its ceiling and this was the largest block in it that failed the
action-changing test for a reader who is not writing code.

⚠ **Three conventions did NOT move and are still in T0**, because they change what a *caller* does:
global flags parsing on either side of the verb, `nh` being the index, and the **exit-code scheme
with its two grandfathered exceptions** (`hcxcapture` and `btinject check`), which a caller will
misread as failure if they apply the house rule.

- ⛔ **`--help-full` IS FORBIDDEN, NOT A CONVENTION — `CODING-RULES.md` rule 3: one help screen,
  no second screen under any name.** Every tool that had one now REJECTS the flag with rc 1 and
  *"there is one help screen"*, so **the live risk is re-introduction, not debt** — do not add one
  back because the surrounding estate once had them. ⛔ **A bare `grep -rl -- '--help-full'` is NOT
  the probe** — it hits every tool that *rejects* the flag, which is exactly the shape a stripped
  tool leaves behind, so it counts **progress** as **debt** and reads as full debt at zero debt:

  ```bash
  for f in /usr/local/bin/*; do grep -q -- '--help-full' "$f" &&
    ! grep -q 'there is one help screen' "$f" && echo "$f"; done   # must print nothing
  ```

  **Where a rebuilt tool's design notes, hazards and background
  went: `/root/docs/TOOLS.md`** — that is `CODING-RULES.md` rule 2's table, and it is the place to
  look before concluding something was deleted.
- ⛔ **OUTPUT IS TESTED PER SENTENCE — it must carry a command, a value, or a choice the
  operator has to make. If it carries none of the three, it is not output.** ⚠ **"It is
  useful" is not the test**, and that is the failure mode rather than a nicety: four successive
  cleanup passes over one tool's output removed nothing, because every line passed the "useful"
  test. What the test strips is usually true and usually the *mechanism* — it is not lost, it
  goes to `docs/TOOLS.md` (rule 2's table). `CODING-RULES.md` rule 4 shows three real messages
  and what survives the cut.
- **Output renders at the TERMINAL'S width, and column widths are DERIVED from content.** Do not
  reintroduce a literal column count or a hand-wrapped paragraph — an author-broken paragraph is
  a hardcoded width with extra steps, and it can neither narrow nor widen. ⚠ In bash, take the
  width ONCE at load: `tput cols` reads the winsize from **stdin** (`PRECONDITIONS.md` P-51).
  ⛔ **And a MINIMUM-WIDTH FLOOR is a hardcoded column count wearing a guard's uniform** — it
  cannot make a narrow terminal wider, it only lays out past the screen edge and the terminal then
  wraps at column 0, destroying the alignment of everything below. **Indent gives way; the width
  never does.** ⚠ **A help screen must follow the terminal even when PIPED** (`--help | less` on a
  phone is the common case): `shutil.get_terminal_size()` reads **stdout only**, so fall back
  stdout → stderr → **`/dev/tty`** → `$COLUMNS`. Archived *runtime* output is the opposite — a
  fixed width, returned before anything else is consulted, so `$COLUMNS` cannot make a `| tee`'d
  capture terminal-dependent. Both rebuilt 2026-08-12; detail in `/root/docs/TOOLS.md` §`usbgadget`.
- **Status markers `[ ok ]` / `[warn]` / `[FAIL]`** are equal width, so output columns align.
- ⛔ **NO HISTORY IN A TOOL — not in the output, not in the source.** Operator instruction,
  2026-08-12, raised across two sessions: no dates, defect ids, "this was X until Y", measurements
  of past bugs or session changelog in code, comments, docstrings or runtime output; present-tense
  documentation only. ⚠ **The existing corpus is written in exactly that style, so matching the
  surrounding file is NOT a reason to add more of it.** History belongs in the git commit message,
  `TOOL-BACKLOG.md`, `TOOL-TEST-RESULTS.md`, `CORRECTIONS.md`. (`CODING-RULES.md` rules 1-2;
  T2 `no-narrative-in-tool-source`.)
- ⛔ **A LINE NEVER GOES IN BECAUSE A RULE "REQUIRES" IT — if a rule is producing lines nobody
  asked for, the rule is wrong. Say so instead.** (`CODING-RULES.md` rule 6: the working version
  is the specification.) It is the only clause in the contract that licenses **refusing** a rule
  rather than complying into bloat, and it exists because the predecessor contract had no such
  escape — it charged ceremony per mutated piece of state and forbade deletion, so every review
  pass could only add, and every review pass grew the tools it governed. Measurements:
  `docs/CORRECTIONS.md` 2026-08-13.
