#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cmd_remove() {
  local target="${1:-}" files=() names=()

  # Collect webapps
  for f in "$NIRI_APP_DIR"/*.desktop; do
    [[ -f "$f" ]] || continue
    grep -q "^Exec=.*--new-window" "$f" || continue
    files+=("$f")
    names+=("$(grep "^Name=" "$f" | cut -d'=' -f2-) ($(basename "$f" .desktop))")
  done

  if [[ ${#files[@]} -eq 0 ]]; then
    gum style --foreground 9 "  No webapps to remove."
    return
  fi

  gum style --foreground 12 --bold "  🗑️  Remove Webapp"
  printf "\n"

  # Select target
  if [[ -n "$target" ]]; then
    # Try by slug
    for f in "${files[@]}"; do
      [[ "$(basename "$f" .desktop)" == "$target" ]] && {
        target="$f"
        break
      }
    done
    # Try by name
    [[ -f "$target" ]] || for f in "${files[@]}"; do
      local n
      n=$(grep "^Name=" "$f" | cut -d'=' -f2-)
      [[ "$n" == "$target" ]] && {
        target="$f"
        break
      }
    done
  else
    local chosen
    chosen=$(gum choose --header="  Select webapp to remove" "${names[@]}")
    target=$(printf "%s" "$chosen" | sed 's/.*(\(.*\))/\1/')
    target="$NIRI_APP_DIR/$target.desktop"
  fi

  if [[ ! -f "$target" ]]; then
    niri_err "Webapp not found"
    exit 1
  fi

  local name slug icon
  name=$(grep "^Name=" "$target" | cut -d'=' -f2-)
  slug=$(basename "$target" .desktop)
  icon=$(grep "^Icon=" "$target" | cut -d'=' -f2-)

  printf "\n"
  gum style --foreground 9 "  Name: $name"
  gum style --foreground 9 "  Slug: $slug"
  printf "\n"

  gum confirm "  Remove this webapp?" --default=false || {
    niri_info "Cancelled"
    return
  }

  rm -f "$target"
  [[ -n "$icon" && -f "$icon" && "$icon" == "$NIRI_ICON_DIR"* ]] && rm -f "$icon"

  niri_ok "Webapp '$name' removed."
}
