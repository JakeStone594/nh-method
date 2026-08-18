#!/usr/bin/env bash
#
# scan-secrets.sh — pre-publish gate for nh-tools.
# ======================================================================================
# WHY THIS EXISTS
#   These tools are developed on a live engagement device. Every file here has been near
#   real PSKs, real BSSIDs, a real LAN, a live SIM and a secrets directory. Six classes
#   of leak are easy to make and impossible to take back once pushed:
#     1. the device serial or a real MAC, left in a comment quoting a real log line;
#     2. a private address that identifies the operator's LAN;
#     3. a credential literal in an example invocation;
#     4. a path that discloses where keys, captures or a potfile live;
#     5. a cellular identifier. The subscriber and equipment identities name the SIM and
#        the handset for their lifetime and cannot be rotated; a serving-cell, operator
#        and signal tuple is a location fingerprint for the moment it was taken.
#     6. the handset model, board or ROM codename. Checked under --public only: a private
#        working mirror is entitled to say which device it was written for.
#   Commit messages are scanned alongside file contents -- they publish with the tree.
#   Publishing is irreversible: making a repository private later does not un-publish
#   what was cloned, cached or indexed.
#
# EXIT CODES  (the house contract — see docs/CODING-RULES.md)
#   0 = clean, nothing to act on
#   1 = the scan itself could not run (refusal / probe failure)
#   2 = a READ-ONLY check found a state needing action, i.e. findings. NOT a crash.
#
# NOTES ON STYLE
#   set -uo pipefail, deliberately no -e: grep legitimately returns 1 on no-match and
#   that is information, not failure.
#   No `grep -q` behind a pipe anywhere: under pipefail a successful match SIGPIPEs the
#   producer and 141 becomes the pipeline status, so a match reads as a failure.
#   See docs/PRECONDITIONS.md N-20.
# ======================================================================================

set -uo pipefail

GRN=$'\033[32m'; RED=$'\033[31m'; YEL=$'\033[33m'; DIM=$'\033[2m'; RST=$'\033[0m'
if [ ! -t 1 ]; then GRN=''; RED=''; YEL=''; DIM=''; RST=''; fi
ok()   { echo "  ${GRN}[ ok ]${RST} $*"; }
bad()  { echo "  ${RED}[FAIL]${RST} $*" >&2; }
warn() { echo "  ${YEL}[warn]${RST} $*" >&2; }
info() { echo "  ${DIM}$*${RST}"; }
die()  { echo "${RED}scan-secrets: $*${RST}" >&2; exit 1; }

# Two tiers, because one class of identity is CONDITIONAL. A serial, a PSK or a subscriber
# id is never publishable and is checked always. The HANDSET MODEL is different: it is
# deliberately present in a private working mirror -- the README has to say what the tools
# were written against -- and is a leak the moment the tree goes public. --public turns on
# the checks that only bind then, so the default stays honest about the private repository.
PUBLIC=0
for _arg in "$@"; do
    case "$_arg" in
        --public) PUBLIC=1 ;;
        *) die "unknown argument: $_arg (the only argument is --public)" ;;
    esac
done

ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)" || die "cannot resolve the repository root"
# $0 decides what "the repository" means, so a copy of this script run from anywhere else
# rescopes the entire scan. `/bin` exists, so testing bin/ alone certifies `/` as the repo:
# git then finds no checkout, the find fallback walks the whole filesystem, and the gate can
# report clean about a tree nobody asked about. Require a marker only this repository has —
# and name the resolved root in the output below, because a probe that chooses its own scope
# has to say which scope it chose.
[ -f "$ROOT/scripts/scan-secrets.sh" ] && [ -f "$ROOT/method/CODING-RULES.md" ] \
    || die "no checkout at $ROOT — run this from inside the repository"
cd "$ROOT" || die "cannot enter $ROOT"

# Files git would actually publish. Falls back to a find when not yet a repo.
if git rev-parse --git-dir >/dev/null 2>&1; then
    mapfile -t FILES < <(git ls-files --cached --others --exclude-standard)
    info "scanning $(printf '%s\n' "${FILES[@]}" | grep -c . ) tracked/untracked files in $ROOT (git-aware)"
else
    mapfile -t FILES < <(find . -type f -not -path './.git/*' | sed 's|^\./||')
    warn "not a git repository yet — scanning the working tree in $ROOT instead"
fi
# The scanner and .gitignore contain these patterns BY DEFINITION. Leaving them in is the
# `pkill -f` self-match family (docs/PRECONDITIONS.md P-01): the instrument matching itself.
_self=( "scripts/scan-secrets.sh" ".gitignore" )
_keep=()
for _f in "${FILES[@]}"; do
    _skip=0
    for _s in "${_self[@]}"; do [ "$_f" = "$_s" ] && _skip=1; done
    [ "$_skip" -eq 0 ] && _keep+=( "$_f" )
done
FILES=( "${_keep[@]}" )

# Commit messages publish with the tree, and no probe below has ever read one: this gate is
# file-content only, so a serial or a model in a subject line ships under a green result.
# Materialise them as a file so every check covers them with no per-check change. The name
# is what a hit line cites, so it has to read as a source, not as a temp path.
if git rev-parse --git-dir >/dev/null 2>&1; then
    _msgdir="$(mktemp -d)" || die "cannot create a temporary directory"
    # /tmp is persistent here and nothing ever ages it out, so the trap is load-bearing.
    trap 'rm -rf "$_msgdir"' EXIT
    git log --all --format='%H %an <%ae>%n%s%n%b' > "$_msgdir/git-commit-messages" 2>/dev/null \
        || die "cannot read commit messages"
    FILES+=( "$_msgdir/git-commit-messages" )
    info "including $(git log --all --oneline | grep -c . ) commit messages from all refs"
fi

[ "${#FILES[@]}" -gt 0 ] || die "no files to scan"

findings=0
check() {  # check <label> <extended-regex> [inverse-filter-regex] [extra-grep-flags]
    # extra-grep-flags is unquoted on use so a caller can pass more than one. It is scoped
    # per check rather than set globally so every probe above keeps the exact behaviour its
    # filter was negative-controlled against. A global -i measures clean on this corpus; it
    # is declined because it silently retunes eight probes, not because it costs anything.
    local label="$1" rx="$2" skip="${3:-}" flags="${4:-}" hits n err
    # ⚠ VERIFY THE INSTRUMENT FIRST. A malformed filter makes `grep -vE` error, emit nothing, and
    # this check then reports [ ok ] while testing NOTHING — a clean bill of health from a probe that
    # never ran. Caught 2026-08-11, when a backreference (unsupported by -E) silently disabled the
    # whole MAC check and a REAL MAC passed the gate. Same family as PRECONDITIONS P-04: a status
    # channel reporting success for something it did not do.
    if [ -n "$skip" ]; then
        err="$(printf 'x\n' | grep -vE -- "$skip" 2>&1 >/dev/null)"
        if [ -n "$err" ]; then
            bad "$label — FILTER IS INVALID, this check did not run: $err"
            findings=$((findings + 1)); return 1
        fi
    fi
    hits="$(grep -nEI $flags -- "$rx" "${FILES[@]}" 2>/dev/null)"
    [ -n "$skip" ] && hits="$(printf '%s\n' "$hits" | grep -vE $flags -- "$skip")"
    n="$(printf '%s' "$hits" | grep -c . )"
    if [ "${n:-0}" -eq 0 ]; then ok "$label"; return 0; fi
    bad "$label — $n hit(s)"
    printf '%s\n' "$hits" | head -8 | sed 's/^/         /'
    [ "$n" -gt 8 ] && info "       … and $((n-8)) more"
    findings=$((findings + n))
}

echo
echo "scan-secrets — pre-publish gate (read-only; every line below is a probe run just now)"
echo

check "no device serial"          '\bR5[0-9A-Z]{9}\b|\bRF[0-9A-Z]{8}\b'
# Campaign files need placeholder MACs to describe an attack without naming a real device.
# Filtered BY SHAPE: all six octets identical, the null address plus a low counter, or the classic
# AA:BB:CC:DD:EE:FF. NO BACKREFERENCES — grep -E has none, and a filter that errors silently
# disables its whole check (see check() below). Negative-controlled 2026-08-11: a realistic MAC
# still fails the gate.
check "no real MAC address"       '\b([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}\b' \
                                  '(AA:BB:CC:DD:EE:FF|aa:bb:cc:dd:ee:ff|XX:XX|00:00:00:00:00:[0-9a-fA-F]{1,2}|((00|11|22|33|44|55|66|77|88|99|[aA][aA]|[bB][bB]|[cC][cC]|[dD][dD]|[eE][eE]|[fF][fF]):){5}(00|11|22|33|44|55|66|77|88|99|[aA][aA]|[bB][bB]|[cC][cC]|[dD][dD]|[eE][eE]|[fF][fF]))'
check "no private IPv4"           '\b(10\.[0-9]+\.[0-9]+\.[0-9]+|192\.168\.[0-9]+\.[0-9]+|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]+\.[0-9]+)\b' \
                                  '(10\.0\.0\.(1|10|250)|172\.31\.0\.|192\.168\.(0|1)\.(0|1)|10\.10\.10\.)'
check "no credential literal"     '(psk|passphrase|password|api[_-]?key|token)[[:space:]]*=[[:space:]]*["'"'"']?[A-Za-z0-9/+._-]{8,}' \
                                  '(=\*\)|=VALUE|=<|\$\{|\$[A-Z_]|_v|=""|=$)'
# The tier contract's own Secrets rule has to NAME the paths it is telling you to reference by
# path and never by value; that bullet is the policy, not an instance of breaking it. Filtered
# by the rule's own wording so the filter cannot widen to anything else that mentions the same
# directory. Same discipline as the boot_id filter below: keep it tight enough that a real path
# still fails the gate.
check "no secrets-dir path"       '\.config/secrets|/root/\.ssh|\.credentials\.json|_API\.txt' \
                                  '(KEY="?\$\{KEY|mode 600 under|never by value|wpa_supplicant\.conf`, `~/\.claude)'
# NB: `SortedEssid.lst` unqualified is hcxcapture's own OUTPUT filename and belongs in the
# source. Only a dated capture directory is an engagement artefact. The bare directory is
# not a leak, so the date is what makes a path an instance — which is why the optional
# `diag-` prefix has to be spelled out here rather than widening the character class.
check "no potfile or capture path" 'hashcat\.potfile|/root/Captures/(diag-)?[0-9]|/root/results/[0-9]'
# A campaign file needs a DELIBERATELY FAKE boot id to test that a journal from a foreign boot is
# discarded. Those are placeholders, not leaks — filtered by shape (a first group of one repeated
# character, or deadbeef), which no real boot id has. Judged 2026-08-10; keep the filter tight so a
# real 32-hex id still fails the gate.
check "no boot_id or UUID"        '\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b' \
                                  '\b(00000000|11111111|22222222|33333333|44444444|55555555|66666666|77777777|88888888|99999999|aaaaaaaa|bbbbbbbb|cccccccc|dddddddd|eeeeeeee|ffffffff|deadbeef)-'
# NB: DEFAULT_SSID is rogueap's own configurable default, not an operator SSID. It is
# filtered here as "not a leak" — but see the safety note in README §Portability: a default
# that is attractive to bystanders is an authorisation question, not a privacy one.
check "no SSID literal"           '(ssid|SSID)[[:space:]]*=[[:space:]]*["'"'"'][^"'"'"'$<]{3,}' \
                                  '(rogueap-|DONOTJOIN|DEFAULT_SSID|=\*\)|\$\{|=<|_v)'

# ── Device identity (--public only) ──────────────────────────────────
# The marketing model, the board and the ROM codenames name the handset as surely as a
# serial does, and on a device whose ROM SPOOFS its model they name it twice: a false model
# paired with a real board is rarer than either alone. Case-insensitive because a log line
# writes these upper-case and prose writes them lower-case.
if [ "$PUBLIC" -eq 1 ]; then
    check "no device model or codename" \
        'SM-[A-Z][0-9]{3}[A-Z]?|\bA52\b|galaxy[[:space:]]+a[0-9]{2}|\batoll\b|\bdm1q[a-z]*\b|sm7125|SDM720G|snapdragon[[:space:]_-]*720|ro\.(serialno|product\.(vendor\.)?(model|name|device))' \
        '' '-i'
fi

# ── Cellular identity ─────────────────────────────────────────────────────────────────
# The baseband tooling prints these ready to paste: qmicli and dumpsys emit them as
# `FIELD: value`, so the realistic leak is a quoted line of real output, not a hand-typed
# constant. These four run case-insensitively because that output is upper-case while a
# doc writes the same field in lower-case.
# Every pattern requires a field name FOLLOWED BY A VALUE. A bare field name is how the
# protocol gets documented at all, and PCI, TAC, PSC and SNR are ordinary words elsewhere
# — matching those alone would fire on documentation and teach the reader to skip the
# gate, which costs more than the check is worth.
check "no subscriber identity"    '(imsi|imei|iccid|msisdn|s-?tmsi|guti|supi|suci)[[:space:]]*[=:][[:space:]]*["'"'"']?[0-9A-Fa-f]{6,}' \
                                  '' '-i'
check "no cell identity"          '(cell[ _-]?id|\btac\b|\blac\b|\bpci\b|e?u?arfcn|\bpsc\b)[[:space:]]*[=:][[:space:]]*["'"'"']?[0-9]+' \
                                  '' '-i'
check "no PLMN or operator"       '(mcc|mnc|plmn|operator[ _-]?numeric)[[:space:]]*[=:][[:space:]]*["'"'"']?[0-9]{2,6}' \
                                  '' '-i'
# Signal is weaker than an identifier on its own, but it is what turns a cell tuple into a
# position, and it is the field most likely to be pasted as "harmless" example output.
check "no RF measurement"         '(rsrp|rsrq|rssi|sinr|rscp|ecno)[[:space:]]*[=:][[:space:]]*["'"'"']?-?[0-9]' \
                                  '' '-i'

echo
if [ "$findings" -eq 0 ]; then
    ok "clean — nothing matched"
    echo
    exit 0
fi
bad "$findings finding(s) — review every one before pushing"
info "a hit is not automatically a leak: placeholders, flag names and documentation"
info "examples are expected. Judge each, then either fix it or extend a filter here."
echo
exit 2
