---
layout: default
---

<div style="text-align:center"><h1>WireGuard Reverse Connection</h1>  
Configure your Root Server to send all traffic via another server you own</div>

<div style="text-align:center"><h2>BETA TESTING. ONLY WORKS ON beta.segfault.net.</h2></div>  

---
A typical use case is where you like to connect to workstations in a remote private LAN from your [Root Server](../) (e.g. with nmap, metasploit, smbscan, ...). A network interface will (magically) appear on your Root Server and that interface is *virtually* located in the remote private LAN.

Another often used scenario is to route all port scanning traffic via your own *Exit Node*.

The setup uses a *reverse connection* and the *Exit Node* can be behind a firewalled NAT gateway. The *Exit Node* can be Linux, Windows or OSX and no superuser privileges are needed.

---
### Step #1 - On your root server

Create a WireGuard keypair and allocate a UDP Port to your [Root Server](../):
```shell
curl rpc/net/init -d name=NameOfExit
```
In this example the UDP Port is 64050. Write down either the Wiretap or WireGuard configuration.
{:refdef: style="text-align: center;"}
![login screen](wg-init.png){:height="80%" width="80%"}
{: refdef}


Bring up the WireGuard Interface:
```shell
curl rpc/net/up -d name=NameOfExit
ip addr show
```

(You should see the new network interface named *wgNameOfExit* on your [Root Server](../)).

### Step #2 - On the Exit Node

Use either Wiretap or WireGuard.

1. __Wiretap:__  
Install the pre-compiled single [Wiretap binary](https://github.com/sandialabs/wiretap/releases/tag/v0.1.0) for Linux, Windows or OSX. Execute the Wiretap command as shown in the output from your *curl rpc/net/init* command in Step #1.

1. __WireGuard:__  
Install & configure [WireGuard](https://www.wireguard.com/). Use the configuration as shown in the output from your *curl rpc/net/init* command in Step #1.


On your root server check the connection:
```shell
curl rpc/net/show
```

### More Shenanigans

More *reverse* WireGuard [Hacks, Tips and Tricks](tricks.html).

### Contact

~~Twitter: [https://twitter.com/hackerschoice](https://twitter.com/hackerschoice)~~  
Mastodon: [@thc@infosec.exchange](https://infosec.exchange/@thc)  
Telegram: [https://t.me/thcorg](https://t.me/thcorg)  
Web: [https://www.thc.org](https://www.thc.org)  
Medium: [https://medium.com/@hackerschoice](https://medium.com/@hackerschoice)  
E-Mail: members@thc.org  
