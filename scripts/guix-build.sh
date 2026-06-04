#!/bin/sh

# SPDX-FileCopyrightText: 2026 Pier-Hugues Pellerin <ph@heykimo.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

rm -rf /var/cache/apt
groupadd --system guixbuild
for i in $(seq -w 1 10); do
  useradd -g guixbuild -G guixbuild -d /var/empty -s "$(which nologin)" \
          -c "Guix build user $i" --system "guixbuilder$i"
done
