#!/usr/bin/env bash

set -Eeuo pipefail

require_cmd() {
    command -v "$1" >/dev/null || {
        gum style --foreground 196 "Missing dependency: $1"
        exit 1
    }
}

spinner() {
    local title="$1"
    shift
    gum spin \
        --spinner dot \
        --title "$title" \
        -- "$@"
}

header() {
    gum style \
        --border rounded \
        --border-foreground 212 \
        --foreground 212 \
        --padding "1 2" \
        --margin "1" \
        "$1"
}

success() {
    gum style \
        --foreground 42 \
        "✔ $1"
}

error() {
    gum style \
        --foreground 196 \
        "✖ $1"
}
