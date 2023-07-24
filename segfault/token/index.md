---
layout: default
title: Enhance your Experience
description: Pimp up your Root Server
---

<div style="text-align:center"><h1>TOKEN TOKEN TOKEN</h1></div>

A TOKEN is a secret string that can upgrade your Root Server:

```sh
### Create a *NEW* server with upgraded resources:
ssh -o "SetEnv TOKEN=SecretTokenChangeMe" root@segfault.net

### Upgrade an *EXISTING* server with upgraded resources:
ssh -o "SetEnv SECRET=YourSecret" root@segfault.net halt # Stop the server
ssh -o "SetEnv TOKEN=SecretTokenChangeMe SECRET=YourSecret" root@segfault.net

# The TOKEN only needs to be set ONCE. All subsequent connects can be done
# without specifying the TOKEN.
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
