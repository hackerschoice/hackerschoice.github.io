#! /usr/bin/env bash

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

# Return 0 if no xmrig found, 1 if found
find_xmrig() {
	local s s1 pid="$1"
	_xdep gdb || return 255
	_xdep sed || return 255
	_xdep awk || return 255
	while [ $# -ge 1 ]; do
		[ "$1" -le 300 ] && shift 1 && continue
		s=$(grep -F ' rw' <"/proc/${pid}/maps" | cut -f1 -d" " | while read -r x; do _dump_gdb2str "$pid" "$x"; done)
		s1=$(echo "$s" | grep -Eo '(^[48][a-z0-9A-Z]{94}$|new job from [^ ]*:)' | sed 's/new job from //g;s/://g' |_xanew)
		[ "${#s1}" -le 95 ] && continue
		[ -n "$s1" ] && echo $'\033[0m\033[1;31m'">>> XMRIG FOUND with PID $1 [$(strings /proc/$1/cmdline)]"$'\n\033[0;33m'"$s1"
		s1=$(echo "$s" | grep -Eo '^{.{1,200}"pass":.*}}' |tail -n1)
		[ -n "$s1" ] && echo $'\033[2m'"$s1"
		[ -n "$KILL" ] && kill -9 "$1"
		shift 1
	done
	[ -n "$s" ] && {
        [ -z "$KILL" ] && echo -e "\e[0mType \e[1;36mexport KILL=1\e[0m and run the command again to kill all xmrigs."
        echo -e "\e[0m\e[0;35m>>> Contact \e[1;34m\e[4mhttps://thc.org/ops\e[0m\e[0;35m or \e[1;34m\e[4mhttps://t.me/thcorg/124821\e[0;35m [DoomeD] for help.\e[0m"
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
