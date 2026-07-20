#!/usr/bin/env bash

set -Eeuo pipefail

PKG=$(
  pacman -Qq |
    fzf \
      --prompt="Remove package> " \
      --preview 'pacman -Qi {}'
) || exit 0

sudo pacman -Rns --noconfirm "$PKG"
