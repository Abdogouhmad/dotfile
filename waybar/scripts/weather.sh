#!/bin/bash
# Weather script for waybar - uses wttr.in
# Usage: weather.sh [location]

LOCATION="${1:-Changchun}"

data=$(curl -sf "wttr.in/${LOCATION}?format=%t+%C" 2>/dev/null)
if [[ $? -ne 0 || -z "$data" ]]; then
  printf '{"text":"","class":"unavailable"}\n'
  exit 0
fi

temp=$(echo "$data" | awk '{print $1}')
condition=$(echo "$data" | cut -d' ' -f2-)

# Map wttr.in conditions to nerd font icons
case "$condition" in
  *Sunny*|*Clear*)         icon="󰖨" ;;
  *Partly*cloudy*)         icon="󰖟" ;;
  *Cloudy*|*Overcast*)     icon="󰖐" ;;
  *Mist*|*Fog*)            icon="󰖟" ;;
  *Rain*|*drizzle*)        icon="󰖗" ;;
  *heavy*rain*)            icon="󰖖" ;;
  *Snow*)                  icon="󰖘" ;;
  *Thunder*)               icon="󰖓" ;;
  *fog*)                   icon="󰖟" ;;
  *)                       icon="󰖙" ;;
esac

# Build tooltip with more detail
detail=$(curl -sf "wttr.in/${LOCATION}?format=%C+%t+Feels+like+%f+%w+%p" 2>/dev/null)
tooltip=$(echo "$detail" | sed 's/"/\\"/g')

# Output JSON
printf '{"text":"%s %s","tooltip":"%s","class":"weather"}\n' "$icon" "$temp" "$tooltip"
