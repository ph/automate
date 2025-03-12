<!--
SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>

SPDX-License-Identifier: GPL-3.0-or-later
-->

# ph's guix automate

This is how my machines are bootstrap, there are not completely automated but this is a good starts. Due to licensing the `wallpapers` is not included in this directory, I might create a dedicated channel to host the wallpapers.

The following steps are required to completely updated the current machine:

- `guix pull`
- `make apply`

There are tasks to only reconfigure the _system_ or the _home_:

- `make system`
- `make home`
