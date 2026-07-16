#!/usr/bin/env bash

set -Eeuo pipefail

DOTFILE_DIR="$HOME/.local/share/dotfile"
CMD=$(git -C "$DOTFILE_DIR" status --short)
count=$(git -C "$DOTFILE_DIR" status --porcelain | wc -l)

# function that sends NTF
notify_me() {
  local title="$1"
  local subtitle="$2"
  notify-send -u critical -i dialog-warning "$title" "$subtitle"
}



# main

if [[ -n "$CMD" ]]; then
    notify_me "Dotfile" "You have $count modified files. Push your dotfiles."
fi
