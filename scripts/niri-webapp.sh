#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPTS_DIR="$SCRIPT_DIR/webapp"

source "$SCRIPTS_DIR/lib.sh"
source "$SCRIPTS_DIR/install.sh"
source "$SCRIPTS_DIR/list.sh"
source "$SCRIPTS_DIR/remove.sh"

trap niri_cleanup EXIT

########################################
# Dashboard (Interactive Mode)
########################################

dashboard() {
  niri_ensure_dirs

  while true; do
    clear 2>/dev/null || true

    # Header
    gum style \
      --foreground 12 --border-foreground 12 --border double \
      --align center --width 50 --margin "1 2" \
      "  NIRI WEBAPP MANAGER  "

    gum style --foreground 8 --align center --width 50 \
      "Turn any website into a desktop app"

    printf "\n"

    local choice
    choice=$(gum choose \
      --header="  What would you like to do?" \
      --cursor="  ▸ " \
      "  📦  Install new webapp" \
      "  📋  List installed webapps" \
      "  🗑️   Remove webapp" \
      "  ❌  Exit")

    printf "\n"

    case "$choice" in
    *Install*)
      cmd_install
      ;;
    *List*)
      cmd_list
      gum confirm "Back to menu?" --default=true --affirmative="Yes" --negative="No" || break
      ;;
    *Remove*)
      cmd_remove
      gum confirm "Back to menu?" --default=true --affirmative="Yes" --negative="No" || break
      ;;
    *Exit*)
      gum style --foreground 10 "  Goodbye!"
      exit 0
      ;;
    esac
  done
}

########################################
# Command Router (Args Mode)
########################################

main() {
  # Ensure dirs exist
  niri_ensure_dirs

  # No args = interactive dashboard
  if [[ $# -eq 0 ]]; then
    niri_require gum
    dashboard
    return
  fi

  # With args = direct command
  local cmd="$1"
  shift || true

  case "$cmd" in
  install | i)
    cmd_install "$@"
    ;;
  list | ls)
    cmd_list "$@"
    ;;
  remove | rm)
    cmd_remove "$@"
    ;;
  *)
    gum style --foreground 9 "  Unknown command: $cmd"
    printf "\n  Usage: %s [install|list|remove] [args...]\n" "$0"
    printf "  Or run without args for interactive mode.\n\n"
    exit 1
    ;;
  esac
}

main "$@"
