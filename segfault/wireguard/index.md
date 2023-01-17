---
layout: default
---

<div style="text-align:center"><h1>WireGuard Reverse Connection</h1>  
Configure your Root Server to send all traffic via another server you own</div>

<div style="text-align:center"><h2>BETA TESTING. ONLY WORKS ON beta.segfault.net.</h2></div>  

---
A typical use case is where you like to connect to workstations on a remote private LAN (e.g. with nmap, metasploit, smbscan, ...). A network interface will (magically) appear on your [Root Server](../) and that interface is *virtually* located inside the remote private LAN.

Another often used scenario is to reach the Internet via the remote private LAN (*Exit Node*). All your traffic will appear as if originating from the *Exit Node*. This is particularly useful for mass-scanning.

The setup uses a *reverse connection* and the *Exit Node* can be behind a firewalled NAT gateway. The *Exit Node* can be Linux, Windows or OSX and no superuser privileges are needed.

---
### Step #1 - On your Root Server

Create and activate a WireGuard interface:
```shell
curl rpc/net/up
```
Write down either the Wiretap or WireGuard configuration.
{:refdef: style="text-align: center;"}
![login screen](wg-up2.png){:height="80%" width="80%"}
{: refdef}

### Step #2 - On the Exit Node

The Exit Node is any host (Linux, Windows, OSX) you have access to and which network you like to connect to from your [Root Server](../).  

Use either Wiretap or WireGuard.

1. __Wiretap:__  
Install the pre-compiled single [Wiretap binary](https://github.com/sandialabs/wiretap/releases/tag/v0.1.0) for Linux, Windows or OSX. Execute the Wiretap command as shown in the output from your *curl rpc/net/up* command in Step #1.

1. __WireGuard:__  
Install & configure [WireGuard](https://www.wireguard.com/). Use the configuration as shown in the output from your *curl rpc/net/up* command in Step #1.


On your [Root Server](../) check the connection:
```shell
curl rpc/net/show
```

### More Shenanigans

Each command is executted on the [Root Server](../) (after the Exit Node has connected).

Scan the remote private LAN:
```
nmap -n -sT -T4 -F --open --script=banner 192.168.0.0/24
```

Crackmapexec the LAN:
```
cme smb 192.168.0.0/24
```

Find Window shares on the LAN:
```
nbtscan 192.168.0.0/24
```

SNMP dump
```
snmp-check 192.168.0.250
```

Log in to a workstation (Remote Desktop/RDP) on the LAN:
```
startxweb
remmina -c rdp://username@server
```

Poke [the lion](police-cars-police-chase.gif) and appear as if originating from the LAN:
```
amass enum -d nsa.gov
```


...and other [Hacks, Tips and Tricks](tricks.html).

### Contact

~~Twitter: [https://twitter.com/hackerschoice](https://twitter.com/hackerschoice)~~  
Mastodon: [@thc@infosec.exchange](https://infosec.exchange/@thc)  
Telegram: [https://t.me/thcorg](https://t.me/thcorg)  
Web: [https://www.thc.org](https://www.thc.org)  
Medium: [https://medium.com/@hackerschoice](https://medium.com/@hackerschoice)  
E-Mail: members@thc.org  


