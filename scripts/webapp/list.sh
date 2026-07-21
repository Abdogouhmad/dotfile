#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cmd_list() {
  local files=()

  for f in "$NIRI_APP_DIR"/*.desktop; do
    [[ -f "$f" ]] || continue
    grep -q "^Exec=.*--new-window" "$f" && files+=("$f")
  done

  if [[ ${#files[@]} -eq 0 ]]; then
    gum style --foreground 9 "  No webapps found."
    return
  fi

  gum style --foreground 12 --bold "  📋 Installed Webapps"
  printf "\n"

  for f in "${files[@]}"; do
    local name slug url icon
    name=$(grep "^Name=" "$f" | cut -d'=' -f2-)
    slug=$(basename "$f" .desktop)
    url=$(grep "^Exec=" "$f" | sed -E 's/.*--new-window "?([^"]+)".*/\1/')
    icon=$(grep "^Icon=" "$f" | cut -d'=' -f2-)
    [[ -n "$icon" ]] && icon="✓" || icon="✗"

    printf "  %-20s %-25s %s\n" "$slug" "$name" "$icon"
  done | gum table --columns "Slug,Name,Icon" --widths "20,25,6" --separator $'\t'

  printf "\n  Total: %d webapps\n" ${#files[@]}
}
