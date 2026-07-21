#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cmd_install() {
  local name="${1:-}" url="${2:-}" slug html favicon icon desktop

  # Args or interactive
  if [[ -n "$name" && -n "$url" ]]; then
    : # both provided via args
  elif [[ -n "$name" && -z "$url" ]]; then
    # name provided, need url
    url=$(gum input --placeholder "URL (e.g. notion.so)")
    [[ -z "$url" ]] && {
      niri_err "URL required"
      exit 1
    }
  else
    gum style --foreground 12 --bold "  📦 Install New Webapp"
    printf "\n"
    name=$(gum input --placeholder "App name (e.g. Notion)")
    [[ -z "$name" ]] && {
      niri_err "Name required"
      exit 1
    }
    url=$(gum input --placeholder "URL (e.g. notion.so)")
    [[ -z "$url" ]] && {
      niri_err "URL required"
      exit 1
    }
  fi

  url=$(niri_normalize_url "$url")
  slug=$(niri_slugify "$name")

  # Check duplicate
  if [[ -f "$NIRI_APP_DIR/$slug.desktop" ]]; then
    gum confirm "  '$slug' exists. Overwrite?" --default=false || {
      niri_info "Cancelled"
      exit 0
    }
  fi

  # Fetch
  gum spin --spinner dot --title "  Fetching $url..." -- \
    bash -c "html=\$(curl --silent --location --max-time 20 '$url'); printf '%s' \"\$html\"" >"/tmp/niri-$$.html" ||
    {
      niri_err "Failed to fetch"
      rm -f "/tmp/niri-$$.html"
      exit 1
    }

  html=$(cat "/tmp/niri-$$.html")
  rm -f "/tmp/niri-$$.html"

  # Auto-detect title
  local detected
  detected=$(niri_extract_title "$html")
  if [[ -n "$detected" && "$name" =~ ^(website|app|site)$ ]]; then
    gum style --foreground 8 "  Detected: $detected"
    gum confirm "  Use this name?" --default=true && name="$detected" && slug=$(niri_slugify "$name")
  fi

  # Summary
  printf "\n"
  gum style --foreground 8 "  Name: $name"
  gum style --foreground 8 "  Slug: $slug"
  gum style --foreground 8 "  URL:  $url"
  printf "\n"

  gum confirm "  Create webapp?" --default=true || {
    niri_info "Cancelled"
    exit 0
  }

  # Icon
  favicon=$(niri_get_favicon "$html" "$url")
  gum style --foreground 8 "  Favicon: $favicon"

  if icon=$(niri_download_icon "$favicon" "$slug" 2>/dev/null); then
    niri_ok "Icon downloaded"
  else
    niri_warn "No icon found"
    icon=""
  fi

  # Create .desktop
  desktop="$NIRI_APP_DIR/$slug.desktop"
  cat >"$desktop" <<EOF
[Desktop Entry]
Name=$name
Exec=zen-browser --new-window "$url"
Icon=${icon:-}
Type=Application
Terminal=false
Categories=Network;
StartupWMClass=$slug
EOF
  chmod +x "$desktop"

  niri_ok "Webapp '$name' created!"
  gum style --foreground 8 "  $desktop"
  printf "\n"

  gum confirm "  Launch now?" --default=false && gtk-launch "$slug" &>/dev/null || true
}
