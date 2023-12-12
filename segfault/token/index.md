---
layout: default
title: Enhance your Experience
description: Pimp up your Root Server
---

<!-- Begin of ugly CSS navigation styling hack -->
<style>a[href$="/token/"] { font-weight: bold; }</style>
<!-- End of ugly CSS navigation styling hack -->

{% include nav-segfault-v1.html margin-top="0" margin-bottom="4rem" %}

<div style="text-align:center"><h1>TOKEN TOKEN TOKEN</h1></div>

A TOKEN is a secret string to upgrade your Root Server:

```sh
### Log in to your root server and type:
curl sf/set -d token=SecretTokenChangeMe && reboot
```

```sh
### Wait 30 seconds.
### Then log back in to your Root Server and check the increased resources:
cat /config/self/limits
```

TOKENS give you more bandwidth, processing power, storage space and allow you to log in to your Root Server when there is a contention for resources (e.g. when under attack). 

Tokens are available from the [SysCops](https://t.me/thcorg). They are not for sale but we hand them out rather freely. Here are a few tips how to get a Token:

 * Participate in the discussions.
 * Share your ideas, comments and concerns.
 * Find bugs.
 * Join our efforts. Help us.
 * Work on great projects.
 * Save the world.

[Contact us on Telegram](https://t.me/thcorg).

If you are a corporate or are using our service for commercial reasons or gain other financial benefits or favours then you must [donate some big dough](../upgrade).

## Contact

{% include contact-details.md %}
