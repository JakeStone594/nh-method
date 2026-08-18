# nh common — shared primitives for the wrappers in /usr/local/bin.
# Source with:  . /usr/local/lib/nh/common.sh
# Requires bash. Sourcing has no side effect beyond setting NH_* variables.

[ -n "${NH_COMMON:-}" ] && return 0
NH_COMMON=1

# ---------------------------------------------------------------- output

# Colour is cleared for a non-tty so a redirected report holds no escapes.
if [ -t 1 ]; then
    NH_GRN=$'\033[32m'; NH_RED=$'\033[31m'; NH_YEL=$'\033[33m'
    NH_DIM=$'\033[2m';  NH_BLD=$'\033[1m';  NH_RST=$'\033[0m'
else
    NH_GRN=''; NH_RED=''; NH_YEL=''; NH_DIM=''; NH_BLD=''; NH_RST=''
fi

# Markers are equal width so columns line up. A message that does not fit one
# line is too long: it carries mechanism, which belongs in docs/TOOLS.md.
_nh_mark() { printf '  %s[%s]%s %s\n' "$2" "$1" "$NH_RST" "$3"; }
ok()    { _nh_mark ' ok ' "$NH_GRN" "$*"; }
warn()  { _nh_mark 'warn' "$NH_YEL" "$*" >&2; }
bad()   { _nh_mark 'FAIL' "$NH_RED" "$*" >&2; }
info()  { printf '  %s%s%s\n' "$NH_DIM" "$*" "$NH_RST"; }
title() { printf '%s%s%s\n' "$NH_BLD" "$*" "$NH_RST"; }
step()  { printf '\n%s%s%s\n' "$NH_BLD" "$*" "$NH_RST"; }
# A command stays on its own line, unwrapped, so it can be pasted.
cmd()   { printf '    %s%s%s\n' "$NH_BLD" "$*" "$NH_RST"; }
die()   { printf '%s%s: %s%s\n' "$NH_RED" "${NH_TOOL:-nh}" "$*" "$NH_RST" >&2; exit 1; }

need_root() { [ "$(id -u)" -eq 0 ] || die "must be root"; }

# ---------------------------------------------------------------- probes

# grep behind a pipe is unsafe under pipefail: grep -q exits on the first match,
# the producer takes SIGPIPE, and the pipeline status becomes 141 — turning a
# successful match into a false negative. Count instead of short-circuiting.
#
# rc >=2 means the probe DID NOT RUN — a pattern this grep rejects, or a file it
# cannot read. Reporting that as "no match" is how a broken probe reads as a
# clean result, so say so and return 2. Callers testing it as a boolean are
# unaffected; a caller that needs the distinction can test for 2.
matches() {
    local n rc
    n=$(grep -c "$@" 2>/dev/null); rc=$?
    [ "$rc" -ge 2 ] && { warn "probe did not run (grep rc $rc): grep $*"; return 2; }
    [ "${n:-0}" -gt 0 ]
}

have() { command -v "${1:-}" >/dev/null 2>&1; }

this_boot_id() { cat /proc/sys/kernel/random/boot_id 2>/dev/null; }

# ---------------------------------------------------------------- process identity

# Field 22 of /proc/<pid>/stat. The comm is parenthesised and may contain
# spaces, so the split is on the last ')'.
proc_starttime() {
    local st
    st=$(cat "/proc/${1:-}/stat" 2>/dev/null) || return 1
    st="${st##*) }"
    awk '{print $20}' <<<"$st"
}
proc_comm() { cat "/proc/${1:-}/comm" 2>/dev/null; }

# A child is recorded as pid:starttime:comm. The chroot shares Android's PID
# namespace and /run is persistent, so a pid alone can name a live Android
# process. Never pkill or pgrep by pattern — that matches this tool's own argv.
record_child() {
    local pid="${1:-}" st
    st=$(proc_starttime "$pid") || return 1
    [ -n "$st" ] || return 1
    printf '%s:%s:%s' "$pid" "$st" "$(proc_comm "$pid")"
}
child_field() { printf '%s' "${1:-}" | cut -d: -f"${2:-1}"; }
child_alive() {
    local rec="${1:-}" pid st comm
    [ -n "$rec" ] || return 1
    pid=$(child_field "$rec" 1); st=$(child_field "$rec" 2); comm=$(child_field "$rec" 3)
    [ -n "$pid" ] && [ -d "/proc/$pid" ] || return 1
    [ "$(proc_starttime "$pid")" = "$st" ] || return 1
    [ "$(proc_comm "$pid")" = "$comm" ] || return 1
}
# SIGTERM, then SIGKILL, then re-probe. Refuses a record it cannot attribute.
kill_child() {
    local rec="${1:-}" pid i
    child_alive "$rec" || return 0
    pid=$(child_field "$rec" 1)
    kill -TERM "$pid" 2>/dev/null
    for i in 1 2 3 4 5; do child_alive "$rec" || return 0; sleep 1; done
    kill -KILL "$pid" 2>/dev/null; sleep 1
    child_alive "$rec" && return 1 || return 0
}

# ---------------------------------------------------------------- radio

# Classify a radio by wiphy identity. The name wlan0 is not a radio: phy0 owns
# several netdevs and an external adapter is a separate wiphy.
phy_of()     { iw dev "${1:-}" info 2>/dev/null | awk '/wiphy/{print $2; exit}'; }
iface_type() { iw dev "${1:-}" info 2>/dev/null | awk '/^\ttype /{print $2; exit}'; }
# The internal chip is the phy whose driver is icnss on this device. The NAME
# wlan0 is not the radio: a hwsim phy can take wlan0 and push the real chip to wlan2.
# The PRIMARY netdev is what con_mode and a vif parent need, and it is not simply
# the first match: phy0 carries four netdevs and the glob yields p2p0 first, so
# the secondary vif types are excluded and the lowest ifindex wins — the driver
# registers its primary before any vif. Arming a secondary returns an empty capture.
internal_iface() { local n i t ix best= bi=
                   for n in /sys/class/net/*/phy80211; do
                     [ -e "$n" ] || continue
                     [ "$(basename "$(readlink -f "$n/device/driver" 2>/dev/null)")" = icnss ] || continue
                     i=${n%/phy80211}; i=${i##*/}
                     t=$(iface_type "$i")
                     case "$t" in P2P-device|AP|AP/VLAN|NAN|"mesh point") continue ;; esac
                     ix=$(cat "/sys/class/net/$i/ifindex" 2>/dev/null) || continue
                     [ -z "$bi" ] || [ "$ix" -lt "$bi" ] && { best=$i; bi=$ix; }
                   done
                   [ -n "$best" ] || return 1; printf '%s\n' "$best"; }
internal_phy() { local i; i=$(internal_iface) || return 1; phy_of "$i"; }
is_internal() { local a b; a=$(phy_of "${1:-}"); b=$(internal_phy)
                [ -n "$a" ] && [ -n "$b" ] && [ "$a" = "$b" ]; }

iface_exists() { [ -n "${1:-}" ] && [ -d "/sys/class/net/$1" ]; }
# operstate settles a moment after a link comes up; read it, not the flags.
iface_up()     { grep -qx up "/sys/class/net/${1:-}/operstate" 2>/dev/null; }
iface_assoc()  { iw dev "${1:-}" link 2>/dev/null | matches -F 'Connected to'; }

# The module name is not portable, so the path is globbed.
conmode_path()  { local p; for p in /sys/module/*/parameters/con_mode; do
                    [ -e "$p" ] && { printf '%s' "$p"; return 0; }; done; return 1; }
conmode_value() { local p; p=$(conmode_path) && cat "$p" 2>/dev/null; }

# ---------------------------------------------------------------- routing

# Android keeps no default in main; routes live in per-network policy tables
# whose ids change as networks come and go. Resolve both at run time.
resolve_uplink() { ip route get "${1:-1.1.1.1}" 2>/dev/null | \
    awk 'NR==1{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}'; }
resolve_table()  { ip route get "${1:-1.1.1.1}" 2>/dev/null | \
    awk 'NR==1{for(i=1;i<=NF;i++) if($i=="table"){print $(i+1); exit}}'; }

main_has_default()  { awk 'NR>1 && $2=="00000000"{f=1} END{exit !f}' /proc/net/route; }
main_is_consulted() { ip rule show 2>/dev/null | matches -F 'lookup main'; }

# ip rule show renders the preference as a leading '<pref>:' and never prints
# the word, so a journalled spec ending in 'pref N' cannot be matched literally.
iprule_present() {
    local spec="${1:-}" pref body
    case "$spec" in *" pref "*) pref="${spec##* pref }"; body="${spec% pref *}" ;;
                    *) return 1 ;; esac
    ip rule show 2>/dev/null | matches -F "$pref:	$body" ||
    ip rule show 2>/dev/null | matches -E "^$pref:[[:space:]]+$(printf '%s' "$body" | sed 's/[][\.*^$/]/\\&/g')\$"
}

# ---------------------------------------------------------------- bpffs

# bpffs must be verified by fstype AND by a positive netd pin count. A fresh
# `mount -t bpf` is mount_nodev: right fstype, its own empty pin namespace, and
# every iptables filter/mangle write below it still fails.
bpffs_fstype_ok() { matches -E '^[^ ]+ /sys/fs/bpf bpf ' /proc/mounts; }
bpffs_netd_pins() { ls /sys/fs/bpf/netd_shared 2>/dev/null | wc -l; }
bpffs_ok()        { bpffs_fstype_ok && [ "$(bpffs_netd_pins)" -gt 0 ]; }

iptables_legacy() { iptables -V 2>&1 | matches -F '(legacy)'; }
chain_exists()    { iptables -t "${1:-filter}" -S "${2:-}" >/dev/null 2>&1; }

# ---------------------------------------------------------------- validation

valid_iface() { [[ "${1:-}" =~ ^[A-Za-z0-9_.-]{1,15}$ ]]; }
valid_ipv4()  { local o IFS=.
                [[ "${1:-}" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]] || return 1
                for o in ${1}; do [ "$o" -le 255 ] || return 1; done; }
valid_cc()    { [[ "${1:-}" =~ ^[A-Za-z]{2}$ ]]; }

# Every value-taking option must prove its value exists before consuming it:
# `shift 2` with one positional left shifts nothing and the parse loop spins.
need_val() {
    [ "${2:-0}" -ge 2 ] || die "${1:-flag} needs a value"
    case "${3:-}" in -*) die "${1} needs a value, got the option '${3}'. Use ${1}=${3} if intended" ;; esac
}

# ---------------------------------------------------------------- state journal

# The journal records what this run CHANGED, never what it owns. /run is
# persistent f2fs, so a journal outlives the boot that wrote it while chains,
# ip rules, con_mode and ip_forward do not — a stale one is discarded, never
# replayed, because replaying it would change live state.
# A journal entry is itself a change, so NH_DRY=1 suppresses the write — a dry
# run that journalled would leave a live journal that refuses the next run.
state_set() {
    [ "${NH_DRY:-0}" = 1 ] && return 0
    printf '%s=%q\n' "${1:-}" "${2-}" >> "${NH_STATE:-/dev/null}"
}

state_load() {
    local f="${1:-$NH_STATE}"
    [ -r "$f" ] || return 1
    local bid; bid=$(awk -F= '/^BOOT_ID=/{print $2}' "$f" | tr -d "'\"")
    if [ -n "$bid" ] && [ "$bid" != "$(this_boot_id)" ]; then
        rm -f "$f"; return 1
    fi
    . "$f"
}

# A finished teardown retires its journal so it can never be replayed.
state_retire() {
    local f="${1:-$NH_STATE}"
    [ -f "$f" ] || return 0
    printf 'TORN_DOWN=1\n' >> "$f"
    mv -f "$f" "$f.torn-down"
}

# Refuses an empty, relative or out-of-tree path. Everything here runs as root.
safe_rm() {
    local p="${1:-}" root="${2:-}"
    [ -n "$p" ] && [ -n "$root" ] || return 1
    case "$p" in /*) ;; *) return 1 ;; esac
    case "$p" in "$root"/*) rm -rf -- "$p" ;; *) return 1 ;; esac
}

# ---------------------------------------------------------------- android

# /system/bin/cmd is a native ELF and runs here. The app_process wrappers (am,
# svc, hid, uinput, content) cannot link in the chroot; svc is the exception
# for wifi/data/bluetooth only, which it forwards to cmd.
android() { PATH=/system/bin:/system/xbin:$PATH "$@" 2>/dev/null; }
android_wifi_on() { android settings get global wifi_on | tr -d '\r\n'; }
