#! /usr/bin/env bash

# Detect XMRig cryptocurrency miner processes in memory and optionally kill them.
# Supports both normal and UPX packed binaries.
# Extract wallet addresses if possible.

# Usage:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/thc-org/hackshell/main/xmrig-remover.sh)"
# bash -c "$(curl -fsSL https://thc.org/xmrig)"

_xanew() {
    awk 'hit[$0]==0 {hit[$0]=1; print $0}'
}
_dump_gdb2str() {
	gdb --batch --pid "$1" "/proc/${1}/exe" -ex "dump memory /dev/stdout 0x${2%%-*} 0x${2##*-}" 2>/dev/null | strings -n95
}
_xdep() {
	command -v "$1" >/dev/null 2>&1 || { echo "Please install $1"; return 255; }
}
_hs_gdb_proc_match() {
    local pid="${1:?}"
    local pattern="${2:?}"
    grep -F ' r-' <"/proc/${pid}/maps" | cut -f1 -d" " | while read -r x; do
        gdb --batch --pid "$pid" "/proc/${pid}/exe" -ex "dump memory /dev/stdout 0x${x%%-*} 0x${x##*-}" 2>/dev/null | grep -Fqam1 "${pattern}" && {
            echo "${pid:-BAD}"
            return 0
        }
    done
}
_warn_upx_exe() {
    local pid
    unset _HS_UPX_PIDS
    for x in /proc/[123456789]*/exe; do
        [ ! -e "$x" ] && continue
        pid="${x:6}"
        pid="${pid%%/*}"
        [ "$pid" -le 300 ] && continue
        dd bs=1k count=1 if="$x" 2>/dev/null | grep -Fqam1 'UPX!' && {
            _HS_UPX_PIDS+=("${pid}")
        }
    done
}

_print_found() {
	local pid="$1"
	echo $'\033[0m\033[1;31m'">>> XMRIG FOUND with PID $pid [$(strings /proc/$pid/cmdline|tr '[\r\n]' ' ' | cut -c -${COLUMNS:-80})]"
}

_kill_xmrig() {
	local pid="$1"
	kill -9 "$pid" 2>/dev/null && echo -e "\e[0;32m>>> Killed XMRig process with PID $pid\e[0m"
}

_print_help() {
	[ -z "$KILL" ] && echo -e "\e[0mType \e[1;36mexport KILL=1\e[0m and run the command again to kill all xmrigs."
	echo -e "\e[0m\e[0;35m>>> Contact \e[1;34m\e[4mhttps://thc.org/ops\e[0m\e[0;35m or \e[1;34m\e[4mhttps://t.me/thcorg/124821\e[0;35m [DoomeD] for help.\e[0m"
}

# Return 0 if no xmrig found, 1 if found
find_xmrig() {
	local s s1 pid="$1"
	_xdep gdb || return 255
	_xdep sed || return 255
	_xdep awk || return 255

	# Try to extact wallet address from rw memory segments (normal and UPX packed bins)
	while [ $# -ge 1 ]; do
		pid="$1"
		shift 1
		[ "$pid" -le 300 ] && continue
		s=$(grep -F ' rw' <"/proc/${pid}/maps" | cut -f1 -d" " | while read -r x; do _dump_gdb2str "$pid" "$x"; done)
		s1=$(echo "$s" | grep -Eo '(^[48][a-z0-9A-Z]{94}$|new job from [^ ]*:)' | sed 's/new job from //g;s/://g' |_xanew)
		[ "${#s1}" -le 95 ] && continue
		[ -n "$s1" ] && echo "$(_print_found "$pid")"$'\n\033[0;33m'"$s1"
		# output json line
		s1=$(echo "$s" | grep -Eo '^{.{1,200}"pass":.*}}' |tail -n1)
		[ -n "$s1" ] && echo $'\033[2m'"$s1"
		[ -n "$KILL" ] && _kill_xmrig "$pid"
	done
	[ -n "$s" ] && {
		_print_help
        return 1
    }

	# Kill it anyhow even if we fail to dump 
	_warn_upx_exe
	s=($(grep -HoaFm1 'XMRIG_VERSION' /proc/*/exe /dev/null 2>/dev/null | sed 's|[^0-9]||g'))
    # Analyze every UPX packed process for XMRIG_VERSION string
    for x in "${_HS_UPX_PIDS[@]}"; do
        s+=($(_hs_gdb_proc_match "${x}" 'XMRIG_VERSION'))
    done
	for pid in "${s[@]}"; do
		echo "$(_print_found "$pid")"$'\n\033[0;33m'"(Could not extract wallet address)"
		[ -n "$KILL" ] && _kill_xmrig "$pid"
	done
	[ "${#s[@]}" -gt 0 ] && {
		_print_help
        return 1
    }

    echo "No XMRig processes found."
	[ -z "$ALL" ] && echo -e "Type \e[1;36mexport ALL=1\e[0m and try again."
}

[ -n "$ALL" ] && pids=($(find /proc -maxdepth 2 -name exe | sed 's|[^0-9]||g'))
[ -z "$ALL" ] && pids=($(shopt -s nullglob 2>/dev/null;grep -HEoam1 '(XMRIG_VERSION|Id: UPX )' /proc/*/exe /dev/null 2>/dev/null | sed 's|[^0-9]||g'))
find_xmrig "${pids[@]}"
exit
# unset -f _xanew _dump_gdb2str
# return "$r"
#:
