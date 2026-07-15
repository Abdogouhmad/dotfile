#!/usr/bin/env bash

set -euo pipefail

TERMINAL="kitty"
APP_ID="com.abdo.screensaver"

for cmd in niri kitty cbonsai; do
    command -v "$cmd" >/dev/null || {
        echo "Missing dependency: $cmd"
        exit 1
    }
done

MESSAGES=(
    "Take a break, $USER."
    "Growing patiently..."
    "Keep coding."
    "Rust never sleeps."
    "One tree at a time."
    "Touch some grass."
)

message="${MESSAGES[$((RANDOM % ${#MESSAGES[@]}))]}"

cleanup() {
    pkill -x cbonsai 2>/dev/null || true
    pkill -f "$APP_ID" 2>/dev/null || true
    exit 0
}

[[ "${1:-}" == "kill" ]] && cleanup

pgrep -x cbonsai >/dev/null && exit 0

trap cleanup SIGINT SIGTERM SIGQUIT EXIT

current_output="$(
    niri msg focused-output |
    sed -n 's/^Output.*(\(.*\)).*/\1/p'
)"

if [[ "${1:-}" == "--current" ]]; then
    outputs=("$current_output")
else
    mapfile -t outputs < <(
        niri msg outputs |
        sed -n 's/^Output.*(\(.*\)).*/\1/p'
    )
fi

for output in "${outputs[@]}"; do
    niri msg action focus-monitor "$output"

    kitty \
        --class="$APP_ID" \
        --start-as=fullscreen \
        cbonsai \
        --infinite \
        --multiplier 11 \
        --leaf "@,0,O,8" \
        --message "$message" &

    sleep 0.4

    niri msg action fullscreen-window >/dev/null 2>&1 || true
done

while pgrep -x cbonsai >/dev/null; do
    if ! niri msg focused-window | grep -q "$APP_ID"; then
        cleanup
    fi
    sleep 0.2
done
