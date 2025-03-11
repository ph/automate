#!/usr/bin/env sh

# SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

sync
pgrep swaylock || swaylock --screenshots \
			   --clock \
			   --indicator-idle-visible \
			   --indicator-radius 100 \
			   --indicator-thickness 10 \
			   --ignore-empty-password \
			   --ring-color a1efe4 \
			   --key-hl-color ffffff \
			   --line-color 00000000 \
			   --separator-color 00000000 \
			   --text-color ffffff \
			   --effect-blur 7x5 \
			   --fade-in 0.15 \
			   --font "Fira Code" \
