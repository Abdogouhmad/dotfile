#!/usr/bin/env bash
set -Eeuo pipefail

# Handle preview mode
if [[ "${1:-}" == "__preview__" ]]; then
  pkg="$2"

  case "$pkg" in
  repo:*)
    exec pacman -Si "${pkg#repo:}"
    ;;
  aur:*)
    exec yay -Si "${pkg#aur:}"
    ;;
  esac

  exit 0
fi

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require() {
  command -v "$1" >/dev/null ||
    die "$1 is not installed"
}

packages() {
  {
    pacman -Slq | sed 's/^/repo:/'
    yay -Slq --aur | sed 's/^/aur:/'
  } | sort -u
}

install() {
  sudo -v || exit 1

  local pkg

  for pkg in "$@"; do
    yay -S --noconfirm "${pkg#*:}"
  done
}

main() {
  require pacman
  require yay
  require fzf

  mapfile -t pkgs < <(
    packages |
      fzf \
        --multi \
        --prompt='Install pkg> ' \
        --height=60% \
        --layout=reverse \
        --border \
        --preview="$0 __preview__ {}" \
        --preview-window=right:65%,wrap \
        --query="${1:-}"
  )

  ((${#pkgs[@]})) || exit 0

  install "${pkgs[@]}"
}

main "$@"
