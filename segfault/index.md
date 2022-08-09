---
layout: default
---

<div style="text-align:center">Throw-Away Root Servers</div>

<div style="width:80%; margin:auto">
</div>

### Log in

```shell
ssh root@segfault.net # The password is 'segfault'
```

{:refdef: style="text-align: center;"}
![login screen](sf-login.png){:height="80%" width="80%"}
{: refdef}

### What it does

Segfault offers free unlimitd Root Servers. A new server (inside a Virtual Machine) is created for every SSH connection. 

* Dedicated ```Root Server``` for every user.
* Pre-installed tools on Kali-Linux.
* Outgoing traffic is routed through NordVPN/CryptoStorm/ProtonVPN.
* Transparent TOR to connect to ```.onion``` addresses.
* Log in via ```.onion```, ```.gsocket``` or direct ```ssh```.
* Encrypted DNS traffic (DNS over HTTPS).
* Pre-configured ```.onion``` web server. Just put your files in /onion.
* Encrypted storage in ```/sec``` and ```/home``` with your password. 
* Encrypted storage is only accessible while you are logged in. Keys are wiped on log out.
* Only the user can decrypt the data. We do not have the key.
* No Logs.

### Show me!

The servers are a great place to compile *stuff* and to test *stuff*.

Install any app you like:
```shell
apt install nmap && nmap -thc
```

Work the Internet
```shell
ping -c 3 1.1.1.1
curl ipinfo.io | jq
ssh blah@anotherserver.com
./7350-sshx3-expl openbsd.org
```

Publish your webpage on the Darknet:
```shell
echo "My First File Shared on The Onion Router (TOR) network" >/onion/helloworld.txt
```

Work the DarkNet:
```shell
lynx http://6nhmgdpnyoljh5uzr5kwlatx2u3diou4ldeommfxjz3wkhalzgjqxzqd.onion/
ssh root@ta6kb6vqm3vd7vlgvf7k4nbhfzst2yfy52t6dqzmz2plteewn7ynmtad.onion
```

Connect to IRCNet:
```shell
ssh -t root@segfault.net 'su user -c "irssi -c ircnet -n MyNickName"'
```

We allow port forwarding and proxies:
```shell
ssh -D 1080 root@segfault.net
```
then from another Terminal on your workstation:
```shell
curl -x socks5h://0 ipinfo.io
curl -x socks5h://0 http://6nhmgdpnyoljh5uzr5kwlatx2u3diou4ldeommfxjz3wkhalzgjqxzqd.onion/ 
```

### How it works

To learn more catch me on [Telegram](https://t.me/thcorg) or read the source at [https://github.com/hackerschoice/segfault](https://github.com/hackerschoice/segfault).

### Contact

Twitter: [https://twitter.com/hackerschoice](https://twitter.com/hackerschoice)  
Telegram: [https://t.me/thcorg](https://t.me/thcorg)  
Web: [https://www.thc.org](https://www.thc.org)  
Medium: [https://medium.com/@hackerschoice](https://medium.com/@hackerschoice)  
E-Mail: members@thc.org  
