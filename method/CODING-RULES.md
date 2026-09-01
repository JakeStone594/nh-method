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

**A DIAGNOSTIC THAT CANNOT SEPARATE TWO CAUSES MUST NOT LEAD WITH ONE OF THEM.** Added
2026-08-23. A message like `Wrong passphrase, or parameters differ` reads as a ranking,
and a reader acts on the first cause named. ⛔ **It fails toward the cause the reader can
act on alone and blame themselves for**: *wrong password* invites a retype, *wrong
parameters* invites asking the other party — so naming the self-blaming cause first
steers away from the answer. The instance cost a cross-machine session: the message was
relayed onward as a finding, because it read as one.

**The fix is refusing to rank, not better wording.** If the tool cannot distinguish, it
says so and lists the causes as equals, with the probe that would separate them — that is
the *choice the operator has to make* the test above asks for. ⛔ **A cause you cannot
distinguish must also not be ADDED to the list**: a differential is only as good as its
weakest member, and a plausible extra entry sends the reader down a branch that does not
exist. The estate already does this where it was forced to — `vpnleak` prints
`<N packages share this uid>` rather than guessing a package — and the same principle is
already binding one tier up, on test verdicts, as *INCONCLUSIVE must never be rounded to
FAIL* (`method/TOOL-TEST-METHOD.md`). This clause is that rule applied to what a tool
PRINTS, which nothing covered until now.

**A SUCCESSFUL RUN ENDS ON ITS VERDICT, NOT ON A MENU — OPERATOR DECISION 2026-08-24.** A
command belongs under a failure it remedies. Where to go next is `nh`'s job, and a tool that
answers it as well is a second index, which drifts.

⛔ **Why this is a separate clause and not a restatement of the test above: THE TEST PASSES A
MENU.** Every line of a suggested-next-command block carries a command — one of the three things
the per-sentence test asks for — so the contract as written never forbade it. *"Four successive
cleanup passes removed nothing, because every one of them passed the useful test"* was about to
happen again one level up, this time to output that passes the **stricter** test too.

**The instance, stated for the shape rather than the tool.** A bring-up ended on three bare
commands. The operator's first report read as *these commands are unlabelled*, so a label line
was ADDED to each — three lines became six. The operator came back. ⛔ **The fix was REMOVAL.
Answering feedback about too much output with more output is the shape to recognise**, and it is
the one that feels like compliance while it is happening.

✅ **Scope limit, tested and held: a command printed directly under a `[FAIL]`/`[warn]` as the
remedy for THAT failure is correct and stays** — this rule already requires it (*"An error says
what failed and what to type next"*). The objection is to an **unprompted menu on a SUCCESS
path**, and nothing wider. A clause read wider than that strips the remedies, which is the
opposite of what it is for. T2 `nh-is-the-operator-entry-point` holds the operator's words, the
escalation and the verified scope limit. *(Recorded by the curator from the session that
received the feedback; the curator did not witness the exchange.)*

## 5. Nothing in the tool that is not the tool's job

No text-wrapping engine, no design document, no test register, no defect list, no
version history, no self-explanation. If it is not on the tool's one-line job
description, it is not in the tool.

**SCOPE — OPERATOR DECISION 2026-08-24: "no text-wrapping engine" does not reach the
laying-out of a screen this contract MANDATES.** The question was put as a normative one and
answered *"keep the awk, it's fine"*. What it settles: a bash tool may carry the minimum
word-wrap needed to render its own `--help` at the terminal's width, and that is not a rule-5
breach. The reading behind it — this rule's list (design documents, defect registers, version
history, self-explanation) names things that are not the tool's job at all, whereas a help
screen is required by rule 3 and content-derived widths by the cross-tool conventions below,
so the minimum implementation of a MANDATED behaviour is not what this rule targets. A Python
tool has `textwrap` and writes nothing; bash has no stdlib, so the wrap is written or the
convention is broken.

⚠ **`androute` had already done it, and predates the ruling.** `_AWKLIB`'s `emit()` is a greedy
word-wrap driving `die`, `info`, the markers and `_banner`; `_cols()` takes the width once;
`_rows()` derives the label column from the longest label **present** and **stacks** the rows
rather than overflowing when the terminal is too narrow; and `_cmd()` is exempt by design,
carrying its reason in one line — *"a command is NEVER wrapped: it must stay pasteable"*. So the
estate now has two independent implementations, and `TOOL-BACKLOG.md` `G-1` records that the
terminal-width probe stayed per-tool by decision.

⛔ **NOT settled by this, and do not read it as settled:** whether the exemption extends past a
help screen to runtime output, and whether the two implementations should merge into
`common.sh`. ⚠ **No timing is quoted here on purpose** — the ruling is a decision, not a
conclusion drawn from a measurement, and attaching the numbers it was made beside would make it
look refutable by a faster or slower implementation (T2 `preference-is-not-a-conclusion`); they
are in the commit that made the change. *(Recorded by the curator from the session that put the
normative question to the operator; the curator did not witness the exchange.)*

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
`diagcap` is the strongest form of the same idea — its restore is the **kernel's**, fired when the
fd closes, so it survives `kill -9` outright.

**A DESTRUCTIVE TOOL'S DEFAULT MUST BE INERT, AND THE INERTNESS MUST BE TESTED WITH SOMETHING
ELIGIBLE PRESENT.** Relayed from the laptop peer 2026-08-23, from a retention script whose dry-run
guard **errored** instead of returning — so execution fell **through** into the delete branch. ⛔ **A
guard that errors does not fail closed, it fails ONWARD**, which is a different defect from a guard
that evaluates wrongly: it is a guard that never ran. ⚠ **And it was invisible in the normal case** —
the directory had nothing eligible, so the fall-through printed a completion message and deleted
nothing. **The script would have looked correct indefinitely and been wrong the first time it had
something to delete.**
⭐ **So a dry run over a directory where nothing qualifies proves NOTHING**: *"nothing to prune"* and
*"the DROP list never populates"* are the same output. The test is a **synthetic directory with
eligible items in it**, asserting the tool identifies them and still removes nothing. ⚠ **The
estate has no pruner today** — retention here is enforced by whoever runs the tool — so this rule
arrives before the tool exists, which is the only time this class is cheap.
⚠ **Do not carry the peer's original mechanism**: they first reported an empty array breaking
`${#X[@]}` under `set -u`; re-tested on bash 5.3.9 both sides, that does **not** reproduce, and the
real trigger was `declare -a X` leaving the variable genuinely unset. **A wrong reason in a safety
note is worse than no note** — the next reader guards the wrong pattern.

**Undo what you did, not what is there — and let the filesystem enforce it.** To remove a
directory your run created, `rmdir` it, not `rm -r`: `rmdir` **refuses** if anything else
appeared inside, which is exactly the difference between removing what you made and
removing whatever is there. The estate already reasons this way one level up — `diagcap
--delete-on-exit` removes only a run dir the run itself created, and every journalled
teardown here replays its own records rather than flushing state wholesale. ⚠ **A failure
from `rmdir` is information, not an obstacle: something you did not put there is in a
directory you were about to delete.**

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

**The absence of one known failure signature is not a success check.** A verdict needs a positive
observable that the thing RAN, and a separate one that it SUCCEEDED — they answer different
questions, and the second alone passes every failure you did not think of. `bin/android-browser` in
this repository scored on *"no `Error:` line"* and printed `[ ok ] opened on the Android side` on an
**empty** output and on a helper binary that could not link, having done nothing at all; fixed
2026-09-01 to require `Starting: Intent` **and** no `Error:` — the first proves the command ran, the
second that the intent resolved. ⚠ **The empty-output head is universal, not a property of one
rootfs**: `grep -c '^Error:'` on an empty string returns `0` and the success branch is taken.
⛔ **That is `LYING-PROBES.md` sub-family (a) — *treat empty as a third branch* — firing inside a tool
shipped in the same repository as the document that warns about it**, which is the strongest argument
that the rule belongs in the authoring contract and not only in the catalogue.
⚠ **The other head does not generalise and is worth separating: `[ -x <binary> ]` passes on an ELF
whose interpreter is missing**, so a preflight cannot tell an unlinkable binary from a healthy one,
and **neither the shell's message text nor its exit status distinguishes the two** — the wording
varies by shell *and* by failure type, and a bad interpreter and a genuinely missing file share an
exit code on most shells. **Read the interpreter out of the ELF (`readelf -l`) and test that path.**
✅ **Both arms of that fix are exercised, on two different machines** — the success arm against a live
Android, the failure arm against a real missing interpreter on another handset, which ran the tool at
`d923e5d` and got the correct verdict, `rc 1`, with the raw error above the hint. ⚠ **Neither arm was
reachable from the other's machine**, which is the general point: a verdict with two independent
observables usually needs two environments to prove, and a tool tested only where it works has tested
one branch.

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

**Whether a guard may REFUSE is decided by who calls the function, not by how serious the
condition is.** A `die` is correct in a function reached only from the dispatcher. It is wrong in
one reached from a trap: there the function *is* the rollback, and refusing aborts the cleanup the
failure created. Same condition, same severity, opposite correct behaviour — so the question is
never *how bad is this?* but **what does not run if I exit here?**

The estate carries both shapes. `lanmitm do_down` is reached only from its dispatcher and has
nothing after the chain block, so it refuses outright. `rogueap do_down` is reached from the `EXIT`
trap via `up_exit_guard` — it is the rollback path for a bring-up that failed half-way — so it
warns, records a flag, and lets the AP-vif delete, the `con_mode` restore and the Android Wi-Fi
re-enable all run, reading the flag only after the last of them. A `die` there strands a radio in
monitor mode, which is the state the tool exists to prevent.

**A TOOL THAT RESOLVES ITS DATA PATHS AGAINST ITS OWN INSTALL DIRECTORY NEEDS A PRIVATE PER-RUN
COPY, OR YOUR RUN READS AND WRITES THE SYSTEM'S FILES.** Three independent instances in one session
(2026-08-24), each a different mechanism and each silent: Responder resolves config, `Responder.db`,
`logs/` and `certs/` from `os.path.dirname(__file__)` (`settings.py:31`) and has **no `--config`
flag** (verified on-device 2026-08-25 from `--help`); `download-autopwn.js:52` **hardcodes**
`/usr/share/bettercap/caplets/download-autopwn/` for its payload reads, one level below where a
wrapper's own validation looks; and `hstshijack.js` **writes learned state back** into the
`dpkg`-owned tree (`saveSSLIndex()` :177-178, `saveWhitelist()` :183). ⛔ **A SYMLINK FARM IS NOT A
PRIVATE TREE, AND IT FAILS TOWARD THE DANGEROUS SIDE** — Python resolves `sys.path[0]` through the
symlink, so the imported module's `__file__` is the real path; the tell is that it **starts
normally**. Copy real files, and prove it with a **negative control**: set something in the private
config that the banner echoes, and check an untouched neighbour still reads the old value.
⚠ **And WRITE the copied config, never copy-then-edit** — `/usr/share/responder/Responder.conf` is a
symlink into `/etc/responder/`, where a `sed -i` happens to break the link instead of following it,
so the approach appears to work while `--follow-symlinks` or a `>` redirect would have edited the
system config. Instances and the per-tool detail: `docs/TOOLS.md` §`authcatch` and §`lanmitm`.

**Validate an argument where it is PARSED, not where it is consumed.** A guard on the consuming
call site fires only if that site is reached, and an unrelated flag can route around it:
`wificonnect`'s `--band` was checked inside `band_freqs`, which `--freq` and `--channel` both
short-circuit, so `--band 6 --channel 5` reached no guard at all and produced a 2.4 GHz frequency.
Validate once, early, by calling the one definition that already knows the accepted values — never
by writing a second list of them beside the parser.

⚠ **A `die` inside `$( )` exits the SUBSHELL.** A helper whose refusal is only ever reached through
command substitution refuses nothing: the message prints, the assignment yields empty, and the
caller continues. Either guard the call site (`x=$(helper) || exit 1`) or call the helper directly
where its exit is meant to be the program's.

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
