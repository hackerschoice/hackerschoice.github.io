---
layout: default
title: SSH-IT | How it works
decription: Technical details about how SSH-IT works.
---

## How it works

SSH-IT executes the original ssh command inside a fake PTY harness and intercepts any user input and output. None of the system binaries are modified and it does not need `ptrace()`. It does not require root or superuser privileges.

> One day I will add information here... about the nitty gritty details.

## Contact

{% include contact-details.md %}
