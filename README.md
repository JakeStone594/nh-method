# Method notes — building and testing tooling on an Android chroot

Working method extracted from a private offensive-security tooling project: a set of
wrappers for a Kali chroot running under Android on an aarch64 phone, developed against
hardware the author owns and networks the author controls.

**This repository contains the method, plus the handful of tools that demonstrate it.** The
rules for writing the tools, the protocol for testing them on a live device, the contract
governing how findings get recorded, the catalogue of diagnostic commands that lie, and the
pre-publish gate that guards all of it — together with six pieces of environment plumbing
included as worked examples of the rules rather than as capabilities.

**The offensive tooling is not here and is not going to be**, nor are the device-specific
findings or the engagement records.

## Why the split

The tooling is dual-use and the findings describe one specific handset on one specific
network. Neither generalises and neither is anyone else's business. What does generalise is
the discipline: how you establish that something is true on a machine where the ordinary
diagnostic commands are unreliable, and how you keep a body of knowledge from rotting once
you have.

That turned out to be the harder problem, and it is the part worth publishing.

## The documents

| file | what it covers |
|---|---|
| `method/LYING-PROBES.md` | Eight mechanisms by which a diagnostic command returns a confident wrong answer, each with the question an author should ask instead. The most portable thing here. |
| `method/TOOL-TEST-METHOD.md` | How a live test campaign is run: the snapshot rule (the diff *is* the pass criterion), the recovery verification block, five verdicts and why INCONCLUSIVE must never be rounded to FAIL, stop conditions, and the authorisation requirement. |
| `method/CODING-RULES.md` | Rules for writing the tools. One help screen. Output is for acting on, not a record. Safety is a trap and a restore function, not a paragraph. The working version is the specification. |
| `contract/RULES.md` | The knowledge-curation contract: admission tests for a new fact, evidence labels, what may never be deleted, and where each kind of claim is allowed to live. |
| `contract/REGRESSION.md` | The questions the documentation must still answer correctly after any rewrite. A rewrite that loses an answer is a regression, not an edit. |
| `scripts/scan-secrets.sh` | The pre-publish gate. Six leak classes over file contents *and* commit messages. |

## The included tools

Environment plumbing, not attack tooling. They are here because `method/CODING-RULES.md`
argues a position about how a tool should behave, and a rule with no worked example is
difficult to evaluate. Each of these verifies by function rather than by exit code, which is
the whole point of the rules they were written under.

| tool | what it does |
|---|---|
| `bin/bpffs-mount` | Bind-mounts the host's bpf filesystem into the chroot so netfilter writes resolve. Verifies by filesystem type and pin count, never by exit status. |
| `bin/dbus-start` | Starts the system bus, which cannot start itself where there is no init. |
| `bin/androute` | Reads the host's policy routing, where the main table is empty and the real routes live in per-network tables. |
| `bin/android-browser` | Opens a URL in the host browser from a chroot that has none. |
| `bin/catch-boot-warn` | Captures a boot-time kernel warning. Reports three verdicts including CANNOT-TELL, cross-checked against the kernel taint word. |
| `lib/common.sh` | Shared library: interface and radio resolution by driver identity rather than by name. |

## The conventions that do the work

Three habits account for most of the value, and none of them are complicated:

**Separate what was measured from what was inferred.** Every durable claim carries how it was
established. A claim derived from reading source is labelled differently from one established
by running a probe on the device, because the first is regularly wrong in ways the second is
not.

**Keep an archive of superseded claims.** When something turns out to be wrong, the old
wording is preserved rather than deleted. This is not sentiment — it stops the same wrong
conclusion being re-derived from the same evidence six weeks later, which otherwise happens
reliably.

**State the scope a measurement actually had.** One sample is one sample. A result from one
adapter is not a result about a driver. Writing a finding one notch stronger than its
evidence is the most common failure mode in the parent corpus, and most of the corrections
archive consists of exactly that.

## Authorisation

The parent project is developed against devices the author owns and networks the author
controls. The test protocol in `method/TOOL-TEST-METHOD.md` treats authorisation as a
precondition to be established before a campaign starts, alongside the recovery plan — not
as a disclaimer appended afterwards.

## Running the gate

```sh
./scripts/scan-secrets.sh --public
```

Read-only. Exit `0` clean, `2` findings, `1` the scan could not run. A hit is not
automatically a leak — placeholders and documentation examples are expected — so each is
judged, then either fixed or filtered explicitly at the probe.

## Provenance

Extracted from a private repository. Cross-references to `N-`/`P-` instance ids, and to
documents not included here, are left intact rather than stripped: removing them would make
the surrounding sentences claim more generality than they were written with.
