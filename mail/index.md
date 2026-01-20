---
layout: default
title: A Free Mail Forwarding Service
description: This project allows users to set up a free email forwarder.
---

<!-- <div style="text-align:center"><h1>{{ page.title }}</h1></div> -->

This project allows you to set up an email forward from `<yourname>@segfault.net` to any email address of your choosing.


## Setup


Please see [https://forward.haltman.io/](https://forward.haltman.io/) for now.

This will forward any email to `foobar@segfault.net` to `hackbart@tuta.io`:

```shell
curl 'https://mail.thc.org/register?name=foobar&to=hackbart@tuta.io'
```

## Available domains

1. @segfault.net
1. @smokes.thc.org

## Use your own domain

You can use your own domain as well!. To do so set the MX record of your domain like this:

```
yourdomain.com.                   MX     1  mx1.mail.segfautl.net.
yourdomain.com.                   MX     5  mx2.mail.segfault.net.
yourdomain.com.                   TXT       "v=spf1 mx ~all"
31337._domainkey.yourdomain.com.  CNAME     dkim.mail.segfault.net. 
```

If you have a cool domain then please let us know and we will add it to the list of available domains.

## Why

Because we can. This project is maintained by [Extencil](extencil@proton.thc.org).

THIS IS BETA TESTING AT THE MOMENT. TALK TO US IF YOU LIKE TO SEE ANY SPECIFIC FEATURES.

## Contact

{% include contact-details.md %}
