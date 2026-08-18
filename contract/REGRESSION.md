# Regression checklist — questions the docs must still answer

Run after **every** T0 rewrite or large T1 move. A question passes only if it is answerable from
`/root/CLAUDE.md` **plus at most one pointer hop**, and the answer is not merely present but
*findable* — the T0 pointer must name what the file answers.

An unanswerable question **blocks the change**. Do not proceed and "fix it later".

## Method

For each question: read T0 only. If T0 answers it, PASS. If T0 names a T1 file that answers it,
PASS. If you need two hops, a search, or prior knowledge from this conversation, **FAIL**.

Answering from memory of the pre-split file is the failure mode this checklist exists to catch —
be strict about it.

## The questions

### Traps that cause wrong actions (these must be answerable from T0 alone)

1. Why did `pkill -f 'btk_server.py'` kill my own shell, and what should I use instead?
2. Why does `mount --bind /proc/1/root/sys/fs/bpf /sys/fs/bpf` exit 0 and still not work?
3. Why must I never run `mount -t bpf bpf /sys/fs/bpf`?
4. `getenforce` says `Disabled` in the chroot — is SELinux off? Where do I read the real value?
5. `df /` says 48 G free. How much space does the chroot actually use?
6. `systemctl start X` exited 0. Did it start?
7. `ip route show` prints nothing and exits 0. Is there a default route?
8. Why does an HTTP request stall for exactly 120 s, and which file is the fix?
9. Why must `/tmp/*.pid` be cross-checked against process start time before signalling?
10. Is `apt-get clean` safe to run here?
11. Which shell rc file must a chroot-start hook go in, and why is `/etc/profile.d` not enough?
12. Why does `pip3 install` fail, and what are the three sanctioned alternatives?

### Procedures (a pointer hop is fine)

13. How do I put the internal chip into monitor mode, and how do I restore it?
14. How do I start PostgreSQL, given `pg_ctlcluster` no-ops?
15. How do I get an `hci0` device at all?
16. `bluetoothd` is connected to the target but nothing types. What are the three causes?
17. Which flag is load-bearing when starting `bluetoothd` for BadBT, and why does starting it by
    hand break it?
18. How do I write a keystroke to `/dev/hidg0`, and how does that report differ from the
    Bluetooth one?
19. `hcxdumptool -o out.pcapng -c 6` fails. Why?
20. How do I bring up a layer-2 lab segment to the laptop VMs, and why won't WireGuard alone do?
21. How do I run the vulnscanner test suite, and what counts as a clean result?
22. How do I refresh the wpprobe vulnerability DB without echoing the key?

### Facts that prevent re-deriving a wrong conclusion

23. Is USB HID / BadUSB available on this device?
24. Does `iwconfig wlan0` show wireless extensions, and is `CONFIG_CFG80211_WEXT` set?
25. Can app-private binaries under `/data/data` be executed from the chroot?
26. Is `/proc/config.gz` trustworthy on this kernel? ⚠ **Pass criterion tightened 2026-08-16 — the
    bare "yes" that passed this question until then is now a FAIL.** A correct answer has **two**
    halves and needs both. (a) **Yes about the kernel Kconfig layer**, and was not on any earlier
    image — Samsung patched `kernel/Makefile:123` to gzip the stock defconfig; that is what the V2
    IKCONFIG fix bought. (b) ⛔ **And it is structurally BLIND to a second config layer: qcacld-3.0
    and the out-of-tree Realtek drivers configure themselves with plain Makefile variables that
    become `-D` cppflags and never reach any `.config`** — so a `config.gz` grep is a
    **false-negative generator for every WLAN feature question**, which is the domain this box
    exists for. **Where the layers disagree the invisible one wins**, because it is what the
    compiler was given. An answer must know the honest probe (qcacld's `configs/default_defconfig`
    plus the `Kbuild` `ifeq` sites; best is the `.o.cmd` compile line, which is **laptop-only**, so
    on the phone `/proc/kallsyms` and device behaviour arbitrate).
    ⚠ **The two failure modes are DIFFERENT and an answer that merges them fails**: pre-V2 the file
    **lied**; now it is **honest about the wrong layer**, and no IKCONFIG fix touches that.
    ⛔ **The expensive half is why this went unseen: the map's three-way cross-check
    (`.config` ↔ defconfig ↔ extracted IKCONFIG) reported ZERO discrepancies while all three sources
    are the SAME layer** — one artifact measured three ways, a *consistency* check wearing the
    authority of a *correctness* check. It would report zero even though the qcacld Make layer
    contradicts it. **And the IKCONFIG truth fix made this worse:** by making the third source
    honest it made the agreement genuine rather than tautological, and so made an already-blind
    check look *more* authoritative. An answer that cites "zero discrepancies" or "48/48" as
    evidence of correctness is the exact state this question now exists to catch. ✅ It must also
    know **no `y`/`m`/`n` row was ever wrong** — the defect was in the methodology sections, which
    is why no row-level review would have found it. `PRECONDITIONS.md` N-73 / N-74 / P-65;
    `CORRECTIONS.md` 2026-08-16.
27. Is `go` installed, and what must never be run?
28. Where is the authoritative kernel reference, and what is the one thing it gets wrong?
29. Is GVM/OpenVAS available?
30. What is the OTG current ceiling, and how confident is that number?

### Conventions

31. What is the required timestamp format for output directories, and why?
32. What must any script that sets `con_mode=4` guarantee?
33. Where do API keys live, and why not in a source tree?

### Added 2026-08-09 (from the audit + split)

34. Is `hcxsort` usable? — added because T0 documented its `ssid-hc2200.py` dependency as though it
    were present, when the file had been deleted. A tool described without its broken state is
    worse than no entry at all. ✅ **Resolved by deletion 2026-08-11**, not by repair: the operator
    removed `/usr/local/bin/hcxsort` **and** `hcat`, and T0 no longer names either. The question is
    **kept, not retired**, and its pass criterion is now twofold. (a) The answer must be *"neither
    exists — `command -v` is the probe"*, reachable from T0's rule **"To answer 'is X installed',
    run `command -v X`"** in §*Installed tooling*; a reader who instead finds a live-looking tool
    row has hit the original defect again. (b) `/root/docs/TOOLS.md` must still carry the
    `hcxsort` **vanished-dependency narrative** — it is the corpus's only worked example of a tool
    whose upstream disappeared from under it, and it is the stated origin of `PRECONDITIONS.md`
    N-52. **Deleting that section to save bytes is a FAIL of this question**, even though the tool
    is gone. The lesson outlives the file: retiring an inventory entry is cheap, retiring the
    worked example that taught a rule is not.
35. A claim in T0 has been superseded. Where is the old wording, and why does it matter that it is
    kept? — added because T3 did not exist until 2026-08-09; before that, corrections were being
    carried inline in T0 forever, or lost.

### Added 2026-08-09 (from the app-extraction correction pass)

36. `/dev/hidg0` does not exist. What creates it, and is turning ADB off enough? — added because T0
    named the ADB toggle as the precondition for two months. It is not: the nodes come from a
    configfs `mkdir`, and after a reboot the toggle produces nothing. A reader following the old row
    would have concluded HID was unavailable, which is the exact refusal the 2026-08-06 correction
    was written to prevent.
37. `test -e /proc/1/root/system/bin/busybox_nh` says the file is not there. Is it absent? — added
    because the answer is no: absolute symlinks read through `/proc/1/root/` dangle, and the whole
    `/proc/1/root/<path>` primitive silently misreports for exactly this class of file.
38. Is `/sdcard/iptables-default` a safe restore point? — added because a T1 doc called it
    "known-good" while T0 forbade the only way to apply it, and replaying it strips eight live
    netd/Samsung BPF rules.

### Added 2026-08-09 (dnsmasq rogue-AP config)

39. You need a DHCP server for a lab segment. Is `service dnsmasq start` safe here? — added
    because the answer is **no** and nothing said so: the shipped `/etc/dnsmasq.conf` is
    NetHunter's evil-twin config (`interface=wlan1`, `10.0.0.10-250`, itself as gw/DNS), the init
    script passes no `-C`, and `wlan1` is the adapter `wificonnect` uses as a **client** — so the
    innocent-looking command puts a rogue DHCP server on a real network. A correct answer must
    also name the mitigation (`-C <own.conf>`, validate with `dnsmasq --test -C`) and that the
    app's Kali Services `DNSMASQ` toggle is the same trap.

### Added 2026-08-09 (usbgadget / rogueap / hidrun admission pass)

40. `/dev/hidg0` is missing. **What creates it, and what does that cost?** — the sibling of Q36,
    which settled the *mechanism*. This one settles the *action*: the answer must name
    `usbgadget compose hid` **and** its price (ADB and MTP drop, the host re-enumerates) **and**
    that no compose has ever run here. An answer that stops at "compose a gadget" sends someone
    into a destructive first run blind.
41. A `status` verb exited **2**. **Is that a bug?** — added because the 0/1/2 convention is new
    (2026-08-09) and looks exactly like a defect to a future session, which would "fix" it and
    silently break every precondition check built on it. A correct answer says 2 = *read-only verb
    found a state needing action*, and that which state earns a 2 is per-tool.
42. You need a **non-US keyboard layout** for a HID payload. **What is available, and what is
    refused?** — added because `ru` is *deliberately* refused (phonetic transliteration, not
    ЙЦУКЕН, wrong on 31–32 of 34 Cyrillic letters). A reader who reads that as a missing feature
    will "add" a layout that mistypes almost every character, and the override
    (`--allow-broken-ru`) must be findable rather than reinvented.
43. You are building a Wi-Fi attack tool. **May it use only the external adapter?** — added
    because the operator made both radios first-class on 2026-08-09, and because the mechanics
    differ per radio in a way that invites a wrong refusal: `con_mode` is **monitor only**, an AP
    is a second `type __ap` vif, and `con_mode` must never be touched for an external adapter.
44. `wificonnect disconnect` ran and the rogue AP stopped relaying. **Why?** — added because the
    pref-1 `ip rule` seam is invisible from either tool's own documentation, and the failure
    presents as "rogueap broke".

### Added 2026-08-09 (wificonnect 2.0 / adapter-parity save)

45. You need to kill a `wpa_supplicant` you started in the chroot. **What must you not use?** —
    added because the answer **contradicts a rule already in T0**. The Conventions section ranks
    `pkill -x <exactname>` as the *most* reliable form, and for this one binary that is the
    dangerous choice: Android's Wi-Fi HAL has `comm` = plain `wpa_supplicant`, so `pkill -x
    wpa_supplicant` kills the phone's Wi-Fi. A correct answer must name the inversion (a
    `^`-anchored `pgrep -f` requiring `-i<iface>`, because the HAL carries no `-i`) **and** that a
    pidfile alone is insufficient, since a bare `grep wpa_supplicant /proc/$pid/cmdline` guard
    passes the HAL. If T0 ever states the general rule without the exception attached, that is a
    FAIL — the exception has to be visible at the point of the advice.
46. **Which radio does `wificonnect` use, and how does it decide?** — added because the answer was
    `wlan1`, hardcoded, for months, and the tool now picks by **wiphy identity** with a documented
    auto-selection order. A stale answer here sends someone to a device that may not exist, or has
    them tear down Android's Wi-Fi as a side effect of using a dongle. The answer must also cover
    what taking `wlan0` costs (an announced, journalled hand-off including
    `set-scan-always-available disabled`).
47. **What regulatory domain applies to the internal chip?** — added because `iw reg get`'s first
    block says `country 00` and that is the *wrong answer* for phy0, which is **self-managed at
    IL**. Reading the global bloc alone hides 6 GHz entirely and marks every 5 GHz band
    PASSIVE-SCAN, which reads as a capability gap and is not one. A correct answer names the
    per-phy block and that a `country_code=` hint is ignored by a self-managed wiphy.
48. A doc or a tool's own header says a capability is unavailable. **What do you check before
    repeating it?** — added because `lanmitm`'s header, and a T2 memory quoting it, both claimed
    Android-managed `wlan0` "cannot be used at all" while **the code never enforced it** and the
    tool's own `prep` fixed the stated reason. The answer is: check whether the code agrees, and
    diff against the backup rather than trusting a summary. Two of this pass's findings — that
    `lanmitm`'s change was comments-only and that `bpfmask`'s **output filename** changed — existed
    only because a real `diff` was run.

### Added 2026-08-10 (first live USB tooling run)

49. `/dev/hidg0` is missing. **Has a chroot-side compose ever actually been PROVEN to work here, or
    is it still theory?** — the third sibling of Q36 (mechanism) and Q40 (action + cost). This one
    settles the **evidence**, and the answer flipped on 2026-08-10 from *"no compose has ever been
    run on this device"* to *"it ran, it worked"*. Added because the old wording invited exactly the
    refusal the 2026-08-06 correction exists to prevent — a reader who finds "never executed, a
    first live run is a deliberate experiment" may decline to run it at all. A correct answer names
    the compose, that it succeeded, and what is **still** untried (the networked set and every
    host-side observation).
50. **You plugged in the charger during a USB gadget test. What just happened?** — added because
    the answer is *the gadget was re-composed and `adbd` restarted, with no user action*, and
    because a specific documented test criterion ("adbd's PID changed ⇒ the compose restarted it")
    is **invalidated** by it. Without this, a charger touch mid-test manufactures a false PASS on
    the headline `rndis,hid,adb` question. A correct answer must also say: do not charge the phone
    during gadget work.
51. **`usbgadget restore` printed `[FAIL]`. Do you reboot?** — added because the documented reaction
    to a failed restore *is* "reboot", and defect **D-1** makes that FAIL false: the links check
    samples `configs/b.1` while Android's USB HAL is still rebuilding the gadget, which `restore`
    provokes itself. The tell is that the same output block says `ffs.adb linked=True` and
    `HAL drift: none`. A correct answer is **no** — re-run `usbgadget status` and trust that.
52. **You are pasting a multi-command `for` loop into a terminal here. What breaks?** — added
    because the interactive shell is `zsh`, which does **not** word-split unquoted expansions, so
    `for n in $VAR` iterates **once** over the whole string, silently, with plausible-looking
    output. It corrupted a live test run on 2026-08-10 (0 of 9 payloads converted, one bogus MATCH
    line, no error). A correct answer names `bash -c '...'` or a real array. This is the class of
    trap that gets compacted away because it looks like trivia about shells; it is not.

## Recording a run

Append to `/root/.claude/memory-curation/regression-log.md`:

```
## <YYYY-MM-DD-HH-MM-SS> — after <what changed>
PASS 33/33   (or list each FAIL with the question number and what was lost)
snapshot: /root/.claude/memory-curation/snapshots/<ts>/
```

Add a question whenever a curation pass nearly dropped something valuable. The checklist is
supposed to grow.

### Added 2026-08-10 (test-campaign discoverability)

53. You are about to run a live test of `usbgadget` / `rogueap` / `wificonnect` / `hidrun` /
    `hcxcapture`. **Has this test already been run, and what does re-running it cost?** — added
    because for a day `/root/docs/TOOL-TESTING-PLAN.md` was a live, mid-campaign operational doc
    that `/root/CLAUDE.md` did not mention **once**. A cold session would have improvised a test
    that was already recorded, and `UG-3`/`UG-4` are irreversible until a reboot. A correct answer
    names the plan, that its §6 is a **live** results log rather than a template, and that Stages 0
    and 1 are already green. The general lesson: **an operational doc whose steps are destructive
    when repeated must be reachable from T0 the day it starts being used, not after the campaign.**

### Added 2026-08-10 (Stage 2 — first tests with a host attached)

54. You need data **back** from a victim you are typing at over USB-HID, and it has no network.
    **Is the subsystem write-only?** — added because the honest answer for two months was "we don't
    know", the intuitive answer is "yes, HID goes one way", and the measured answer is **no**: the
    host's LED OUTPUT report is readable off `/dev/hidg0`, one byte, settable by any unprivileged
    process on the victim. That makes it the only network-independent return path here and it
    crosses an air gap. A correct answer must also carry the probe trap — `dd bs=1 count=8` waits
    for **eight** one-byte events and looks exactly like "not supported", which is how a real
    capability nearly got recorded as absent.
56. You cleared a configfs/sysfs attribute with `printf '' > attr`, the shell returned 0, and the
    attribute still reads its old value. **Why?** — added because a **zero-byte write never fires
    the kernel's store callback**, so the clear silently does nothing while looking like success.
    It invalidated an A/B arm on 2026-08-10. A correct answer says re-read the attribute, and that
    the real control is usually a separate switch (`os_desc/use` for the USB MS-OS descriptor).
    Generalises to every sysfs write on this box, `con_mode` included.
57. Can you compose `rndis,hid,adb` from the chroot **and keep it**? — added because the answer is
    **no, and the reason matters more than the answer**: arming `ffs.adb` requires the very
    `start adbd` + `sys.usb.ffs.ready 1` writes that wake Android's HAL into re-applying
    `sys.usb.config`, so the composition is reverted ~440 ms after it applies. A correct answer must
    also refuse the tempting conclusion — this is **not** the kernel author's "RNDIS+HID keeps ADB"
    claim being disproven, because the composition never held long enough to test it — and should
    name the adb-free contrast (stable indefinitely, survives unplug/replug).

### Added 2026-08-10 (harvest — the skill tier, and probes that lie about absence)

58. **Does any skill assert a capability that T0 says works?** — grep-checkable, and it must be run
    after **every** T0 correction, not only after a split:
    `grep -rniE "unavailable as configured|Say so before suggesting|no bnep|not available on this device" ~/.claude/skills`
    ⛔ **EVERY HIT IS READ, NEVER COUNTED — added 2026-08-17.** *"Must be empty"* is the wrong
    criterion: **a grep for a retired claim also matches the text that RETIRES it.** Re-run that day
    returned three hits and **all three were correct text** — two were the instruction *never to say
    HID is unavailable*, one was a correction quoting a dead command to warn against it. Scoring
    mechanically would have manufactured three regressions on a clean corpus, which is the mirror of
    what this question exists to catch. A hit is a prompt to read, and only an assertion in the
    present tense fails. Added because two skill files told the model to *volunteer* a refusal of USB
    HID for four days after T0 had corrected it, in a tier whose descriptions load ahead of T1. A
    contradiction in a tier nobody reads in full is the most expensive kind.
59. **Does the skill tier point at the device docs?** —
    `grep -rl "/root/docs/" ~/.claude/skills | wc -l` must be **> 0** (it was **0** of 113 files on
    2026-08-10, against 68 files naming `CLAUDE.md`). A tier that knows T0 exists but not T1 will
    re-derive whatever T1 owns.
60. **Does any SKILL.md body contain a positional parameter?** —
    `grep -rlE '\$\{?[0-9]' ~/.claude/skills --include=SKILL.md`; any hit inside a code block is a
    **FAIL**, and a hit in prose (a price, an `awk '{print $1}'`) is a defect to escape. Added
    because bodies are `$N`-substituted with the **caller's arguments** at invoke time and **no file
    read reveals it** — the corruption exists only in the delivered context.
61. **`am start …` printed `app_process: inaccessible or not found`. Is `am` missing, and will
    fixing `PATH` help?** — added because the answer is **no** to both, and the message is a decoy:
    20 `/system/bin` wrappers are shell scripts that `exec app_process`, and `app_process` cannot
    link in the chroot (`libnativeloader.so` lives under Android's `/apex/com.android.art`, and
    reaching it only advances the error to `not accessible for the namespace "(default)"` — the
    Android linker's namespace policy, which `LD_LIBRARY_PATH` cannot override). A correct answer
    names the `cmd` equivalent or `su -mm`, and knows that `svc` works **only** for
    `wifi`/`data`/`bluetooth`.
62. **You are about to pin a long hashcat run to the big cores. Which cores, and will the pin be
    honoured?** — added because T0 said `taskset -c 4-7` and "the big cores" for months, and both
    halves were wrong: 6-7 are the big cores, and 4/5 are usually outside the session's allowed
    mask, so the documented pin silently ran **2**-wide with a width that changes as CPUs 4/5
    flicker. A correct answer gives `-c 6-7`, and knows that a core count must never be cached.
63. **Is `pytest` installed?** — added as the canonical example of a **half-wrong** claim surviving
    in two tiers at once: it *is* installed system-wide (`/usr/bin/pytest` 9.0.3) and *is not*
    reachable from the vulnscanner venv (`include-system-site-packages = false`), which is where
    everyone checks. A correct answer states both halves **and** that the gate stays on stdlib
    `unittest` regardless.

### Added 2026-08-10 (second harvest apply — citation rot, core_ctl, module probes)

64. **A T1 file cites `/root/CLAUDE.md:412`. Can you trust it?** — grep-checkable:
    `grep -rln "CLAUDE\.md:[0-9]" /root/docs/*.md` lists the exposed files, and each must carry a
    `citations re-resolved YYYY-MM-DD` marker **dated on or after `stat -c %y /root/CLAUDE.md`**.
    Added because 19 such citations went ~60 lines stale within hours of a single T0 edit, inside
    the very file whose own rule warns about rot. A correct answer knows new citations must name a
    **section heading and anchor phrase** instead. ⚠ **Updated 2026-08-13: the exposure is now
    ZERO** — `PRECONDITIONS.md` held the last 38 and they are section anchors, so the byte-stamp
    requirement lapsed with them. **Do not re-add a stamp**; a stamp naming a byte count that no
    longer governs anything reads as freshness and certifies nothing. The grep is now the whole
    mechanical test — and see Q75 for what it does not catch.
65. **`nproc` says 6, `getconf _NPROCESSORS_ONLN` says 8, `online` says `0-7` and `isolated` is
    empty. How many CPUs can you actually use, and why?** — added because **four** conventional
    probes are wrong at once. The answer is Qualcomm **`core_ctl` runtime isolation**
    (`cpuN/isolate` = 1 while `online` = 1), the honest probe is
    `len(os.sched_getaffinity(0))` inside the pinned process, and the answer is **not stable** —
    isolation is load-driven, so probing it changes it. A correct answer also pins `6-7`, not `4-7`.
66. **`modinfo <mod>` says "not found". Is the module absent?** — added because the answer is *the
    question is unanswerable that way on this box*: there is **no `/lib/modules/$(uname -r)`** at
    all (only trees for two kernels that never ran here), so `modinfo`/`modprobe`/`depmod` are
    **inert** and answer "not found" regardless of truth. It false-negatives for a built-in
    (`bnep`) **and** for a loaded module (`rfcomm`). A correct answer names the discriminator:
    `/sys/module/<name>/initstate` **absent ⇒ built-in**, **`live` ⇒ loaded module**.
67. **`invoke-rc.d <svc> status` exited 4. Is the service down?** — added because the answer is
    **no, that is a refusal**: the policy layer denies read-only actions and it emulates the action,
    returning "unknown", without ever consulting the daemon. A correct answer routes read-only
    questions to `service <x> status` or `pgrep -x` plus a functional probe — and knows that T0
    listed `invoke-rc.d` among the "honest" tools until 2026-08-10.

### Added 2026-08-13 (harvest — the rules replacement and the two tool rebuilds)

68. A tool's design notes, hazards and defect register are in `--help-full`. **Is that the house
    convention?** — added because T0 said **yes** for a day, in the settled voice most likely to be
    copied, while `CODING-RULES.md` rule 3 forbids a second help screen under any name. The correct
    answer is **no**: the tools that still carry one are debt (`TOOL-BACKLOG.md` G-16), the long
    text's home is `docs/TOOLS.md` (rule 2's table), and every rebuilt tool has none. ⚠ **The count
    is T0's to own and it moves with every rebuild** — it was 13 on the day this question was
    written and 11 by the end of that day; do not restate it here. ⚠ The
    dangerous half is the *retrieval* one — a reader who cannot find a design note must be sent to
    `TOOLS.md`, not left concluding it was deleted.
69. You are about to rebuild one of the `/usr/local/bin` tools. **What do you start from?** — added
    because the answer is **not the current source**: `/sdcard/nh_files/Scripts/Backup/` holds the
    operator's originals for **ten** tools — not the estate — and rebuilding from the accumulated
    version copies the ceremony forward, which is the thing the rebuild exists to remove.
    ⛔ **THIS IS THE OPERATOR'S STATED PREFERENCE, NOT A FINDING, AND A CORRECT ANSWER SAYS SO**
    (operator, 2026-08-15: *"the rule was aspirational, the quarter-size result was just an
    observation"*). ⚠ **This question cited its own evidence until 2026-08-15** — *"Both 2026-08-13
    rebuilds were done this way and landed at roughly a quarter of the size with the same
    capability"* — and that sentence was **wrong twice over**: only two of the four rebuilds started
    from an original, and the size result was never offered as proof of anything. **An answer that
    justifies the rule by a line count fails this question**; so does one that treats the rule as
    weakened by `rogueap` reaching the same reduction **from the current source**. A preference does
    not need evidence and cannot be refuted by it. `CORRECTIONS.md` 2026-08-15.
70. A register says nine tools each have a test campaign. **Are those tools tested?** — added
    because the answer is **no** and the register read exactly like coverage: 10,395 lines of
    `docs/tests/*-CAMPAIGN.md`, every one *written, NOT STARTED*, deleted unexecuted 2026-08-12. A
    correct answer knows **a plan is not evidence**, names the five tools ever executed against
    (`usbgadget` `rogueap` `hidrun` `wificonnect` `hcxcapture`), and knows `TOOL-TEST-METHOD.md`'s
    instance register is dead while its **method** — harness-can-lie, INCONCLUSIVE-never-FAIL, the
    snapshot rule — is not.
71. `grep -qE '(a|b|)x' file || echo "no match"` printed `no match`. **Did the probe run?** — added
    because a bare `grep` *rejects* an empty alternation branch with `empty (sub)expression` and
    **rc=2** instead of evaluating it, and `||` fires on rc 2 exactly as on rc 1. A correct answer
    treats any `grep` rc ≥ 2 as **"did not run"**, and knows glibc `regcomp` (so `pgrep`, `awk`,
    Python) accepts the same pattern — which is what makes a cross-checked probe look confirmed.
    ⚠ **Updated 2026-08-15, and the update is now the harder half of the question: this entry said
    `/usr/bin/grep` IS ugrep 7.5.0, and that was wrong in the direction that costs you the fix.**
    Measured A/B on one pattern: bare `grep` → **rc 2**, `/usr/bin/grep` → **rc 0**, `bash -c
    'grep …'` → **rc 0**. `/usr/bin/grep` = `/bin/grep` = **GNU grep 3.12**; there is **no ugrep
    binary on PATH and no ugrep package**. The ugrep is the **assistant harness's embedded copy**,
    injected as a shell **function** named `grep` by `/root/.claude/shell-snapshots/snapshot-zsh-*.sh`
    (*"Shadow find/grep with embedded bfs/ugrep"*). ⛔ **So an answer that names `/usr/bin/grep` as
    the offender FAILS this question twice over** — it blames an innocent binary, and it forecloses
    one of the two working escape hatches. **The scope is the assistant, not the device:** a shipped
    `#!/bin/bash` tool and the operator's own terminal both get GNU grep, so an answer that proposes
    hardening a tool against this also fails. ⚠ **The general lesson is why the question is kept:
    `--version` told you nothing here — only `type -a grep` and an A/B against the explicit path
    distinguish "the system tool is odd" from "something shadowed the name".** `PRECONDITIONS.md`
    N-62; mechanism in `/root/docs/CLAUDE-HARNESS.md` §6; `CORRECTIONS.md` 2026-08-15.
    ⚠ **Extended 2026-08-15 — there are THREE `grep`s here, not two, and the third breaks a
    DIFFERENT pattern.** `/system/bin/grep` is **toybox 0.8.9-android**: it **accepts** the empty
    branch and **rejects `\s`** (`bad regex: trailing backslash`), the mirror image of the ugrep
    case. ⛔ **An answer naming only ugrep-vs-GNU now FAILS this question**, because the toybox arm
    is the one T0's own §*Android integration* sends you to — prepend `/system/bin` so `svc`/`cmd`
    resolve, and every later `grep` in that shell is toybox. It cost `rogueap`/D-12: a defect filed,
    committed and **pushed** against a working radio, from a probe that answered *"this radio cannot
    host an AP"* at every `con_mode`. A correct answer gives the pattern that survives all three —
    **POSIX classes (`[[:space:]]`), no empty arm** — or pins the interpreter, and knows the estate
    is not exposed (`common.sh` `android()` scopes PATH to one command) while a hand-typed export
    is. `PRECONDITIONS.md` N-72; `TOOL-TEST-METHOD.md` §6, third shape.
72. The chroot has a default route and a `from all lookup main` rule at pref 1. **Does Android's app
    traffic follow it?** — added because the answer is **no**: Android binds each app socket to its
    network's interface, so the bound lookup decides and `main` never applies. A chroot-side default
    route can neither give Android connectivity nor steal it. A correct answer also names the lying
    probe — `ip route get <dst>`, and even with `uid`/`mark`, is an **unbound** lookup describing a
    packet Android never sends; only `oif <iface>` matches a real app socket. `PRECONDITIONS.md`
    P-53.

### Added 2026-08-13 (elevation of `CODING-RULES.md` rules 4 and 6 into T0)

73. You are writing a line of runtime output for a tool and it looks useful. **Does it go in?** —
    added because the operable half of rule 4 lived only in T1 while T0 carried the headline
    *"Output is for acting on, not a record"*, which is unfalsifiable on its own. The correct answer
    is the per-sentence test — **a command, a value, or a choice the operator has to make; none of
    the three means it is not output** — plus the reason the weaker form fails: *"it is useful"*
    passed four successive cleanup passes over one tool's output, which removed nothing. An answer
    that stops at "keep output actionable" is the state this question was written to catch. It must
    also say where the stripped mechanism **goes** (`docs/TOOLS.md`, rule 2's table), or the test
    becomes a licence to delete knowledge.
74. A rule in the contract is telling you to add lines nobody asked for. **What do you do?** —
    added because this is the only clause in the corpus that licenses **refusing** a rule rather
    than complying into bloat, and its absence is the recorded failure mode of the predecessor
    contract: it charged ceremony per mutated piece of state and forbade deletion, so every review
    pass could only add and every review pass grew the tools it governed. The correct answer is
    *the rule is wrong; say so instead* — not "comply and note the concern". ⚠ A compaction pass
    that strips this bullet as "restating T1" reintroduces the ratchet; that is a FAIL.

### Added 2026-08-13 (the T0 citation-anchor conversion)

75. `grep -rn "CLAUDE\.md:[0-9]" /root/docs/*.md` is empty and every T1 citation into T0 names a
    section. **Is the citation set therefore correct?** — the mechanical half is the grep, and it
    **must stay empty**: a hit is a regression to a form that rots, and it fails this question
    outright with no further reading. The judgement half is the one that was expensive, and it is
    why this question is not just Q64 restated. **A clean re-resolve proves a cited passage was not
    REWRITTEN. It proves nothing about whether the citation was ever RIGHT.**
    `PRECONDITIONS.md`'s 38 were re-resolved by verbatim anchor match **five** times, every pass
    reporting *0 failed*; when they were finally read for **meaning**, **17 of 38 pointed at the
    wrong table row or paragraph** — 13 at a different one entirely, 4 overrunning the passage.
    The error rode through every pass because a verbatim match faithfully reproduces the previous
    target *whatever it was*. A correct answer says an anchor set is audited for meaning **once, at
    adoption**, and that no stamp, count or "0 failed" substitutes for that. `CORRECTIONS.md`
    2026-08-13. ⚠ An answer that stops at "the grep is empty, so we are fine" is the exact state
    this question exists to catch.

### Added 2026-08-13 (the normative-decision clause — proposed, approved, restored)

76. A `CORRECTIONS.md` entry says a rule "now lives at the head of the contract". **Is it there?**
    — added because one did not, and no tier noticed for a day. ⚠ The arrow runs both ways: a T1
    file asserting **its** old wording "is in `CORRECTIONS.md`" fails this question identically.
    Grep both directions, and normalise whitespace first — a pointer that wraps across a newline
    defeats a naive regex and the question then fails open. T3's §*The governance error —
    extraction was framed as documentation* closed with *"The rule that replaces it, **now at the
    head of the contract**"*, written while `/root/docs/CODING-RULES.md` still had
    `## 1. Code contains code` at line 5: **the landing it asserted had not happened.** The clause
    survived only because a T2 memory had quoted it verbatim while flagging it as homeless
    (`tools-are-for-the-operator`), and that memory is what got it restored — it is now the
    unnumbered head section, and the memory points there instead of carrying it.
    **The pass criterion is an act, not a reading: open the named target and match the text.** An
    answer that reports what the entry *says*, or that the rule "was carried forward", **FAILS** —
    that is the state this question exists to catch, and it is how a rule every tier believes is
    binding ends up carried by none of them. ⚠ **Same shape as Q75, different artefact:** there, a
    clean re-resolve proves a passage was not *rewritten* and proves nothing about whether the
    citation was ever *right*; here, a correction entry faithfully records an intention and proves
    nothing about whether it landed. **A document reproducing its own prior assertion is not
    evidence about the world.** Sizes and the re-derivation are owned by `CORRECTIONS.md`
    2026-08-13.
    ⛔ **Do not mechanise this question as a verbatim substring probe — it does not fail closed, it
    floods.** Tried 2026-08-13: a naive mechanisation reported **63 MISSes, every one false** (count
    as reported in the harvest brief, **not re-derived here**). Two structural reasons, both
    unfixable by a better regex: a pointer normally sits beside the **corrected** text, so there is
    no old wording next to it to match; and the sites that *do* carry their old wording elide it with
    `…`. The whitespace-normalised grep finds the **pointer**; only reading the named target settles
    whether the claim landed. **A landing assertion is a claim about content, and a verbatim probe
    cannot settle a claim about content** — the same reason Q75 requires an anchor set to be audited
    for meaning once, at adoption. Budget a read per pointer, or do not run the question.

### Added 2026-08-13 (the first live exercise of an external-adapter restore)

77. A tool armed your external adapter and its `EXIT` trap handed back the interface **type**. **Is
    the adapter back as you found it?** — added because the answer was **no** for the whole life of
    the rebuilt `hcxcapture`, and nothing revealed it, because **the wrapper's own code read as a
    complete account of what the run changed**. `hcxdumptool` also **substitutes the MAC** — its own
    `-h` says so — and the interface was left administratively UP. A correct answer names all three
    pieces of state, says a restore's scope is enumerated from the **dependency's** documentation and
    never from the wrapper's code, and carries the two probe traps that come with it: the falsifying
    evidence is the **mid-run** sample (without it, a managed type at the end proves nothing — the
    restore branch may never have fired), and the teardown is scored on
    `/sys/class/net/<if>/{type,address,operstate,flags}`, **not** on `iw dev` (it keeps a cached
    channel line) or `ip link` (`qdisc` moves `noop`→`mq`) — both residues survive a manual recovery
    too, so they are not the tool's. ⚠ An answer that stops at *"the trap restores the type"* is the
    state this question exists to catch: an unrestored adapter advertises **another vendor's OUI**,
    not a locally-administered address, and every later tool on that phy inherits it silently.
    `PRECONDITIONS.md` N-63 covers the recovery probe that lies (`perm_addr` is absent on this
    kernel; `ethtool -P` is honest).

### Added 2026-08-14 (the `rogueap` preference correction)

78. Two tools both want a `lookup main` `ip rule`. One scopes its rule to its own subnet
    (`from <net>/24`). **Is it now safe from the other tool's teardown?** — added because the answer
    is **no**, and the corpus said yes in **seven files at once** for a day: T0 in two places,
    `HANDOFF.md`, `TOOLS.md`, `PRECONDITIONS.md` P-39, `TOOL-BACKLOG.md` and
    `TOOL-TEST-RESULTS.md` all attributed the closed `rogueap`↔`wificonnect` seam to the **scoping**.
    ⛔ **A rule's SCOPE and its DELETABILITY are independent properties.** `ip rule del` matches only
    the attributes it is given, so an unqualified `ip rule del lookup main priority 1` deletes a
    *scoped* rule at that priority exactly as readily as a global one (measured 2026-08-13). What
    closed the seam was moving `rogueap` to **`pref 100`**, clear of `wificonnect`'s 1 and
    `ms2-lab`'s 1..9. A correct answer names **both** properties and says which one does which.
    ⚠ **The second half is the retrieval trap and it fails silently**: a teardown check, an `RVB`
    line or a test criterion that greps `pref 1` for `rogueap`'s rule **never matches**, and the
    natural reading of no match is *"no rule was installed"* — the same false negative
    `rogueap`/D-2 was about. `TOOL-TEST-RESULTS.md`'s `W11` row carried exactly that criterion.
    ⚠ An answer that stops at *"the rule is scoped, so it cannot be touched"* is the state this
    question exists to catch. `CORRECTIONS.md` 2026-08-14.

### Added 2026-08-14 (the `usbgadget` rebuild and the outward citation rule)

79. You are about to rebuild a tool and `/sdcard/nh_files/Scripts/Backup/` **does not contain it.**
    **What now?** — the sibling of Q69, which settles the *source*. This one settles the *absence*,
    and it was live on 2026-08-14: `usbgadget` was written by the assistant and has no pre-assistant
    ancestor, so **the rule Q69 scores had no starting point** — the first rebuild in the estate in
    that position. ⚠ **An answer that reports Q69's rule and stops is the state this question exists
    to catch**, because the failure it produces is silent: with no original to hand, the only thing
    left to read is the accumulated source, which is exactly what the rule forbids. The correct
    answer names the substitute — an **audited capability floor** (verbs, presets, tokens, flags and
    every silently-failing probe, enumerated from the old file *before* a line is written) **plus a
    regression gate that is not the output**, because a from-scratch rewrite changes every line of
    output. For `usbgadget` that gate was the ordered configfs write sequence (0 of 15 plans
    differed). It must also know **which tools are in this position**: `usbgadget`, `hidrun`, `nh`.
    T0 §*Conventions*, the rebuild bullet.
80. A doc cites `/usr/local/bin/rogueap:611-624`. **Is that allowed?** — added because the answer
    flipped on 2026-08-14 and the *old* answer was yes, in the contract, with a stated reason.
    `RULES.md` rule 4 permitted `path:line` into source *"because those files change far less
    often"*; **five tools were rebuilt in two days and the outward citation set measured 3 of 4
    wrong**, one of them pointing past EOF. The correct answer is **no** — cite the function or
    token name, `grep -n` is the resolver, a line number is a hint beside a name at most. The
    mechanical half:

    ```
    grep -rnoE '\b(usbgadget|hidrun|rogueap|wificonnect|hcxcapture|lanmitm|badbt|btinject|bpfmask|ms2-lab|androute|bpffs-mount)`?:[0-9]+' /root/CLAUDE.md /root/docs/*.md
    ```

    ⚠ **Two exemptions, and they are not laxity — a hit in either is correct and must not be
    "fixed":** `CORRECTIONS.md` is an **append-only record of what was said**, so rewriting an
    archived entry to a newer convention falsifies the record; and `TOOL-BACKLOG.md` Part 2 row 13
    **quotes a wrong line citation as the defect it is describing**. Everything else is a
    regression. ⚠ **The judgement half is Q75's, and it applies unchanged:** converting a rotten
    number to a name requires *reading* to find the right anchor. A name resolved by mechanical
    proximity to the old line number reproduces the old error under a form that looks durable.

### Added 2026-08-14 (the cellular DIAG harvest — the `cmd:`/`app_process:` inversion)

81. A `/system/bin` wrapper failed with **`X: inaccessible or not found`**. **Is `PATH` the fix?** —
    added because the corpus gave exactly **one** rule for a message shape that has **two**
    opposite remedies, and the rule it gave is the wrong one for the case a reader is most likely
    to hit. **The answer depends entirely on WHICH BINARY the message names.** `app_process:` is the
    hard boundary of Q61 — 20 wrappers `exec app_process`, which cannot link here, and PATH changes
    nothing. **`cmd:` is the opposite**: the three *translated* `svc` verbs (`wifi`, `data`,
    `bluetooth`) `exec cmd` **bare**, `cmd` is a native ELF that runs fine, and `/system/bin` is
    simply not on the chroot's PATH — **so PATH IS precisely the fix** (or call `/system/bin/cmd …`
    directly; `svc data` is `cmd phone data enable|disable`). ⚠ **An answer that applies Q61's rule
    to both is the state this question exists to catch**, and it costs a wrong refusal of a working
    capability — including the only way to cycle the data connection, which is how a full RRC
    lifecycle is forced for a `/dev/diag` capture. ⚠ **The second half is the invariant nobody
    stated for four days**: T0 and `ANDROID-BRIDGE.md` both assert `hcxcapture -A` and
    `rogueap --drop-android-wifi` are *not* silent no-ops, and that is true **only because the
    wrappers prepend `/system/bin` themselves** (`/usr/local/lib/nh/common.sh` `android()`,
    `hcxcapture`). A correct answer knows the claim is carried by two lines of tool code, that
    nothing typed by hand inherits it, and that **T0's own monitor-mode recipe opens with
    `svc wifi disable`.** `PRECONDITIONS.md` N-70; `CORRECTIONS.md` 2026-08-14.

### Added 2026-08-15 (harvest — the silent half of a trap T0 already carried)

82. A loop `until ! pgrep -f 'thing'; do sleep 3; done` has been running for twenty minutes and the
    job it waits on finished long ago. **What is wrong, and what do you wait on instead?** — the
    sibling of **Q1**, which settles the **kill** form. This one settles the **wait** form, and it is
    the more dangerous of the two because Q1's failure is *loud* (the shell dies, exit 144) while
    this one produces **no error, no exit status and no output** — the loop simply never returns.
    The waiting shell's own `argv` contains the pattern, so `pgrep` matches **itself**, forever.
    ⚠ **An answer that recites Q1's rule and stops is the state this question exists to catch**: the
    documented remedies are ranked for *killing* (`pkill -x`, a pidfile, a `/proc` sweep skipping
    `os.getpid()`) and **none of them fixes a wait**. A correct answer waits on a **file or state
    condition** (`until grep -q done log`) or on a **PID captured at launch**, and knows that
    skipping `$$` is insufficient — measured on-device 2026-08-15, `pgrep -f` from inside such a
    shell returned **three** pids: the child, the substitution subshell, **and the harness's own zsh
    wrapper**. Reported cost: 5 shells spinning 626–1156 s in a single session, against one loud
    `pkill` hit in the same session. T0 §*Conventions*, the `pkill -f` bullet.

### Added 2026-08-15 (the mirror-drift probe — a clean check of the wrong artefact)

83. `git status --porcelain` in `/root/tools/nh-tools` is **empty**. **Is the mirror in sync with
    the device?** — added because the answer is **no, and that probe cannot tell you either way**:
    the repo holds **regular copies**, not symlinks (`git ls-files -s`, zero mode-`120000`), so a
    device-side edit never touches the working tree and git has nothing to report. Measured
    2026-08-15: `git status --porcelain` **0 lines** while **7** mirrored files were drifted, each
    confirmed by `cmp`. ⛔ **Any pass that ends "mirror clean" on the strength of `git status` is
    reporting the wrong artefact** — including the pre-push secret gate, which scans the **repo**
    copies and so certifies nothing about the device. ⚠ **An answer that stops at "use `cmp`
    instead" is the state this question exists to catch**, because the mapping is **four roots** and
    a guessed path fails in *both* directions: `bin/*` → `/usr/local/bin/*`, `lib/common.sh` →
    `/usr/local/lib/nh/common.sh` (**`lib/`, not `lib/nh/`**), `docs/*` → `/root/docs/*`,
    `contract/*` → `/root/.claude/memory-curation/*`; a bare `cmp -s <guess> <dev> || echo DRIFT`
    exits **2** and reports drift that is not there, while a `[ -f ]`-guarded loop prints nothing
    and reads as in sync. ⚠ **Distinct from `TOOL-TEST-METHOD.md` §6's three harness shapes, and
    the difference is the whole lesson** — there the instrument malfunctions (it measures itself,
    it cannot pass, it changed the environment); here the instrument is working **perfectly** and
    answering a **different question**, which is why re-running it never helps and why "prove the
    harness can fail" does not catch it. T0 §*Conventions*, the mirror bullet; T2 `nh-tools-repo`.

### Added 2026-08-16 (the clock-rendering save)

84. Chroot `date` and Android `date`, read at the same instant, print different times. **Are the
    clocks out of sync?** — added because the answer is **no, and it cannot be yes**, and the wrong
    answer is expensive in a direction the corpus had no guard against: it invites a *fix*. The
    chroot and Android share **one `CLOCK_REALTIME`**, and this kernel predates time namespaces
    (`/proc/self/ns/time` and `/proc/1/ns/time` are **both ENOENT** on 4.14.190; they landed in
    5.6), so there is no mechanism for drift to exist through. What differs is `date`'s
    **locale-aware default format**: the app boot chain exports `LANG=en_US.UTF-8`, so glibc prints
    **12-hour AM/PM** where Android's toybox prints 24-hour, and `07:07:05 PM` beside `19:07:05`
    reads exactly like a clock offset. **A correct answer needs all three parts:** (a) drift is
    *impossible*, not merely unobserved; (b) the locale-independent probe — `date -u`, or an
    explicit `date '+%Y-%m-%d %H:%M:%S %Z'`, never two bare `date` outputs; (c) **refuse a time
    daemon** — `ntpsec` is installed with a working init script, so the wrong fix is one `service`
    call away, and there is one clock which is Android's. ⚠ **An answer that stops at "set
    `LC_TIME`" FAILS**: the export is the remedy for one caller's rendering, not the reason the
    question can never be a sync fault, and a reader holding only the remedy re-opens the
    investigation the next time a shell that predates it prints AM/PM. ⚠ **Same shape as Q83, which
    is why it is not filed with the shell traps**: the instrument works perfectly and answers a
    **different question** (`PRECONDITIONS.md` G8 — `date` is correct, the eye is measuring the
    locale). `PRECONDITIONS.md` N-75; T0 §*Conventions*, the clock bullet.

### Added 2026-08-16 (the `mac80211_hwsim` phantom-`wlan0` incident)

85. `wlan0` exists, sits on **phy0**, reads `type managed` and its `con_mode` is readable. **Is it
    the internal chip?** — added because on 2026-08-16 the answer was **no**, and *every one of
    those four properties was true of the phantom*. `mac80211_hwsim`, auto-loaded from the Magisk
    module at `late_start`, registered **phy0 and phy1 at t≈13.25 s** while qcacld's netdev arrives
    via ICNSS at **t≈16.30 s**: the phantom took `wlan0`+`wlan1`, the real chip landed on `wlan2`,
    and Android scanned a radio with no antenna. ⛔ **An answer that reaches for `is_internal()` /
    the wiphy-identity rule FAILS this question**, and that is the whole point: `is_internal()`
    compared `phy_of $IFACE` to **`phy_of wlan0`** — a name comparison one indirection down. ⚠ **Pass criterion updated 2026-08-17: the estate now resolves by DRIVER (`icnss`) and a correct answer says so, while still naming the hazard for anything hand-typed**
    — immune to a *vif rename on the real chip* (the 2026-08-09 `hcxcapture` bug) and **not** immune
    to a *foreign radio taking the name `wlan0`*, where it inverts and calls the real chip
    *external*. ⚠ `pick_iface()` is worse than `-i`: it **skips** internals to prefer an external,
    so it would select `wlan1`, the second phantom. A correct answer names the honest probe — read
    the **driver**, `basename $(readlink -f /sys/class/net/wlan0/phy80211/device/driver)` must be
    `icnss` — and knows the recorded mitigation (`=m`, not `=y`) was **orthogonal to the mechanism**:
    load order is the only variable, and `late_start` is earlier than qcacld either way. ⚠ **Same
    shape as Q83 and Q84**: the instrument works perfectly and answers a *different* question. Filed
    here rather than with the radio questions because the generalisable half is about **hazards
    recorded against the wrong variable** — a mitigation that is complied with, ships, and buys
    nothing while looking like diligence. `PRECONDITIONS.md` P-67 (`G3`); `KERNEL-V2.md`
    §`mac80211_hwsim`; `CORRECTIONS.md` 2026-08-16.


### Added 2026-08-17 (the watchdog-bite harvest)

86. The docs give a **safe first-use procedure for kprobes** and the capability map lists *"an
    installed kprobe"* among its untested settling probes. **Is arming one safe?** — added because
    the answer is **no on this build**, and because the doc's own opening sentence said the risk was
    *"not the probe firing"* until 2026-08-17, which is a **stale instruction**: it told a careful
    reader which risk to skip. `arch/arm64/kernel/insn.c` patches text under
    `stop_machine_cpuslocked()` and `kprobes.c` routes **both** arm and disarm through it, while
    ftrace uses the `_nosync` variant; with `JUMP_LABEL=n` (verified on-device) **kprobe arm/disarm
    is the only runtime stop-the-world text patch this kernel performs**, and that path was found
    wedged across all 8 CPUs at a `WPON` watchdog reset (RWC 568). A correct answer names the
    mechanism, the operational rule (**no `perf probe`, no `kprobe_events` write from any tool, do
    not arm while RPMH `TCS Busy` is climbing**) and knows the shared tracefs buffer is the
    **second** risk, not the first. ⚠ **An answer that treats the untested settling probe as a gap
    to close is the state this question exists to catch.** `KERNEL-V2.md` §*KPROBES*;
    `CORRECTIONS.md` 2026-08-17.
87. The phone reset by itself. **Where is the evidence, and what must you do FIRST?** — added because
    every instinct here (`dmesg`, `catch-boot-warn`) reads the wrong source, and because the right
    ones are **destroyed by the next boot**. A correct answer: read `/proc/reset_reason` (`WPON`
    watchdog vs `RPON` normal), `/proc/extra`, `/proc/reset_rwc` and `/proc/reset_summary` **at their
    plain chroot paths**, and **capture them before rebooting** — measured 2026-08-17, after the
    reboot that followed the bite `reset_summary` read **0 bytes** and the only surviving copy was
    the one already saved to `/root/tests/`. It must also carry the two probe traps: ⛔ **a size
    probe lies** (`stat -c %s /proc/reset_reason` → 0 while `cat` → `RPON`, so `[ -s ]` skips a
    populated record — `PRECONDITIONS.md` N-82), and ✅ **the persistent archives**
    (`/data/system/dropbox/SYSTEM_LAST_KMSG_*`, `/data/log/dumpstate_lastkmsg_*`) are where anything
    older must come from. ⚠ **An answer that reaches for `dmesg` or the taint word alone FAILS the
    action half** — the taint word tells you a WARN fired, never that a watchdog bit.
88. You are about to run a 5 GHz attack on the **external** adapter and a doc says `--country`
    matters for a non-self-managed phy. **Does it?** — added because the answer is **no**, and
    because the corpus asserted the opposite in **two** places (T0 §*BOTH radios* and `TOOLS.md`
    §`rogueap`) from an inference nobody had measured: *absence* of a `phy#1` self-managed block was
    read as *presence* of the global domain. Measured 2026-08-17 with the adapter attached: phy1
    (`rtl88XXau`) publishes **zero** restriction flags across 58 channels and exposes 5075–5090 MHz
    and ch 173/177, valid in no domain. **A correct answer states the operational consequence — on
    phy0 the kernel stops you leaving the permitted set, on phy1 nothing does, so the operator is the
    only guard** — and knows the measurement is of what the driver **publishes**, not proof of what
    it **enforces** (`P-57`, `P-63`, `N-72` are the rows where `iw phy` published a claim that did
    not hold). ⛔ **It must also refuse both available false explanations**: `CONFIG_DISABLE_REGD_C`
    in `rtl8812au/Makefile` is a **dead variable** (assigned once, consumed nowhere, never a `-D`),
    and it is **not** a missing database — `CONFIG_CFG80211_INTERNAL_REGDB=y` compiles 1,665 rules
    into vmlinux. The mechanism is **UNESTABLISHED**; the next place to look is `rtw_regd_init()`.
    `PRECONDITIONS.md` P-71; `CORRECTIONS.md` 2026-08-17. **This question supersedes the external
    half of Q47** — Q47 still owns the internal chip.

89. `dmesg | grep -c 'TCS Busy'` returned 42, then 32 a few minutes later on the same boot. **Which
    is right?** — added because **neither is**, and because the shape leaves no trace: a `dmesg` count
    is bounded by the **ring**, so it reports what is still resident, not what has happened since
    boot, and there is **no error, no truncation warning and no gap marker**. Measured on-device
    2026-08-17: uptime 3658.0 s against a ring spanning 1660.1 → 3657.4 s = **1997.3 s, only 55 % of
    the boot**; the same 36 hits give **0.59/min against uptime** and **1.08/min against the span**.
    ⭐ **A correct answer gives the honest denominator — `last_ts − first_ts` from `dmesg`, never
    `/proc/uptime`** — and names **the ring FLOOR as the probe, not the count**: re-sample and see
    whether the floor advances (1660.14 → 1694.63 over 45 s with the count unchanged at 36), which
    fires **whenever the ring has wrapped, regardless of arrival rate**. ⚠ **An answer that offers
    the falling count as the test FAILS**: it is a corroborating symptom that appears only when
    eviction outpaces arrival, so it may never fire while the ring quietly eats the history anyway. ⚠ **An answer scoped to `TCS Busy` FAILS**: it hits every `dmesg`-derived count, so **a
    zero is not an absence either** — this corpus's own `over-current` (P-72) and `defex` counts are
    ring-bounded evidence. ⛔ **And it is the SAME mechanism as `catch-boot-warn`'s permanent
    CANNOT-TELL** (`TOOL-BACKLOG.md` row 22): there the wrap eats the early-boot WARN, here it eats
    the event history — one cause, two symptoms, and an answer treating them as separate problems will
    "fix" one in isolation. `PRECONDITIONS.md` P-73; `KERNEL-V2.md` §*RPMH / `TCS Busy`* owns the
    rates.

### Added 2026-08-17 (the harvest — a correction that reached T0 and T1 and stopped)

90. A device claim was found wrong and **corrected in T0 and T1**. **Is it corrected everywhere?** —
    added because the answer is **no by default**, and because a clean T0/T1 is the state this
    question exists to reject rather than the pass criterion. Measured 2026-08-17: a T2 memory
    asserting *"the V2 kernel supports ZERO external USB Wi-Fi adapters"* was still live **16 days**
    after the correction was published in both T0 §*The kernel* and the vulnscanner fork's own
    `CLAUDE.md`, which cites that very audit as its canonical void-conclusion example. A correct
    answer runs **two** greps in the same pass — `~/.claude/projects/*/memory` **and**
    `~/.claude/skills` — and knows why the tiers fail differently: **T2 is injected on recall and
    never audited on load**, so nothing re-reads it, while a skill body is injected wholesale on
    invoke and its *description* is in context from session start. ⭐ **It must name the asymmetry:
    a wrong memory outlives a wrong doc, and the corrected doc then CONCEALS the disagreement**. ⛔ **AND BOTH GREPS MUST BE SUBJECT-SCOPED, added
    2026-08-18: searching the retired claim finds only text that DISAGREES with the correction, while
    text that AGREES for a reason that has expired conflicts with nothing and survives the sweep.**
    Proven twice in two days — the `hci0` absolute, then the kprobes withdrawal, which reached the two
    rows a peer named and stopped because the peer's finding had defined the scope. `RULES.md`
    §*Classification order* —
    the two now differ and only one of them is ever in front of you. ⚠ **An answer that treats
    fixing T0 as the landing FAILS**; so does one that greps only the skills dir, which is the half
    `T1.5` rule 1 already mandated and which passed throughout the 16 days. ⛔ **A live second
    instance was found in the same pass and is the worked example**:
    `recon-passive-active/SKILL.md:150` said *"PEP 668 is diverted here so `pip3 install` works"* —
    the opposite of the measured behaviour, carrying the library's most-trusted `⚠ ON THIS DEVICE`
    marker, and recorded as *fixed* in the skills dir's own audit file because the fix went into T0
    and never into the source. `RULES.md` §T1.5 rule 1 and §*Retiring a T2 memory*;
    `CORRECTIONS.md` 2026-08-17. **Retirement is part of the answer**: retire the memory's **slug
    and description**, not its body — recall is scored on the description, so a body-only fix leaves
    it firing on exactly the questions it answers wrongly.

### Added 2026-08-18 (an absolute that a plugged-in adapter falsifies)

91. `hciconfig` shows an **`hci0`**. **Is `bluebinder` running?** — added because T0 states the
    absolute *"there is no HCI device until `bluebinder-start` runs"*, and **the converse does not
    hold**: a USB Bluetooth controller registers its own. Measured 2026-08-18 — the MT7921AU in an
    Alfa AWUS036AXML makes `btusb` claim two interfaces and register a **phantom `hci0`** that can
    never initialise (`BD Address 00:00:00:00:00:00`, `DOWN`, `hciconfig hci0 up` →
    `Can't init device hci0: Connection timed out`), with `bluebinder` **not running**; and
    `BLUETOOTH.md` independently records a CSR dongle taking `hci0` with bluebinder down. **A correct
    answer refuses the inference and gives the discriminator** — `hciconfig hci0` reporting
    `Bus: USB`, plus a non-zero BD address to distinguish a working adapter from a phantom, and
    `pgrep -x bluebinder` to settle it outright. ⚠ **An answer that reads `hci0` as proof the HAL
    proxy ran FAILS**, and so does one that treats the phantom as a usable controller. ⛔ **This is
    Q90's shape and was found by it**: the correction reached T1 (`INSTALLED.md`, `BLUETOOTH.md`) and
    stopped, leaving T0 and **four skill-tier sites** asserting the absolute in the present tense —
    in the tier that loads ahead of T1. `INSTALLED.md` §*USB Wi-Fi adapters*; `BLUETOOTH.md`.

### Added 2026-08-18 (the second repository — and it is public)

92. `scan-secrets.sh` exited **0, clean**, and `cmp` says one file in the repo differs from its
    device original. **Are you clear to push, and should you sync that file?** — added because the
    answer is **no to both**, and each half fails in the direction that publishes device identity.
    ⛔ **There are TWO repos and their invariants are OPPOSITE.** The private one is a
    **byte-identical mirror** of the device (BT-0.10); the public one is a **curated derivative**,
    and exactly one file is deliberately short — the contract's regression checklist, with its one
    identity-carrying question removed, leaving a visible gap in the numbering. **A `cmp` sweep
    reports that as DRIFT and the reflex fix copies the identity straight into a public tree.**
    ⚠ **An answer that reaches for the four-root `cmp` loop is the state this question exists to
    catch** — that loop is scoped to the private mirror and is the wrong instrument here; the
    numbering gap is the tell, not a defect to close.
    ⛔ **The second half is the gate.** A green run is a statement about **the bytes the gate was
    handed**, never about the artefact git will publish: until 2026-08-18 it built its input from
    `git ls-files` alone and **had never read a commit message**, while the private repo's root
    commit subject names the handset — so every green run for the life of that repo certified a tree
    containing it. A correct answer knows the input set is the question, that `.gitignore` is an
    input to it, that the script resolves its root from `$0` so the wrong copy reports cleanly about
    the wrong tree, and that the model/board/codename probe runs **only** under `--public`.
    `PRECONDITIONS.md` P-78; `TOOL-BACKLOG.md` G-17; T2 `nh-method-repo` and `nh-tools-repo`;
    `CORRECTIONS.md` 2026-08-18.

### Added 2026-08-18 (the repository object — the artefact no file gate reads)

93. `scan-secrets.sh --public` exited **0** on the tree you are about to publish. **Have you
    checked everything that publishes?** — the sibling of **Q92**, which settles the *input set*
    (files, then files + history). This one settles the *artefact*: **a repository is not only a
    tree.** ⛔ **Name, description and topics live in the forge's API, in NO commit, so no
    file-content probe can ever reach them** — measured 2026-08-18 with
    `gh repo list --json name,description,repositoryTopics`: one private repo's **description**
    names the handset model, and a second private repo's **name** carries the model and the SoC.
    ⚠ **And they do not publish on a push — they publish on a VISIBILITY FLIP**, so the pre-push
    gate is the wrong *moment* as well as the wrong instrument, and a description survives being
    copied into a new repo. ⛔ **The second half is the one a careful reader will not expect: the
    gate SKIPS TWO FILES BY DESIGN** — itself and `.gitignore`, citing the `pkill -f` self-match
    family — **and those are exactly the two that must carry device-identifying literals to do
    their job** (the `--public` probe's own pattern list enumerates board, SoC and model family;
    the ignore rules carry the model as a glob). **So the least-scanned file in a public tree is
    the densest identity string in it.** ⚠ **The exemption is CORRECT and an answer that proposes
    removing it fails** — what is wrong is the conclusion drawn from a green run. ⚠ **An answer
    that reaches for the gate, or proposes another probe inside it, is the state this question
    exists to catch**: the honest move is to **enumerate what the gate did not read** — a
    `gh repo view --json name,description,repositoryTopics`, plus the script's own self-exempt
    list — and judge those by hand. ⚠ **Scope: these are MODEL-WIDE identifiers, not per-unit, and
    whether they are acceptable is an operator decision** — there is a precedent for keeping a
    model-wide string in a non-published file and none for keeping one in a public tree.
    `PRECONDITIONS.md` **P-79**; `TOOL-BACKLOG.md` G-17.
    ⚠ **UPDATED THE SAME DAY — THE DECISION NOW EXISTS, AND IT DOES NOT RETIRE THIS
    QUESTION.** The operator **accepted** the model-wide identifiers in the private
    repositories' metadata as they stand — ⛔ **they are not to be changed; a rename breaks
    the remote of every clone** — **conditional on those repositories remaining private**,
    which is exactly the condition this question says does not survive a **visibility
    flip**. ⛔ **So the enumeration still runs.** The acceptance covers the set that was
    judged: not a new repository, not a description copied into one, and not the public
    tree's self-exempt file. ⚠ **An answer that cites the decision INSTEAD of enumerating
    is the state this update exists to catch** — a settled judgement about one set is not a
    probe of the next. Nothing about per-unit identity is relaxed. T2
    `repo-object-identity-accepted`.
