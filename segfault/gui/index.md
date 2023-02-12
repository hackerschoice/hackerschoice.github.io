---
layout: default
title: segfault - GUI
---

<div style="text-align:center"><h1>Graphical User Interface</h1></div>

<div style="width:80%; margin:auto">
</div>

Use Firefox, Brave, Wireshark, Sublime, Geany and any of your favourite applications on a remote desktop. All outbound traffic is routed via VPNs.

{:refdef: style="text-align: center;"}
![gui](sf-gui.png){:height="80%" width="80%"}
{: refdef}

---

{:refdef: style="text-align: center;"}
# THIS IS BETA TESTING. IT ONLY WORKS ON:
# beta.segfault.net
{: refdef}

```shell
ssh root@beta.segfault.net # Password is 'segfault'
```

---

There are a few ways to access a GUI.

### GUI via VNC

Log in to your [root server](../) and type:
```shell
startvnc
```

Thereafter use your favourite VNC Client and connect to `127.0.0.1:5900`.

### GUI via Web

Log in to your [root server](../) and type:
```shell
startxweb
```

Thereafter use your Web Browser and go to [http://127.0.0.1:2000](http://127.0.0.1:2000).

### GUI via XPRA

Install [XPRA](https://xpra.org/) on your workstation (not server).

Connect to your existing [root server](../) (replace `FluffyBunny` with the name of your root server):
```shell
xpra start ssh://root@FluffyBunny/ --start-child=xterm-dark 
```

Or start Firefox on a fresh new disposable [root server](../) (which will self-destruct when Firefox stops):
```shell
xpra start ssh://root@beta.segfault.net/ --start-child=firefox --ssh=ssh --ssh-upgrade=no
```

### IT'S BUGGERED

Some applications may not work. Chances are that your server does not have enough memory. Be a badass and [buy an upgrade](../buy-an-upgrade) to make all applications work flawlessly.

### Contact

~~Twitter: [https://twitter.com/hackerschoice](https://twitter.com/hackerschoice)~~  
Mastodon: [@thc@infosec.exchange](https://infosec.exchange/@thc)  
Telegram: [https://t.me/thcorg](https://t.me/thcorg)  
Web: [https://www.thc.org](https://www.thc.org)  
Medium: [https://medium.com/@hackerschoice](https://medium.com/@hackerschoice)  
E-Mail: members@thc.org  