---
layout: default
title: SSH-IT / How it works
description: Technical details about how SSH-IT works.
---

<!-- Begin of ugly CSS navigation styling hack -->
<style>a[href$="/how-it-works/"] { font-weight: bold; }</style>
<!-- End of ugly CSS navigation styling hack -->

{% include nav-ssh-it-v1.html margin-top="0" margin-bottom="4rem" %}

## How it works

SSH-IT executes the original ssh command inside a fake PTY harness and intercepts any user input and output. None of the system binaries are modified and it does not need `ptrace()`. It does not require root or superuser privileges.

> One day I will add information here... about the nitty gritty details.

## Contact

{% include contact-details.md %}
