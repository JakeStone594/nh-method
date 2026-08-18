# TOOL-TEST-METHOD.md — how to run a live test campaign against a tool on this box

**T1. Written 2026-08-10** by generalising `/root/docs/TOOL-TEST-RESULTS.md`, which was authored
2026-08-09 for five rewritten wrappers and executed through Stage 2 on 2026-08-10. **That file is an
instance; this one is the method.** It contains no device state, no test ids and no results — only
the shape a campaign takes and the rules that make its results mean something.

✅ **Citations here are to BT clause ids and to section names, not to `/root/CLAUDE.md` line numbers.**
This file therefore does not rot with T0. Where a device fact is needed, it is named, never quoted.

**Related:** `/root/docs/CODING-RULES.md` (the authoring contract — a campaign tests conformance to
it) · `/root/docs/PRECONDITIONS.md` (the probes that lie — a campaign's pass criteria must not rest on
one) · `/root/docs/TOOL-TEST-RESULTS.md` (instance #1, live).

---

## 1. When a tool needs a campaign at all

**BT-0.5 is the trigger:** a tool whose write path touches iptables, `ip rule`, `con_mode`, the USB
gadget, a radio, or an Android HAL is **stranding-class** and reaches lifecycle state L3 only through
numbered tests with logged diffs.

Everything else can live at L2 (field-executed) indefinitely and honestly, provided the census in
this file's own instance register says so. **The failure mode this file exists to prevent is not "an untested
tool" — it is "a tool everyone believes is tested".**

A campaign is worth its cost when at least one of these is true:

- the tool's teardown is its product (BT-4.1), so only a diff can show whether it works;
- a failure would strand the operator — no shell, no radio, no USB;
- the tool encodes a claim about the device that nobody has measured;
- a rewrite landed and the no-regression argument is currently an assertion (BT-0.7, BT-0.8).

---

## 2. Artefacts, and where they live

| artefact | path | lifetime |
|---|---|---|
| **the campaign file** | ⛔ `/root/docs/tests/<tool>-CAMPAIGN.md` — **THE WHOLE DIRECTORY WAS DELETED 2026-08-12** | archived, see the banner |
| **the results log** | §6 *inside* the campaign file | permanent; append-only |
| **snapshots and diffs** | a dated dir outside `/usr/local/bin` | permanent |
| **the rollback copy** | `/root/tools/backups/tool-backups-<date>/<tool>.pre-<testid>-fix-<date>` | permanent (BT-0.6) |
| **per-test artefacts** | one dir per campaign, `*-VERDICT.txt` per test | permanent |

**Test ids** are `<TOOL-INITIALS>-<n>` and never change meaning. A test that is re-scoped gets a new
id; a test that is dropped is struck through with a reason, never deleted.

**The UNVERIFIED register — owned by this file since 2026-08-12.** Every open question names the
**exact command that would settle it**. A settled row is retired in place with its answer; a
half-settled one keeps `◐`; an untestable one is admitted as such. Prove falsifiably — flip a value
rather than rewriting it, so a silent failure cannot be mistaken for success by reading back a stale
read. ⚠ This was `CODING-RULES.md` BT-8.5, which required the register to live **in the tool's
header**, and argparse then served that header as `--help`. The register is campaign machinery: it
belongs **here, and in no tool at all** — ⚠ **this line prescribed `--help-full` until 2026-08-14**,
which `CODING-RULES.md` rule 3 forbids and the estate no longer has (old wording in
`/root/docs/CORRECTIONS.md`).

**Register ids** (`U-n`, `V-n`, `RA-n`, …) are the tool's own UNVERIFIED register. Every test
that settles one names it, so closing an open question afterwards is a mechanical edit rather than an
archaeology exercise.

---

## 3. Before you start

⛔ **SETTLE BEFORE YOU SNAPSHOT A TEARDOWN.** An interface whose type was just changed bounces its
link, so a snapshot taken in the same breath as the teardown records a **transient** value. Measured:
a post-teardown snapshot recorded an interface DOWN — matching the baseline, all diffs IDENTICAL, a
clean pass — while the interface was UP at that instant and stayed UP. **Every other snapshot trap in
this document manufactures a false FAIL, which is self-correcting because someone investigates. This
one manufactures a false PASS and hides the defect, which nothing corrects.** Wait for the state to
settle, sample it more than once, and prefer `/sys/class/net/<if>/operstate` to `ip -br addr` for
link state.

### 3.1 Physical kit

List it, and list what makes each item *silently* unjudgeable if it is wrong — that is the part
operators skip. Generic entries that apply to any campaign here:

⛔ **ASK THE OPERATOR TO SET UP ANYTHING ON THIS LIST THAT IS NOT ALREADY IN PLACE, IN THE SAME
MESSAGE THAT PRESENTS THE PLAN.** Do not defer a campaign to a later session, do not silently take
the arm that avoids the missing item, and never record it as *"blocked on hardware"* — the operator
is present and most of these take seconds. A deferred campaign does not resume unchanged: its
criteria go stale against a tool that keeps moving.

- **A data-capable cable**, for anything USB. A charge-only cable makes every host test unjudgeable
  and the tell is a UDC that never leaves `not attached` (P-33).
- **A host you own**, already authorised, with the specific tooling the arbiter needs. Name the
  reference implementation: if a layout table was press-tested against one keymap stack, that stack is
  the matched arbiter and any other host is a second-tier result.
- **A powered hub** for any adapter near the port's current ceiling (P-34).
- **A second client you own, MAC noted in advance** — so a bystander association is instantly
  distinguishable from your own device.
- **A second on-device terminal** for anything that can drop the network. A network-attached shell
  dies with the interface it rides on.
- **Power.** Long runs thermally throttle; a campaign that stalls at 60% is not a result.

### 3.2 Snapshot before anything

Take the rollback copy **first** and confirm it by listing the directory (BT-0.6). Per-stage snapshots
belong inside the test blocks, not in a preamble — and the rule that makes them worth taking:

> **The diff IS the pass criterion for every teardown test.**

If a tool has no `.orig` and the rewrite already landed, rescue a pre-change copy from file history
before running anything. A campaign against a tool with no rollback point is not a campaign; it is an
experiment you cannot undo.

### 3.3 The stranding checklist

Fill this in **before Stage 0**, not after a test goes wrong:

| if this drops | what still reaches the device | verified how |
|---|---|---|
| the primary shell transport | … | … |
| the network | … | … |
| both | the phone's screen — and you must know where the relevant Android toggle is *without looking* | … |

Then answer the three questions that decide recovery, because they differ per subsystem and are
**not** in the tool headers:

1. **Which state survives a reboot?** Persisted Android globals do. A test that leaves one at 0 boots
   the phone back into that state, so **a reboot is not recovery** — the GUI is.
2. **Which state is boot-scoped?** configfs, `con_mode`, chains, ip rules, vifs, daemons, and any
   journal gated on `boot_id` (BT-4.12). For these a reboot **is** the guaranteed path.
3. **Which state is irreversible until a reboot?** Function instances that nothing ever `rmdir`s
   (BT-4.16). Tests touching those can only be run once per boot — mark them.

### 3.4 The Recovery Verification Block

Write one RVB per campaign: a short, read-only block that asserts the device is back to baseline.
Every line is a probe, every expectation is stated, and it must cover *each* subsystem the campaign
touches — radio mode, interface type, addressing, the persisted globals, routing, the tool's own
chains and rules, and any daemon it starts.

**Two rules, and they are the whole point:**

> **Do not start the next test until the RVB is clean.**
> **Two stranding tests must never run back-to-back.**

### 3.4.1 When the test breaks its own transport. Added 2026-08-15, from `T10`

Some tests take away the link the tester is running over. `T10` took `wlan0`, **the phone's only
data path**, so the test would have killed the agent running it. The pattern that made it safe,
worth reusing for any test in that position:

⭐ **Run detached with an unconditional restore `trap`, plus a separate detached watchdog armed
BEFORE the first destructive step** that force-restores on a deadline. Both fired correctly; the
phone came back to `con_mode=0`, `wifi_on=1`, `wlan0` reassociated, no residue.

**Two independent mechanisms, and the second is the point.** A trap only runs if the process
survives to run it; the watchdog is what covers the case where it does not. **Arm the watchdog
before the first destructive step, not after** — a watchdog armed afterwards protects nothing
during the window it exists for.

⚠ **Cellular failover is NOT a fallback you can plan on, and it is UNVERIFIABLE BEFOREHAND.** It
did work mid-test (`8.8.8.8 via … dev rmnet_data0`) once mobile data was enabled — but
`rmnet_data0` **stays DOWN with no address until Wi-Fi actually goes away** (re-confirmed by the
curator 2026-08-15: `ip -br link show rmnet_data0` reads `DOWN` with no address while Wi-Fi is up).
So you cannot prove the fallback before you need it, and a stranding-checklist row asserting it is
a guess. **Do not bet on it; make it irrelevant.**

### 3.5 Standing rules to restate in every campaign

These are cheap to restate and expensive to rediscover. Cite the clause; do not re-derive:

- **Never `pkill -f` / `pgrep -f`** — the pattern matches your own `argv` (BT-6.1, P-01). **And never
  `pkill -x wpa_supplicant`**, where the safe default inverts (BT-6.2, P-02).
- **Run every snippet under `bash`, not the interactive shell.** zsh does not word-split unquoted
  expansions, so a pasted loop runs once with the whole list as one value — silently, with
  plausible-looking output (N-10, BT-9.5). This was added to instance #1 *after* it corrupted a
  9-payload test into converting 0 while printing a bogus match.
- **Never run a compose or restore from a shell the tool will kill** — a tool that stops the transport
  it is running over strands itself mid-plan.
- **Never `iptables -F` or `iptables-restore`** wholesale (BT-4.20, P-14).
- **Record pre-existing residue before Stage 0**, and decide deliberately whether to sweep it or
  expect it in every diff. **Sweeping is itself a write** — do it before, never mid-campaign.

---

## 4. Ordering — the rules, not the sequence

The stage order in an instance file is derived; these are the rules it is derived *from*. Sort by
these in order:

1. **Everything read-only and `--dry-run` first, in one sweep.** It costs nothing, and some results
   *change how later tests are judged* — a calibration, a gate, or a regression check that would
   invalidate every later result for that tool.
2. **Separate subsystems whose failures look alike.** USB and radio failures are indistinguishable
   from a terminal; interleaving them means one gets blamed for the other.
3. **Within a subsystem: cheapest recovery first.** Cable out before cable in. Nothing observing
   before something observing.
4. **Dependencies before dependents**, and say so explicitly: if tool B has no wire until tool A
   composes one, A's test *is* B's precondition. Where two ids denote the same execution, say
   `X ≡ Y` and run it once.
5. **A gate that can invalidate a whole block runs before the block.** If it fails, the plan changes
   — write down what the alternative path would be *before* you need it.
6. **Prove a shared pipeline on the safe instance before the dangerous one.** If the same teardown
   code runs for an external adapter and the internal chip, exercise it where it cannot strand you,
   and require a clean diff before taking the one that can.
7. **Group by hardware** so a cable is plugged once and an adapter attached once.
8. **Stranding tests sit where recovery is cheapest, and never back-to-back** (§3.4). A deliberate
   strand runs *after* the tests that proved the recovery text is literally correct.
9. **Irreversible-this-boot last in its block** — ideally immediately before a scheduled reboot, which
   then hands the next block a clean boot for free.
10. **Outward-facing last of all.** Anything configuration cannot contain closes the campaign.

Draw the dependency edges explicitly — a diagram earns its place here, because "which result gates
which" is the part that is expensive to reconstruct later.

---

## 5. The anatomy of a test block

Every numbered test carries all of these. A block missing one is not runnable by someone else:

| field | why |
|---|---|
| **id** and **register id(s) it settles** | makes closing an open question mechanical |
| **what it is testing** — the claim, not the command | a test whose claim is unstated cannot fail meaningfully |
| **preconditions** | drawn from `PRECONDITIONS.md` §11 for the subsystem |
| **the exact commands**, copy-pasteable, wrapped for `bash` | environment-specific values in CAPITALS with the command that yields them |
| **the observable** | what specifically is being read |
| **pass criteria** | stated *before* the run |
| **blast radius** | what breaks if it fails |
| **recovery** | the exact path back, per §3.3's three questions |
| **artefact** | what file the run leaves behind |

**Three rules on pass criteria:**

> **No test passes on an exit code** unless the block explicitly says the exit code *is* the
> observable (BT-3.1).
> **A pass criterion must not rest on a probe that lies.** Check it against `PRECONDITIONS.md` before
> writing it — most of that file's rows were harvested from exactly this mistake (`PRECONDITIONS.md`
> owns its own count).
> ⛔ **A PASS CRITERION IS ITSELF UNVERIFIED UNTIL THE TEST RUNS — AND ITS FAILURE MODE IS A FALSE
> `FAIL`.** Added 2026-08-12. §7's warning that the harness can manufacture a false **PASS** has a
> mirror image that turns out to be more common: **six criteria were found wrong in two days, and
> every one of them would have produced a FALSE FAIL** — `W1`'s `curl neverssl.com` liveness probe
> (the *server* stalls after the handshake, `N-60`), `W1`'s *"`ip route get` names `rmnet_data0`"*
> (a VPN masks the transport, `N-61`), `T1`'s immediate `ip -br link` read (`DOWN` alongside flags
> `UP,LOWER_UP` inside the settling window, `N-57`), `UG-11`'s *"`$G/UDC` empty ⇒ FAIL"* (it bound
> 60 s later), `T2`'s `grep -E '^(state|channel|ssid)='` (hostapd 2.10 emits **`ssid[0]=`**), and
> the byte-diff of `iptables.txt`/`listen.txt` (`P-49`/`P-50`). **A false FAIL is worse than a false
> PASS on a GATE test**, because a gate blocks every dependent stage and the campaign stops on a
> defect that is in the *criterion*, not the tool. **So: when a gate or an endgame test fails,
> falsify the CRITERION before recording `FAIL`** — re-read after a settle, check the field against
> `PRECONDITIONS.md`, and confirm the probe's output format against the installed version. Record
> the corrected criterion in place; a criterion silently repaired after the fact is unreviewable.

**Environment-specific values are written in CAPITALS with the command that yields them**, never
hardcoded. A campaign file with a baked-in interface name, table id or PID is single-use.

---

## 6. Verdicts

Five, and the last two are what stop a campaign from manufacturing certainty:

| verdict | meaning |
|---|---|
| **PASS** | the stated criterion was met, by the stated observable |
| **FAIL** | it was not — and the block's blast-radius entry now applies |
| **PARTIAL** | met on some arms and not others, with the split characterised |
| **INCONCLUSIVE** | the question cannot be judged from the evidence available (BT-3.3) |
| **NOT RE-VERIFIED** | not run, with the exact command that would settle it recorded |

**INCONCLUSIVE is a first-class result and must never be rounded to FAIL.** Instance #1 records the
canonical case: a composition that did not survive is logged as *"did not survive under these
conditions"* — never as the underlying claim disproven. A test that could not run is not evidence
against the hypothesis it was meant to test.

**A PASS carries its scope.** If the phone can only see its own half of a two-sided question, the
verdict is `PASS (phone-side)` with the host-side half still open — a `◐` half-settled register entry
(§2, the UNVERIFIED register), not a closed one.

**Never count a value the tool under test wrote** (BT-3.2). If a signal is tool-set, print it labelled
as non-evidence and reserve the verdict for something the tool could not manufacture.

### ⛔ THE HARNESS IS AN INSTRUMENT AND IT CAN LIE. Added 2026-08-11 — NORMATIVE

**BT-3.2 forbids counting a value the tool wrote. This clause forbids trusting a value the *test*
wrote.** They are different failures and the second is more dangerous, because a bad harness produces
a **green** result and nothing downstream questions a pass.

**Measured 2026-08-11: three times in one session a test reported a PASS that the harness had
manufactured.** The three, kept because the *shapes* recur:

| the harness bug | why it read as a pass |
|---|---|
| a wrong **argument index** into an `iptables` invocation | the assertion inspected a field that was always present, so it matched regardless of the rule under test |
| an **unbalanced extraction** (quote/bracket) | the extractor silently captured the wrong span and compared it against itself |
| **`rc=$?` read after a pipe** | it captured `sed`'s status, not the status of the command being judged — and `sed` essentially always succeeds |

⚠ **Note what all three share: the harness stopped measuring the system under test and started
measuring itself.** That is the diagnostic question — *did this assertion look at the world, or at my
own scaffolding?* — and it is the same question BT-3.2 asks one level down.

**The rule that caught all three: re-run rather than trusting the first green.** A first green is a
hypothesis. Specifically:

1. **Prove the harness can FAIL.** Before believing a pass, perturb the input so the assertion
   *should* fail, and confirm it does. An assertion that has never been seen to fail has not been
   shown to be an assertion.
2. **`rc=$?` after a pipeline is the status of the LAST element.** Capture the status of the command
   you are judging, or use `PIPESTATUS`. This box's shell rules make it worse — see the zsh
   word-splitting trap in T0's Conventions.
3. **A green on the first attempt, on a test written the same hour, is the least trustworthy green
   in the log.** Re-run it.

### The same fault with the sign reversed — a harness that manufactures a FAIL. Added 2026-08-14

The three above are false **passes**. A harness can equally manufacture a false **failure**, and
that is not the harmless direction: **a green rebuild that reports red invites someone to "fix"
working code**, and the fix is applied to the system under test while the defect is in the
instrument. Both instances below came from the `usbgadget` from-scratch rebuild, whose regression
gate is the ordered configfs **write sequence** extracted from 15 dry-run plans — chosen precisely
because a from-scratch rewrite changes every line of *output*, so output could not be the signal.

| the harness bug | why it read as a fail |
|---|---|
| the golden plans are **device-state dependent** | **325** steps with an empty `hid.*` function pool, **307** after a compose has left `hid.0`/`hid.1` behind — 9 plans × 2 `mkdir` steps. An 18-step delta appears that **nobody introduced**, and it is a property of the device at capture time, not of the code. **Capture the baseline and the candidate at the same device state, and record that state beside the plans.** |
| **`sha256sum <dir>/*` embeds the path** in its output | so a digest taken in one directory can **never** match one taken in another, however identical the bytes. The comparison is guaranteed to fail and says nothing. Hash the **content** (`sha256sum < file`, or `cd` into each directory), or diff the files directly. |

⚠ **The diagnostic question from the false-pass case applies unchanged** — *did this assertion look
at the world, or at my own scaffolding?* — but the second failure adds one of its own: **a
comparison that CANNOT succeed is not a strict test, it is a broken one.** Rule 1 above covers it
if it is actually run: prove the harness can **pass** on known-identical input, not only that it
can fail on perturbed input. An assertion that has never been seen to *pass* has not been shown to
be an assertion either.

This is why §8 result rows record the **command as run**, not a description of it: a rewritten
command cannot be re-executed to check the harness.

### The third shape — the harness changed the ENVIRONMENT under the system under test. Added 2026-08-15

The two shapes above are a harness that **measures itself** and a harness that **cannot pass**.
This one is worse than both, because the assertion is correct, the code is correct, and the
**answer still depends on which binary a name resolved to inside the harness**.

**The instance: `rogueap`/D-12.** A `T10` harness script opened with
`export PATH="/system/bin:/system/xbin:$PATH"`. `/system/bin/grep` is **toybox 0.8.9-android**,
which rejects `\s` outright (`bad regex '^\s+\* AP$': trailing backslash`). `phy_supports_ap`
matched `^\s+\* AP$` through `matches()`, which discarded grep's rc — so a **rejected pattern** was
indistinguishable from an **absent match**, and the probe answered *"this radio cannot host an AP"*
at every `con_mode`. A defect was filed, committed and **pushed** on it. The premise was false:
`iw phy phy0 info` is byte-identical at `con_mode` 0 and 4.

**The three errors, in the order they mattered — each recurs independently of this instance:**

1. ⛔ **A two-variable comparison was recorded as a "single-variable A/B".** The `con_mode=4`
   observation came from inside the harness (toybox grep); the `con_mode=0` observation came from an
   interactive shell (GNU grep). **Both** the variable under test **and** the instrument changed.
   The phrase *"single-variable A/B, same box, minutes apart"* went into the results row and made
   the claim look measured. **Write down what the harness changed about the environment, not only
   what the test changed about the device** — a `PATH`, an `LD_LIBRARY_PATH`, a `cd`, an exported
   locale is a variable.
2. ⛔ **A code read confirmed a mechanism that was never the cause.** The capability check really
   does run 405 lines before the reset, and that ordering really would matter *if* the premise held.
   Reading the source made a false premise feel verified. **Source ordering explains how a failure
   COULD happen, never that it DID.**
3. ⚠ **The control case failed and was explained away twice before being investigated.** `CASE C`
   (`con_mode=0`, expected to pass) failed on the first verification run; it was attributed to a
   transient `iw` read, then tested for flicker (60/60 stable) — and only when it reproduced
   **in-script but not by hand** did the execution-context difference become visible.
   ⛔ **A FAILING CONTROL IS THE FINDING, NOT NOISE AROUND THE FINDING.** A control that fails means
   the instrument is wrong; nothing measured through it counts until that is settled.

**The generalisable rule:** *when a probe's answer depends on which binary the name resolves to,
every measurement taken through that probe inherits the ambiguity.* **Pin the interpreter**
(`/usr/bin/grep`), or use a pattern every implementation accepts, **before** using a probe as
evidence about hardware. `PRECONDITIONS.md` N-62 and N-72; `CORRECTIONS.md` 2026-08-15.

### The fourth shape — the harness under-specified the invocation and the tool chose a different SUBJECT

The three above are a harness that measures itself, one that cannot pass, and one that changed the
environment. This one leaves the instrument correct, the environment untouched and the assertion
sound — and measures **the wrong object**, because the tool selected the subject and the harness
never pinned it.

⛔ **A GUARD THAT DOES NOT FIRE IS NOT EVIDENCE UNTIL YOU HAVE CONFIRMED WHICH SUBJECT IT WAS
HANDED.** The failure is silent in the worst direction: a correct refusal that stays quiet about
something it was never asked to judge reads as **a fix that does not work**, and the obvious next
move is to "repair" working code.

**The rule: when a tool AUTO-SELECTS a resource — a radio, an interface, a device, a config — pin
every selector explicitly in the harness, even the ones whose default you believe you know.** A
default is a decision the tool makes from state you are not holding constant. Naming the parent is
not naming the subject; the tool may still prefer something else it found.

⚠ **It passes every check the other three shapes teach.** Single-variable, instrument verified,
environment clean, output read rather than exit code — and still wrong, because those all police
*how* the measurement was taken and this one is about *what was measured*. **Add the subject to the
snapshot**: record which resource the tool selected, not only what it reported.

---

## 7. Stop conditions

Write these **before** running anything, in two lists.

**Hard stops** — stop, reassess, do not continue down the stage. One row per condition:
`observed | what it means | stop what`. A hard stop is justified when continuing would (a) build on a
broken invariant, (b) run a dangerous test on top of a leaking teardown, or (c) risk a party who did
not consent. The archetypes:

- *the teardown contract the tool was written to guarantee does not hold* → stop everything that
  depends on teardown;
- *the shared pipeline leaks on the safe instance* → do not take the dangerous one;
- *the restore is broken and a reboot will not fix it* (persisted state) → stop the block, recover by
  GUI, debug before continuing;
- *the containment control is decorative* → tear down at once, let nobody join;
- *the scoping filter is empty* → do not run anything that transmits;
- *an unknown party appeared* → stop immediately, record the run as aborted.

**Soft stops** — record and route around. These are results, not failures: a host-side limitation, a
client-side block, an inconclusive probe, a wordlist that found nothing. **Say which is which in
advance**, or every surprise becomes a debate mid-run.

---

## 8. The results log

The log lives inside the campaign file and is **LIVE, not a template**. Rules:

- **Never re-run a filled row.** Some are irreversible until a reboot; re-running one silently
  replaces evidence with a different experiment.
- **Do not change the instrument mid-campaign — except for a safety defect.** A defect found in the
  tool under test is *registered and worked around*, not silently repaired, while its stage is open —
  repairing it invalidates comparisons across stages. A text-only change is exempt and must say so.

  ⛔ **CARVE-OUT, added 2026-08-12. A defect that can harm the operator, the phone, or a third party
  is fixed IMMEDIATELY and the stage restarts.** Comparable measurements do not outrank a live
  defect. Examples that qualify: anything that can signal a process this tool does not own, truncate
  a file it did not create, strand a radio or the USB gadget, or emit a partial sequence to a third
  party.

  ⚠ **This rule used to live in `CODING-RULES.md` as `BT-0.9`, with no carve-out at all** — so by
  its letter a dangerous defect in the operator's working tool stayed unfixed to keep test results
  comparable. It was deleted there on 2026-08-12 and moved here, because it governs **the campaign**,
  not the tool. Cite it as `TOOL-TEST-METHOD.md §8`.
- **Record the calibration values a later test depends on**, and mark them boot-scoped. A baseline PID
  is void after a reboot; so is any "state left behind" note.
- **Carry-forward is state, and state expires.** Every log needs a *state left behind / where to pick
  up* block, and that block must name the `boot_id` it was true under.

> ⛔ **The unrecorded-reboot failure, from instance #1, 2026-08-10.** The log's carry-forward said
> *"no reboot since"* and named the next action as one requiring the live state of that boot. The
> phone rebooted; the function instances vanished; the restore point was captured under a dead boot;
> the named next action had lost its precondition — and none of that was visible from the log.
> **Re-baseline at the start of every session and compare `boot_id` before trusting any carry-forward.**
> When it has expired, log the expiry in place rather than rewriting history.

- **Log what was *not* covered.** Silence reads as coverage. If a stage was skipped, a row deferred, a
  tool given no ids at all — say so in the register, so the absence is a record rather than a gap.

---

## 9. Authorisation

Every campaign file ends with an authorisation section, and it is not boilerplate. It states:

1. **Who owns each target** — every AP broadcast, every host enumerated against, every client joined.
2. **The two places this drifts**, named so they are not forgotten:
   - **a broadcast a stranger's device may see and join.** Controls: a `DONOTJOIN`-style SSID,
     encryption with a throwaway credential on every test that does not specifically need open mode,
     minutes-long time boxes, and — where the test *requires* open or promiscuous behaviour — location
     as the containment control.
   - **a DHCP server or NAT path reachable from a real LAN.** Controls: an isolated subnet with its
     own server, never bridged to a real one, and egress opened by exactly one named test.
3. **The blunt statement about physical-access tooling.** A composed HID gadget is a real keyboard on
   the machine at the other end of the cable from the instant it enumerates: not a shared workstation,
   not a kiosk, not a public charger, not a colleague's machine.
4. **Third-party payload content.** Any shipped payload that fetches and executes remote content from
   a URL the operator did not write is rewritten to your own lab endpoint or skipped.

---

## 10. After the campaign

1. **Promote the lifecycle state** — L1 → L2 → L3 — with the evidence that earned it, in this file's
   instance register. ⚠ The five-state census used to live in `CODING-RULES.md` §S0; that section
   was deleted on 2026-08-12 (a census is not a rule). `CODING-RULES.md` BT-0.2 keeps the only part
   that binds: **a tool whose write path has never run is a draft** and may not be called from a
   script, a wrapper or another tool.
2. **Retire settled register entries in place**, with their answers. Half-settled stays `◐`.
3. **Land the corrections.** A campaign is the largest single source of corrections this box produces:
   route superseded claims to `CORRECTIONS.md`, new lying probes to `PRECONDITIONS.md`, new contract
   clauses to `CODING-RULES.md`, and device facts through `/curate`. **Anything the campaign
   refuted must not survive anywhere in the corpus** — including in the tier that loads ahead of T1.
4. **Fix the defects you deferred under §8**, now that the stage is closed.
5. **Keep a doc-drift appendix** during the run — every place the campaign found a document wrong —
   and work it afterwards rather than interrupting the run.

---

## Instance register

| campaign | tool(s) | state |
|---|---|---|
| `/root/docs/TOOL-TEST-RESULTS.md` | `usbgadget` · `hidrun` · `hcxcapture` · `rogueap` · `wificonnect` | **LIVE.** Stages 0–2 executed 2026-08-10; Stage 3 onward pending. Not all green. |
| `tests/lanmitm-CAMPAIGN.md` | `lanmitm` | **#2 — written, NOT STARTED.** 14 tests `LM-1`…`LM-14`. Written straight after a seven-defect fix pass, so each fix has the test that would prove it. |
| `tests/ms2-lab-CAMPAIGN.md` | `ms2-lab` | **#3 — written, NOT STARTED.** 21 tests `ML-n`. Centres on the two 2026-08-10 fixes: the pid+starttime+comm identity guard and the adopt-don't-delete `ip rule`. |
| `tests/badbt-CAMPAIGN.md` | `badbt` | **#4 — written, NOT STARTED.** 24 tests `BB-n`. Outward-facing: a success types at someone else's device. |
| `tests/bluebinder-start-CAMPAIGN.md` | `bluebinder-start` | **#5 — written, NOT STARTED.** 26 tests `BS-n`, register `BS-V-n`. Proves the two RECORDED-EXCEPTIONS still earn their grandfathering. |
| `tests/btinject-CAMPAIGN.md` | `btinject` | **#6 — written, NOT STARTED.** 17 tests `BI-n`. The most outward-facing tool in the estate; a NEGATIVE result is a PASS. |
| `tests/androute-CAMPAIGN.md` | `androute` | **#7 — written, NOT STARTED.** 13 tests `AR-n`. Deliberately **not** a stranding-class campaign — the tool is read-only, so this proves CORRECTNESS, not safety. |
| `tests/bpffs-mount-CAMPAIGN.md` | `bpffs-mount` | **#8 — written, NOT STARTED.** 17 tests `BF-n`. Proves the BT-3.6 model (fstype **and** count) is real, since rogueap and lanmitm both copied it. |
| `tests/bpfmask-CAMPAIGN.md` | `bpfmask` | **#9 — written, NOT STARTED.** 12 tests `BM-n`. 36 lines of tool, but its output is a **safety control** — an over-broad filter is an authorisation failure that fails silently. |
| `tests/dbus-start-CAMPAIGN.md` | `dbus-start` | **#10 — written, NOT STARTED.** 20 tests `DS-n`. The reference implementation for BT-6.4, BT-5.9, BT-5.10 and BT-6.1 — four clauses rest on it. |
| *(deleted)* | `hcat` · `hcxsort` | **Removed from the box 2026-08-11.** Neither needs a campaign because neither exists. |

**Coverage, stated honestly.** Ten campaigns cover **all 14 tools** in the estate. `hcat` and
`hcxsort` were deleted on 2026-08-11, which removed the last two exceptions rather than covering
them. **Every tool on the box now has a campaign.**

⚠ **That is a statement about DOCUMENTS, not about tools.** Only instance #1 has ever been
EXECUTED, and only through its Stage 2. **Writing a campaign does not move a lifecycle state** —
every tool in instances #2–#10 remains at **L2 or below** until someone runs the tests and logs the
diffs. A directory full of campaigns with blank result rows is a plan, not evidence, and the
failure mode this method exists to prevent is *"a tool everyone believes is tested"*.

⚠ **Corrected 2026-08-11** — this register previously listed **six** uncovered tools, omitting
`bpffs-mount`, `bpfmask` and `dbus-start`, which this file's instance register records as L2. The count
disagreed with the census in another file I own; the census was right. A new tool inherits no test
id by existing, and neither does an old one.

⚠ **SIX of the nine campaign files carried a WRONG instance number, and this register was right.**
Found by the curator 2026-08-11 by re-deriving instead of reading: each file's line 3 declared its own
`Instance #N`, and `androute` said #3 (is #7), `badbt` #3 (is #4), `bluebinder-start` #3 (is #5),
`btinject` #3 (is #6), `bpfmask` #8 (is #9), `dbus-start` #8 (is #10). Only `lanmitm`, `ms2-lab` and
`bpffs-mount` agreed. **Cause: each file was written from a copied header and the number was a
restatement of something this register owns.** Fixed 2026-08-11 by **deleting the number from all
nine files** and having them cite this register instead — the drift cannot recur because there is
nothing left to drift. This is `RULES.md` §*One tier owns a number* applied inside T1.

**Re-derived by the curator 2026-08-11** (`grep -oE '\b[A-Z]{2}-[0-9]+\b' | sort -u`, per file):
`AR` 13 · `BB` 24 · `BS` 26 · `BF` 17 · `BM` 12 · `BI` 17 · `DS` 20 · `LM` 14 · `ML` 21 = **164**.
⛔ **DEAD REGISTER — READ THIS BEFORE ANY ROW BELOW.** The nine `docs/tests/*-CAMPAIGN.md` files
this register indexes were **DELETED on 2026-08-12, unexecuted**: 10,395 lines of plans that had
never been run, i.e. never evidence. They are in
`/root/archive/docs-backups-2026-08-12/removed-2026-08-12.tar.gz`. **Instance #1 (`TOOL-TESTING-PLAN.md`)
was the only one ever executed and its executed rows survive as `/root/docs/TOOL-TEST-RESULTS.md`.**
So: **do not cite this register as evidence that a tool has a campaign, and do not treat
"L1 CONTRACTED" as a live status** — nothing points at a live file. What is still worth reading in
this file is the **METHOD**: the snapshot rule, the Recovery Verification Block, the five verdicts
and why INCONCLUSIVE must never be rounded to FAIL, the stop conditions, §8's instrument-stability
rule, and ⛔ that the harness itself can lie. The per-tool rows below are kept for the *reasoning*
about each tool's blast radius, not as pointers.

**164 tests across the nine files in `/root/docs/tests/`**. ⚠ **Note the shape of the count, because a
brief got it wrong:** there are **nine** files in that directory, not ten — instance **#1 is
`/root/docs/TOOL-TEST-RESULTS.md`**, which lives one level up and is the only one ever executed. "Ten
campaigns" is right; "ten files in `tests/`" is not.

---

## Provenance

Generalised 2026-08-10 from `/root/docs/TOOL-TEST-RESULTS.md`, which remains the live instance and the
owner of every measured value, test id and result. This file owns the method only. When the two
disagree about *method*, this file wins and the instance is corrected; when they disagree about a
*measurement*, the instance wins and this file should not have contained the number.

