#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "$0")/lib.sh"

sudo pacman -Syu --noconfirm
