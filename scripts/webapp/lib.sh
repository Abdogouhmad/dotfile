#!/usr/bin/env bash

[[ -n "${_NIRI_LIB_LOADED:-}" ]] && return
readonly _NIRI_LIB_LOADED=1

########################################
# Paths
########################################

readonly NIRI_ICON_DIR="$HOME/.local/share/icons/niri-webapp"
readonly NIRI_APP_DIR="$HOME/.local/share/applications"
readonly NIRI_USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"

########################################
# Colors
########################################

readonly C_BLUE='\033[34m'
readonly C_GREEN='\033[32m'
readonly C_YELLOW='\033[33m'
readonly C_RED='\033[31m'
readonly C_RESET='\033[0m'

niri_info() { printf "${C_BLUE}==>${C_RESET} %s\n" "$*"; }
niri_ok() { printf "${C_GREEN}==>${C_RESET} %s\n" "$*"; }
niri_warn() { printf "${C_YELLOW}==>${C_RESET} %s\n" "$*" >&2; }
niri_err() { printf "${C_RED}error:${C_RESET} %s\n" "$*" >&2; }

########################################
# Requirements
########################################

niri_require() {
  command -v "$1" &>/dev/null || {
    niri_err "'$1' is required. Install: https://github.com/charmbracelet/gum"
    exit 1
  }
}

########################################
# Dirs & Cleanup
########################################

niri_ensure_dirs() {
  mkdir -p "$NIRI_ICON_DIR" "$NIRI_APP_DIR"
}

niri_cleanup() {
  local code=$?
  command -v update-desktop-database &>/dev/null &&
    update-desktop-database "$NIRI_APP_DIR" &>/dev/null || true
  exit $code
}

########################################
# URL Utils
########################################

niri_normalize_url() {
  local url="$1"
  url="${url#"${url%%[![:space:]]*}"}"
  url="${url%"${url##*[![:space:]]}"}"
  [[ "$url" =~ ^https?:// ]] || url="https://$url"
  printf "%s" "$url"
}

niri_get_origin() {
  printf "%s" "$1" | sed -E 's#(https?://[^/]+).*#\1#'
}

########################################
# Network
########################################

niri_fetch() {
  curl --silent --show-error --location --max-time 20 --retry 2 \
    --user-agent "$NIRI_USER_AGENT" "$1"
}

########################################
# Favicon
########################################

niri_get_favicon() {
  local html="$1" base="$2" href

  href=$(printf '%s' "$html" | grep -oiE '<link[^>]+rel="[^"]*(icon|apple-touch-icon)[^"]*"[^>]*>' |
    sed -E 's/.*href="([^"]+)".*/\1/' | head -n1)

  [[ -z "$href" ]] && {
    printf '%s/favicon.ico' "${base%/}"
    return
  }

  # Absolute
  [[ "$href" =~ ^https?:// ]] && {
    printf '%s' "$href"
    return
  }
  # Root relative
  [[ "$href" =~ ^/ ]] && {
    printf '%s%s' "$(niri_get_origin "$base")" "$href"
    return
  }
  # Relative
  printf '%s/%s' "${base%/}" "$href"
}

niri_download_icon() {
  local url="$1" slug="$2" out="$NIRI_ICON_DIR/$slug.ico"
  curl --silent --show-error --location --max-time 15 --output "$out" "$url" 2>/dev/null || return 1
  [[ -s "$out" ]] || {
    rm -f "$out"
    return 1
  }
  printf '%s' "$out"
}

########################################
# Text Utils
########################################

niri_slugify() {
  printf "%s" "$1" | tr '[:upper:]' '[:lower:]' |
    sed -e 's/[^a-z0-9]/-/g' -e 's/-\{2,\}/-/g' -e 's/^-//' -e 's/-$//' | cut -c1-50
}

niri_extract_title() {
  printf "%s" "$1" | tr '\n\r' ' ' | sed -n 's:.*<title>\(.*\)</title>.*:\1:pi' |
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | head -c 80
}
