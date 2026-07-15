#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/lib.sh"

spinner "Cleaning package cache..." \
    sudo paccache -r

orphans="$(pacman -Qtdq || true)"

if [[ -n "$orphans" ]]; then
    spinner "Removing orphan packages..." \
        sudo pacman -Rns --noconfirm $orphans
fi

spinner "Cleaning AUR cache..." \
    yay -Sc --noconfirm

success "Cleanup completed."
