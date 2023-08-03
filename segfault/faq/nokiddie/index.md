---
layout: default
title: Segfault / NoKiddie
description: How the pros do it.
---

You can [not mass-scan](../../faq/#scan) from Segfault. The *uplink* VPN provider will block the requests after scanning few hundred hosts.

1. Use your own [Exit Node](../../wireguard).
2. Disable the warning with `touch ~/.nokiddie`

Alternatively go slow and use `-s 100` for Massdns and `-t 100` for shuffledns.
You must use your own [Exit Node](../../wireguard) for masscan.

## Contact

{% include contact-details.md %}
