#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/lib.sh"

require_cmd gum
require_cmd yay
require_cmd checkupdates

header "󰚰 System Update"

spinner "Checking repositories..." \
    bash -c '
        checkupdates 2>/dev/null > /tmp/pacman_updates || true
        yay -Qua > /tmp/aur_updates || true
    '

PACMAN_COUNT=$(wc -l < /tmp/pacman_updates)
AUR_COUNT=$(wc -l < /tmp/aur_updates)

if (( PACMAN_COUNT == 0 && AUR_COUNT == 0 )); then
    success "System is already up to date."
    sleep 3
    exit 0
fi

# gum table \
#     --border rounded \
#     --widths 18,10 \
#     "Repository" "Updates" \
#     "Pacman" "$PACMAN_COUNT" \
#     "AUR" "$AUR_COUNT"

# printf "Pacman,%s\nAUR,%s\n" \
#     "$PACMAN_COUNT" \
#     "$AUR_COUNT" |
# gum table \
#     --separator "," \
#     --columns "Repository,Updates" \
#     --widths "20,10" \
#     --border rounded
# echo

choice=$(
gum choose \
    --header "Select an action" \
    "Show package list" \
    "Update Everything" \
    "Only Pacman" \
    "Only AUR" \
    "Cancel"
)

case "$choice" in

"Show package list")
    {
        echo "===== Pacman ====="
        cat /tmp/pacman_updates

        echo

        echo "===== AUR ====="
        cat /tmp/aur_updates
    } | gum pager

    exec "$0"
    ;;

"Update Everything")

    gum confirm "Continue?" || exit 0

    [[ "$PACMAN_COUNT" -gt 0 ]] && bash "$(dirname "$0")/pacmanpkg.sh"
    [[ "$AUR_COUNT" -gt 0 ]] && bash "$(dirname "$0")/aurpkg.sh"

    bash "$(dirname "$0")/cleanpkg.sh"
    ;;

"Only Pacman")

    gum confirm "Update Pacman packages?" || exit 0

    bash "$(dirname "$0")/pacmanpkg.sh"

    ;;

"Only AUR")

    gum confirm "Update AUR packages?" || exit 0

    bash "$(dirname "$0")/aurpkg.sh"

    ;;

*)

    exit 0

esac

success "System update completed."

rm -f \
    /tmp/pacman_updates \
    /tmp/aur_updates
