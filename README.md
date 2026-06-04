<!--
SPDX-FileCopyrightText: 2025-2026 Pier-Hugues Pellerin <ph@heykimo.com>

SPDX-License-Identifier: GPL-3.0-or-later
-->

# ph's guix automate

This is how my machines are bootstrap, there are not completely automated but this is a good starts. Due to licensing the `wallpapers` is not included in this directory, I might create a dedicated channel to host the wallpapers.

```
	sudo -E guix time-machine -C ./channels.lock.scm -- -L ./modules ./modules/automate/system/hellboy.scm
```
