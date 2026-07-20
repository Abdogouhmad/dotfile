#!/usr/bin/env bash

########################################
# Exit handler (pause if interactive)
########################################
_niri_paused=0
niri_pause_on_exit() {
  local exit_code=$?
  if [ $_niri_paused -eq 1 ]; then return; fi
  _niri_paused=1
  if [ -t 0 ] && [ -t 1 ]; then
    printf "\n"
    read -n1 -rs -p "Press any key to close..." 2>/dev/null || true
    printf "\n"
  fi
  exit $exit_code
}

########################################
# Constants
########################################

readonly NIRI_USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36"

########################################
# Logging
########################################

niri_info() {
  printf "\033[34m==>\033[0m %s\n" "$*"
}

niri_success() {
  printf "\033[32m==>\033[0m %s\n" "$*"
}

niri_warn() {
  printf "\033[33m==>\033[0m %s\n" "$*" >&2
}

niri_error() {
  printf "\033[31merror:\033[0m %s\n" "$*" >&2
}

die() {
  niri_error "$*"
  niri_pause_on_exit
}

########################################
# Requirements
########################################

niri_require() {
  command -v "$1" >/dev/null 2>&1 || {
    niri_error "\"$1\" is not installed."
    exit 1
  }
}

########################################
# URL
########################################

niri_normalize_url() {
  local url="$1"

  # Trim whitespace
  url="${url#"${url%%[![:space:]]*}"}"
  url="${url%"${url##*[![:space:]]}"}"

  # Add scheme if missing
  if [[ ! "$url" =~ ^https?:// ]]; then
    url="https://$url"
  fi

  printf "%s\n" "$url"
}

########################################
# Network
########################################

niri_fetch_html() {
  local url="$1"

  curl \
    --silent \
    --show-error \
    --location \
    --user-agent "$NIRI_USER_AGENT" \
    "$url"
}

########################################
# HTML
########################################

niri_extract_title() {
  local html="$1"

  printf "%s" "$html" |
    tr '\n' ' ' |
    sed -n 's:.*<title>\(.*\)</title>.*:\1:p' |
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

########################################
# Utils
########################################

niri_slugify() {
  local text="$1"

  printf "%s" "$text" |
    tr '[:upper:]' '[:lower:]' |
    sed \
      -e 's/[^a-z0-9]/-/g' \
      -e 's/-\{2,\}/-/g' \
      -e 's/^-//' \
      -e 's/-$//'
}
