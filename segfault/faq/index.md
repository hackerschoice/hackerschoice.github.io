---
layout: default
---

<div style="text-align:center"><h1>Frequenty Asked Questions</h1></div>

<div style="width:80%; margin:auto">
</div>

<a id="lost"></a>
1. **My Question is not answered here**  
   Join our [Telegram channel](https://t.me/thcorg) and ask your question. We will try to answer.
1. **Log in without password**  
Save this SSH key to `~/.ssh/id_sf`. 
```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACB3jmp/3JyvY9ABgjrx4+sBnQ0T+yHsB4HTBMcJqC2OtgAAAIiJ9mzOifZs
zgAAAAtzc2gtZWQyNTUxOQAAACB3jmp/3JyvY9ABgjrx4+sBnQ0T+yHsB4HTBMcJqC2Otg
AAAEAs6YNqZSzAfZDl5/vDOB0vv7EZMxMUc/fEipuZ9A3eCHeOan/cnK9j0AGCOvHj6wGd
DRP7IewHgdMExwmoLY62AAAAAAECAwQF
-----END OPENSSH PRIVATE KEY-----
```
The same key is also available at _/config/guest/id_ed25519_. Thereafter use this command to log in:
```shell
ssh -i ~/.ssh/id_sf root@segfault.net
```
1. **Why are my changes lost?**  
   Data in your home directory and in /sec, /onion and /everyone is permanent and wont get lost (unless you delete the data). Data in (/usr, /tmp, ...) is only valid for the duration of the session and will disappear when you log out. Chances are that you used `apt install` and got a warning. You can use `apt install` but the package can only be used until you log out. Instead tell us and we will install the package to the core system and make it permanentally available. Alternativly you can install any package to `/sec/usr` or [pay for an upgrade](../buy-an-upgrade).
<a id="quota"></a>
1. **Why do I get resource errors**  
   You likely got `out of heap memory`, `resource temporarily unavailable` or `Disk quota exceeded`. The FREE service is [restricted](../youcheapfuck) and the outbound traffic is throttled. Upgrade your server and [enjoy unlimited resources](../buy-an-upgrade).
1. **I get an SSH error**  
   Likely you got `Bad configuration option: setenv` when trying to log in to your existing server. You need to update your OpenSSH client to a newer version (`ssh -V`). Alternatively you can try `SECRET=XXX ssh -o "SendEnv SECRET" root@segfault.net` (where XXX is your _SECRET_).
1. **How can I install services or daemons**  
   Take a look at `/sec/usr/etc/rc.local`. This file is excuted on bootup. There is no systemctl.
1. **How can I publish my Web Page**  
   The Web Page is automatically generated using [Pelican](https://www.getpelican.com) and the awesome Markdown syntax. All you need to do is edit the files in `/sec/www/content` and then execute:
   ```shell
   cd /sec/www && make html
   ```

### Contact

Twitter: [https://twitter.com/hackerschoice](https://twitter.com/hackerschoice)  
Telegram: [https://t.me/thcorg](https://t.me/thcorg)  
Web: [https://www.thc.org](https://www.thc.org)  
Medium: [https://medium.com/@hackerschoice](https://medium.com/@hackerschoice)  
E-Mail: members@thc.org  
