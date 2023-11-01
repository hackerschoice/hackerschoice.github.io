---
layout: default
title: Segfault / FAQ
description: Frequently asked questions related to Segfault.
---

<!-- Begin of ugly CSS navigation styling hack -->
<style>a[href$="/faq/"] { font-weight: bold; }</style>
<!-- End of ugly CSS navigation styling hack -->

{% include nav-segfault-v1.html margin-top="0" margin-bottom="4rem" %}

<div style="text-align:center"><h1>Need some help?</h1></div>

1. **My Question is not answered here**  
   Join our [Telegram channel](https://t.me/thcorg) and ask your question. We will try to answer.

1. **I have a problem on my Root Server**<a id="help"></a>  
   Join our [Telegram channel](https://t.me/thcorg) and send us the output of `echo "$SF_HOSTNAME $SF_LID $SF_FQDN"` or a screenshot and explain your problem (what you expect to see or happen and what you see or what happens instead).

1. **Can I do stupid things?**<a id=stupid></a>  
   No. You can not mine crypto or use segfault to do stupid or illegal things. This is not a warez trading platform either. It's also not a 'cheap way to access the Internet anonymously' - buy your own [VPN](https://www.mullvad.net). Go away unless you are doing research or working on some great project. Join our [Telegram Channel](https://t.me/thcorg) (especially if you are new): Participate & discuss.

1. **How do I log back in to my server?**<a id=reconnect></a>  
   On log out you will see a *command* that allows to you to log back in to your server. It contains a `SECRET` and it is this `SECRET` that allows you access your server. The log out screen may look like this:

   ```
   Access with      : ssh -o "SetEnv SECRET=XXX..." root@NNN.segfault.net
   GOODBYE          : Join us on Telegram - https://t.me/thcorg 
   ```

   Use the command `ssh -o "SetEnv SECRET=XXX...` and the password `segfault` to log back in to your server. If you do not use the same SECRET and instead just do `ssh root@segfault.net` then a new server with a new /sec filesystem will be created for you. Alternatively use `ssh secret@NNN.segfault.net` with the password `segfault` and, when asked, your SECRET. There is also help for [PuTTy](putty/), [WinSCP](winscp/) and [Termius](termius/).

1. **My files are gone when I log back in again**  
   You did not set the `-o SetEnv "SECRET=XXX..."`. This means a brand new server was created when you logged in the second time.

1. **How long will the server run?**  
   Forever if you stay logged in (active session) or log in at least once every 6 days. Auto-shutdown may occur if there is no shell running (in tmux or screen) and nobody has logged in for 1.5 days. A server may shut down during major software upgrades or due to abuse. No data in /sec is ever deleted or lost (even if shut down) and your data in /sec becomes available again on your next log in (but you may have to start your background processes again). These limits do not apply to [cool users](../upgrade/).

1. **My processes disappear after I log out**  
   See above.

1. **Why are my changes lost?**<a id="lost"></a>  
   Data in your home directory and in /sec, /onion and /everyone are never lost. They are permanent (unless you delete the data). Data in (/usr, /tmp, ...) is only valid for the duration of the session and will disappear when you log out. You can use `apt install` and `pipx install` etc but the package can only be used until you log out. Alternatively you can install any package to `/sec/usr`.

1. **Why do I get resource errors?**<a id="quota"></a>  
   You likely got `out of heap memory`, `resource temporarily unavailable` or `Disk quota exceeded`. The FREE service is [restricted](../free/) and the outbound traffic is throttled. Ask us for a secret [token](../token/) to get more resources. Tokens are FREE for anyone working on a cool project.

1. **My processes are getting killed**  
   Read above.

1. **Can I scan?**<a id=scan></a>  
   It is [discouraged](nokiddie/). The scan will slow to 2ports/second after the first 8,000 ports. Use your [own EXIT node](../wireguard/) for mass scanning.

1. **I get an SSH error**  
   Likely you got `Bad configuration option: setenv` when trying to log in to your existing server. You need to update your OpenSSH client to a newer version (`ssh -V`). Alternatively you can try `SECRET=XXX ssh -o "SendEnv SECRET" root@segfault.net` (where XXX is your _SECRET_) or ssh to `secret@segfault.net`.

1. **How can I install services or daemons?**  
   Take a look at `/sec/usr/etc/rc.local`. This file is executed on bootup. There is no systemd/systemctl.

1. **How can I start a Web Browse, VNC or GUI?**  
   1. Use [https://shell.segfault.net](https://shell.segfault.net). Click "I'm new here" to create a new server. Click "I've been here" to log in to your existing server: Take your SECRET and prefix it with the short server name. Example Secret: `8lgm-XXX...`.
   1. Log in with SSH start a VNC session: `ssh -L5900:0:5900 <servername>` and execute `startxvnc`. Then connect with VNC to 127.0.0.1:5900
   1. Log in with SSH, start a XPRA session: `ssh -L2000:0:2000 <servername>` and then browse to http://127.0.0.1:2000.
   <p>
1. **How can I publish my Web Page?**  
   The Web Page is automatically generated using [Pelican](https://www.getpelican.com) and the awesome Markdown syntax. All you need to do is edit the files in `/sec/www/content` and then execute:

   ```shell
   cd /sec/www && make html
   ```

1. **How do I change the password?**  
   You can not. The access password is always `segfault`. However, nobody can access your server using `segfault` as a password: The system generates a unique and new `SECRET` for every new log in and then uses this SECRET to set up your private virtual server (isolated from all other servers). It is this SECRET that allows only you to access *your* server. Read the next paragraph...  

1. **When does it self-destruct?**  
   Immediately on log out or when you type `halt`. Your server shuts down and all system data and memory is wiped. Your private data in /sec and /root is only accessible while your server is running. When you log back in using the same `SECRET` then your server starts up again and your (old) private data is attached again to /sec (encrypted). You can wipe all data (including your encrypted data) by typing `destruct`.

1. **What EXIT IP is used?**  
   There are 3 or more _EXIT IP_ lines shown during log in. These are the VPN providers through which your outgoing traffic is routed. Each of your outgoing connections leaves through a different EXIT (multipath routing). The VPN Exit Nodes cycle every few days.

1. **Is there a list of tools?**  
   The server comes with around 54GB of pre-installed tools. See the [full list](https://github.com/hackerschoice/segfault/blob/main/guest/Dockerfile). Let us know if any tool is missing and we can add it (permanently).

1. **How to upload/download files?**<a id="data"></a>  
   Use `scp -o "SetEnv SECRET=XXX..." root@...` or the shorter version `scp <servername>`. Alternatively log in with the port forward shown below, type `startfb` and then point your browser to http://127.0.0.1:2900

   ```
   ssh -L2900:0:2900 -o "SetEnv SECRET=XXX..." root@<servername>
   startfb
   ```
   Alternatively:
   1. Read [How do I run a webserver on a permanent reverse Tunnel](#web) to access your files via Cloudflare.
   1. Copy your files to /onion and download them via TOR.
   1. Use [rsync](https://github.com/hackerschoice/thc-tips-tricks-hacks-cheat-sheet#rsync) via the reverse Port.
   <p>
1. **Log in without password**<a id=autologin></a>   
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

   The same key is also available at `/config/guest/id_ed25519`. Add these lines to your `~/.ssh/config` on your workstation (not the root server!):
   
   ```
   host your-server-name
      User root
      HostName teso.segfault.net
      IdentityFile ~/.ssh/id_sf
      SetEnv SECRET=YOUR-SECRET
   ```
   (Replace teso.segfault.net with the correct server name (`echo $SF_FQDN`). Replace `YOUR-SECRET` with your server's secret).

   Thereafter use any of these commands:

   ```shell
   ssh  your-server-name
   sftp your-server-name
   scp  your-server-name:stuff.tar.gz ~/
   ```

1. **SSH ProxyJump and -N are not working**<a id="proxy"></a>  
   There is a workaround. Log in to your root server with `ssh -D1080 ...`. Keep this shell open and alive. Then (from a different terminal on your workstation) execute:
   
   ```
   ssh -o ProxyCommand='socat - "SOCKS4A:0:%h:%p,socksuser=nobody|tcp:0:1080"' user@remotehost.foo
   ```

   or make an entry for 'user@remotehost.foo' in your ~/.ssh/config file:
   ```
   Host remotehost
      hostname remotehost.foo
      ProxyCommand socat - "SOCKS4A:0:%h:%p,socksuser=nobody|tcp:0:1080"
   ```
   and use `ssh user@remotehost` to log in.  

   (For socat2 use `socat2 - "SOCKS4A:%h:%p|tcp:0:1080"`)


1. **How do I use reverse Port Forwarding?**<a id="fwd"></a>  
   Your server runs on a private IP space. You can connect out (to the Internet) but nobody can connect back to your server. However, your server is assigned **one** PORT on a public IP address (for reverse back connections). The IP & PORT are unique to your server. During log in you will see a message that looks like this (example):

   ```
   [...]
   Reverse Port      : 185.117.118.23:1234
   [...]
   ```

   That's your personal IP & PORT for reverse connections. Any connection to 185.117.118.23 on Port 1234 is forwarded to your server on port 1234. You can listen for the connection like so:

   ```
   nc -vnlp 1234
   # If this is for a connect-back shell then you likely like to press
   # Ctrl-Z after connection and type 'stty raw -echo opost; fg'
   ```

   (The IP & PORT are an example. You need to read the log in message when you log in to find out your IP and PORT or check `/config/self/reverse_*`. The IP and PORT are temporary and may change every few days.).

1. **Can I use OpenVPN?**<a id="vpn"></a>  
   No. Use WireGuard instead: [https://thc.org/segfault/wireguard](../wireguard).

1. **How do I run a webserver on the reverse Port Forward?**<a id="web"></a>

   ```shell
   echo "Folder ${CDY}$(pwd)${CN} is now shared at ${CB}${CUL}http://$(</config/self/reverse_ip):$(</config/self/reverse_port)${CN}"
   python -m http.server "$(</config/self/reverse_port)"
   ```
   (Use for temporary sharing only. The reverse port may change at any time.)

1. **How do I run a webserver on a permanent reverse Tunnel?**<a id="web"></a>

   ```shell
   cd /onion
   (python -m http.server 8080 &>/dev/null &)
   cloudflared tunnel --url http://localhost:8080 --no-autoupdate
   ```
   Your HTTPS URL will be shown to you (it looks like `https://blah-foo-one-two.trycloudflare.com`). Optionally start the tunnel inside `tmux` so that the tunnel stays connected after you exit your SSH session. [Keep reading...](https://github.com/hackerschoice/thc-tips-tricks-hacks-cheat-sheet/blob/master/README.md#https)

## Contact

{% include contact-details.md %}
