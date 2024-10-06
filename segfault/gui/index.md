---
layout: default
title: Segfault / GUI
description: Use Firefox, Brave, Wireshark, Sublime, Geany and any of your favourite applications on a remote desktop with Segfault.
---

<!-- Begin of ugly CSS navigation styling hack -->
<style>a[href$="/gui/"] { font-weight: bold; }</style>
<!-- End of ugly CSS navigation styling hack -->

{% include nav-segfault-v1.html margin-top="0" margin-bottom="4rem" %}

<div style="text-align:center">
    <h1>Graphical User Interface</h1>
    <p>Use Firefox, Brave, Wireshark, Sublime, Geany and any of your favourite applications on a remote desktop. All outbound traffic is routed via VPNs.</p>
</div>

{:refdef: style="text-align: center;"}
![gui](sf-gui.png){:height="80%" width="80%"}
{: refdef}

---

## GUI via your Web Browser
The easiest way to connect to the graphical interface is through your Web Browser.

<video controls autoplay muted width="80%" style="display: block; margin: 0 auto;">
  <source src="https://github.com/user-attachments/assets/53138a23-e28e-489c-baa1-48f59b4a1e52" type="video/mp4">
  Your browser does not support the video. You can watch the tutorial at this URL: https://github.com/user-attachments/assets/53138a23-e28e-489c-baa1-48f59b4a1e52
</video>

1. Go to https://shell.segfault.net
2. Choose "I'm New Here" to generate a new server. If you already have a previously generated server, you can choose "I've Been Here" and enter the Host name and Secret in this format: "adm-ExampleSecretChangeMe".<br>**IMPORTANT:** at this time, only adm and 8lgm hosts are supported. You can check the list of supported hosts in the SF-UI source code: https://github.com/messede-degod/SF-UI
3. Please wait for connection.
4. In the left navigation menu, click "Desktop." It's the icon shaped like a computer monitor.

Connect to your shell:

```shell
# Execute this command on your WORKSTATION, _not_ on the segfault root shell.
ssh -L2000:0:2000 -L5900:0:5900 root@segfault.net # Password is 'segfault'
```

<div style="text-align:center"><p>There are a few ways to access a GUI.</p></div>

## GUI via Web

Log in to your [root server](../) and type:

```shell
startxweb
```

Thereafter use your Web Browser and go to [http://127.0.0.1:2000](http://127.0.0.1:2000).

## GUI via VNC

Log in to your [root server](../) and type:

```shell
startxvnc
```

Thereafter use your favourite VNC Client and connect to `127.0.0.1:5900`.

## GUI via TigerVNC

```shell
vncserver -SecurityTypes None :0
```

Thereafter use your favourite VNC client and connect to `127.0.0.1:5900`.

## GUI via XPRA

Install [XPRA](https://xpra.org/) on your workstation (not server).

Connect to your existing [root server](../) (replace `FluffyBunny` with the name of your root server):

```shell
xpra start ssh://root@FluffyBunny/ --start-child=xterm-dark --ssh=ssh --ssh-upgrade=no
```

Or start Firefox on a fresh new disposable [root server](../) (which will self-destruct when Firefox stops):

```shell
xpra start ssh://root@segfault.net/ --start-child=firefox --ssh=ssh --ssh-upgrade=no
```

## IT'S BUGGERED

Some applications may not work. Chances are that your server does not have enough memory. Be a __badass__ and [upgrade your server](../upgrade) to make all applications work flawlessly.

## Contact

{% include contact-details.md %}
