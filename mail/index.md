---
layout: default
title: A Free Mail Forwarding Service
description: This project allows users to set up a free email forwarder.
---

<!-- <div style="text-align:center"><h1>{{ page.title }}</h1></div> -->

<video controls autoplay muted width="80%" style="display: block; margin: 0 auto; margin-bottom:15px;">
  <source src="mail-forwarding-demo.mp4" type="video/mp4">
  Your browser does not support the tutorial video.
</video>

This project allows you to set up an email forward from `<yourname>@segfault.net` to any email address of your choosing.

## Setup

Use the interactive UI [https://mail.thc.org/](https://mail.thc.org/) (recommended)

Or, try the OG mode: 
This will forward any email to `foobar@segfault.net` to `hackbart@tuta.io`:

```shell
curl 'https://mail.haltman.io/forward/subscribe?name=foobar&to=hackbart@tuta.io'

```

## Available domains

1. @segfault.net
2. @smokes.thc.org
3. @abin.lat
4. @the.hackerschoice.org
5. @thc.extencil.me
6. and many more;

## Use your own domain

You can use your own domain as well! To do so follow the official guides:
* [https://docs.haltman.io/knowledge-base/mail-forwarding/add-my-own-domain](https://docs.haltman.io/knowledge-base/mail-forwarding/add-my-own-domain)
* [https://docs.haltman.io/knowledge-base/mail-forwarding/add-my-own-subdomain](https://docs.haltman.io/knowledge-base/mail-forwarding/add-my-own-subdomain)

If you have a cool domain then please let us know and we will add it to the list of available domains.

## Why

Because we can. This project is maintained by [Extencil](extencil@proton.thc.org).

THIS IS BETA TESTING AT THE MOMENT. TALK TO US IF YOU LIKE TO SEE ANY SPECIFIC FEATURES.

## Contact

{% include contact-details.md %}
