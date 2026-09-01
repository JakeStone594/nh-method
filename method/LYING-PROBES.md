# Probes that lie

A catalogue of **eight mechanisms** by which a diagnostic command returns a confident,
well-formed, entirely wrong answer — and the question an author should ask to avoid each.

This is extracted verbatim from the mechanism section of a larger working document that
catalogues **228** measured instances on one aarch64 Android chroot — the parent's own
count, re-derived at extraction on 2026-09-01. It only ever grows, so read it as a floor;
the `~160` that stood here until then was an approximate figure that nobody re-derived after
writing it, which is one of the mechanisms below. **The instances are not
published; the mechanisms are**, because the mechanisms are the part that transfers and the
instances are the part that is specific to one machine.

## How to read the cross-references

The extracted text below cites ids from the corpus it came from. They are left intact rather
than stripped, because removing them would make sentences claim more generality than they
were written with. None of them resolve here:

| id | what it refers to |
|---|---|
| `N-nn` | an instance that wrongly answers **absent / broken / nothing-to-do** |
| `P-nn` | an instance that wrongly answers **present / OK / success** |
| `BT-n.n` | a clause in the authoring rules (`method/CODING-RULES.md` is the successor document) |
| `§4`, `§5` | the instance registers in the unpublished parent document |
| `T0` | the always-loaded top-tier context file for that machine |
| `CORRECTIONS.md`, `TOOL-BACKLOG.md` | other unpublished files in the same corpus |

Driver and subsystem names (`qcacld`, `rtl88XXau`, `netd`, `con_mode`) are technical context,
not device identity. They are the *evidence* for a mechanism, and a mechanism asserted without
its evidence is just an aphorism.

## Why this exists

Every entry was written after a probe produced a wrong conclusion that cost something —
a working capability refused, a capture that came back silently empty, a healthy device
rebooted, a system process killed. The pattern that recurs is not that tools are buggy. It
is that **a probe answers the question it was actually asked**, which is frequently not the
question the author believed they were asking.

---

## 1. `G1…G8` — the eight mechanisms that generate every row

Every row in §4 and §5 reduces to one of these eight causes. This is the reusable part. **The
instance count is the header's, not this line's** — it read `112` against a header saying `115`
until 2026-08-13, so it is stated once and in one place now.

| id | mechanism | the question an author asks |
|---|---|---|
| **G1** | **Wrong root.** The probe reads the chroot's namespace or view; the truth lives in Android's. | *Would this answer differently under `/proc/1/root` or `/proc/1/mounts`?* |
| **G2** | **Wrong scope.** A global-scope reading of a per-object setting. | *Is this per-phy / per-table / per-mount / per-interface / per-venv?* |
| **G3** | **Identity by name.** A string is compared where an identity is required. | *Is `wlan0` / `hci0` / a `comm` / a PID the THING, or a label on it?* |
| **G4** | **Absence of the artefact, not of the capability.** The `.ko`, node, param or attribute is missing because of how the thing was built or composed. | *Does this file only exist in one of the two valid configurations?* |
| **G5** | **The status channel is not the truth channel.** Exit codes, logfiles, counters, and values the tool itself wrote. | *Did I measure the world, or my own request?* |
| **G6** | **The probe perturbs, or is perturbed.** Another actor — Android's USB HAL, netd, InviZible, the Wi-Fi framework, a charger — moves the state around the read. | *Who else writes this, and on what timescale?* |
| **G7** | **The shell or pipeline mangles the probe.** zsh splitting, `pipefail`+SIGPIPE, stderr merge, binary grep, zero-byte writes. | *Is the shell part of my instrument?* |
| **G8** | **Right answer, wrong question.** The probe is correct and measures something else. | *What exactly does this syscall or flag report?* |

`G2` is named in the corpus in its own words, `CORRECTIONS.md:586-607`: *"a global-scope reading of a
per-object setting is a false negative that looks authoritative."*

### Two sub-families worth a column of their own

**(a) Lies by exiting 0 with EMPTY output.** `ip -6 route show default` · `ls /sys/kernel/config` ·
bare `hciconfig` (no output, rc 0, because `bluebinder` is not running). This reads far worse in a
preflight than a wrong value, because **both** `[ -z "$out" ] && fail` and `[ -n "$out" ] && pass`
are wrong. Treat "empty" as a third branch, never as a boolean. ⚠ **The same applies to an empty
RESTRICTION list, where the third branch has a name: UNGUARDED, not permitted.** A wiphy publishing
zero `no IR` / `radar detection` / `disabled` flags has told you nothing, and reading that as
clearance trades a wrong refusal for a silent permission — on `rtl88XXau` it would pass DFS 52–144
(P-71; `TOOL-BACKLOG.md` row 25).

**(b) Confirms the REQUEST, not the EFFECT.** `printf '' > <attr>` (P-07), `taskset` and
`Cpus_allowed_list` (NEW-1). BT-3.5 says read the attribute back — **NEW-1 shows read-back is not
always enough: you must read a *different* attribute.** `Cpus_allowed_list` echoes the mask you asked
for while `sched_getaffinity` inside the pinned process reports what you actually got.

⛔ **This family also generates DEFECTS, not just bad probes — and on 2026-08-14 it generated four in
one tool.** Every `rogueap` defect fixed that day was the tool reporting **what it asked for rather
than what it got**: `[ ok ] NAT out wlan0` while no reply could route back (D-9) · `AP up … ch 36`
while the radio sat on ch 1 (D-10, and see P-57) · `--dry-run complete. Nothing was changed.` after
writing a live journal (D-3) · `restored to type managed` while leaving the link UP (D-8).
**None would surface from reading the tool's output — the output was the thing that was wrong.**
All four surfaced from state the tool did not write: netfilter counters, `hostapd_cli status`,
`ip route get`, and snapshot diffs. **So the author-side test is BT-3.2's mirror: before printing a
success line, ask whether the value came from the world or from your own argv.**
Instances: `TOOL-BACKLOG.md` rows `0a`…`0b`.

**(c) ADVERTISED, NOT HONOURED.** `iw phy` publishes what a driver *claims*. Three measured instances
on this box say a claim is not a behaviour: **P-57** — phy0's combination block permits
`#channels <= 2`, and qcacld silently CSAs the AP onto the STA's channel · **P-63** — the same
block's entry #1 permits `#{ managed } <= 3`, and phy0 holds **one STA association at a time** ·
**P-64** — an external phy publishes `CMAC (00-0f-ac:6)` and *"Device supports SAE with AUTHENTICATE
command"*, and `rtl88XXau` cannot join a WPA3-SAE/MFP-required BSS. **Two phys, three different
advertised properties, one shape: a capability table states the driver author's intent, and the only
honest source is the ACHIEVED state** — the frequency reached, the association completed, the frames
captured. ⚠ **This is not (b).** There the tool echoes *your* request; here the **driver** makes the
claim and the tool faithfully relays it, which is why a code review passes, a read-back passes, and
the probe still lies. The author-side question: *am I quoting a capability, or a result?*

⛔ **The advertisement does not have to come from `iw phy` — the BUILD CONFIG makes the same
over-claim, and that is a second, independent witness for P-64 rather than a new row.** Added
2026-08-16: `drivers/net/wireless/realtek/rtl8812au/Makefile:55` sets `CONFIG_80211W = y`, so the
driver was **compiled** with 802.11w, and the adapter still cannot join a WPA3-SAE/MFP-required AP
(P-64: two distinct adapters, each alone, identical `ASSOC-REJECT status_code=1`, internal chip as
positive control). ⚠ **The contrast in the same tree is what makes it a config claim and not a
board fact:** `rtl8188eus/Makefile:71` sets the same symbol to `n`. **So "config says yes" and
"`iw phy` says yes" are the same shape arriving from two directions**, and neither is a result:
**the config layers tell you what was COMPILED; only the device tells you what WORKS.** This is
also why it was *merged here* instead of filed separately — splitting one shape across two ids is
how a family stops being recognisable as a family. The config layer has its own, distinct failure
modes; those are N-73 / N-74 / P-65, not this one.

---

