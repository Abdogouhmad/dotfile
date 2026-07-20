#!/usr/bin/env bash

# set -uo pipefail

source "$(dirname "$0")/niri-webapp-lib.sh"
trap niri_pause_on_exit EXIT
########################################
# Constants
########################################

readonly ICON_DIR="$HOME/.local/share/icons/niri-webapp"
readonly APPLICATION_DIR="$HOME/.local/share/applications"

########################################
# Install
########################################

install() {
  local name
  local url
  local slug
  local html

  case "$#" in
  0)
    name=$(gum input --placeholder "Name of your web app")
    url=$(gum input --placeholder "https://example.com")
    ;;
  1)
    name="$1"
    url=$(gum input --placeholder "https://example.com")
    ;;
  *)
    name="$1"
    url="$2"
    ;;
  esac

  url=$(niri_normalize_url "$url")
  slug=$(niri_slugify "$name")

  niri_info "Downloading website..."

  if ! html=$(niri_fetch_html "$url"); then
    niri_error "Failed to download '$url'"
    niri_pause_on_exit
  fi

  niri_success "Website downloaded."

  printf "\n"
  printf "Name : %s\n" "$name"
  printf "Slug : %s\n" "$slug"
  printf "URL  : %s\n" "$url"

  # TODO
  # favicon=$(niri_get_favicon_url "$html" "$url")
  # icon=$(niri_download_icon "$favicon" "$slug")
  # niri_create_desktop "$name" "$slug" "$url" "$icon"
}

########################################
# Main
########################################

main() {

  niri_require gum
  niri_require curl
  niri_require grep
  niri_require sed

  mkdir -p \
    "$ICON_DIR" \
    "$APPLICATION_DIR"

  case "${1:-}" in

  install)
    shift
    install "$@"
    ;;
  list)
    shift
    printf "listing...\n"
    ;;
  *)
    printf "Usage: %s install [URL]\n" "$0"
    exit 1
    ;;
  esac
}

main "$@"
