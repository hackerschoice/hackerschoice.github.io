---
layout: default
title: Segfault / NoKiddie
description: How the pros do it.
---

<!-- <div style="text-align:center"><h1>Frequently Asked Questions</h1></div> -->

<!-- <div style="width:80%; margin:auto">
</div> -->

You can [not mass-scan](../../faq/#scan) from Segfault. The *uplink* VPN provider will block the requests after scanning few hundred hosts.

1. Use your own [Exit Node](../../wireguard).
1. Disable the warning with `touch ~/.nokiddie`

Alternatively go slow and use `-s 100` for Massdns and `-t 100` for shuffledns.
You must use your own [Exit Node](../../wireguard) for masscan.

## Contact

{% include contact-details.md %}
