#!/usr/bin/env bash
set -Eeuo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/gpu-screen-recorder"
PID_FILE="$STATE_DIR/pid"

mkdir -p "$STATE_DIR"
MONITOR=$(
  gpu-screen-recorder --list-monitors |
    head -n1 |
    cut -d'|' -f1
)

VIDEO_DIR="$HOME/Videos/Recordings"
mkdir -p "$VIDEO_DIR"

timestamp() {
  date +"%Y-%m-%d_%H-%M-%S"
}

is_running() {
  [[ -f "$PID_FILE" ]] || return 1

  local pid
  pid=$(<"$PID_FILE")

  kill -0 "$pid" 2>/dev/null
}

start_record() {
  if is_running; then
    notify-send "Screen Recorder" "Already recording."
    exit 0
  fi

  local file="$VIDEO_DIR/$(timestamp).mp4"

  gpu-screen-recorder \
    -w "$MONITOR" \
    -f 30 \
    -k av1 \
    -o "$file" \
    >/dev/null 2>&1 &

  echo $! >"$PID_FILE"

  notify-send "Recording Started" "$file"
}

pause_record() {
  if ! is_running; then
    notify-send "Screen Recorder" "No active recording."
    exit 1
  fi

  kill -STOP "$(cat "$PID_FILE")"

  notify-send "Recording Paused"
}

resume_record() {
  if ! is_running; then
    notify-send "Screen Recorder" "No active recording."
    exit 1
  fi

  kill -CONT "$(cat "$PID_FILE")"

  notify-send "Recording Resumed"
}

kill_record() {
  if ! is_running; then
    notify-send "Screen Recorder" "No active recording."
    exit 1
  fi

  kill -INT "$(cat "$PID_FILE")"

  rm -f "$PID_FILE"

  notify-send "Recording Saved"
}

usage() {
  cat <<EOF
Usage:
    record.sh -s    Start
    record.sh -p    Pause
    record.sh -r    Resume
    record.sh -k    Stop
EOF
}

while getopts "sprkh" opt; do
  case "$opt" in
  s) start_record ;;
  p) pause_record ;;
  r) resume_record ;;
  k) kill_record ;;
  h | *) usage ;;
  esac
done
