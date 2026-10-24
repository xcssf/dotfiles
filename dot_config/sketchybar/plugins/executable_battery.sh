#!/bin/bash

source "$CONFIG_DIR/colors.sh"

BATTERY_INFO="$(pmset -g batt)"
PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

# Check for the absence of "InternalBattery" to determine no battery present
# My mac mini doesn't have a battery, and it was leaving a blank space where the
# battery was supposed to be
if ! echo "$BATTERY_INFO" | grep -q "InternalBattery"; then
  sketchybar --set "$NAME" drawing=off
else
  sketchybar --set "$NAME" drawing=on
fi

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

COLOR=$WHITE
case "${PERCENTAGE}" in
[8-9][0-9] | 100) # 80+
  ICON="􀛨"
  #COLOR=$GREEN
  COLOR=$WHITE
  ;;
[3-7][0-9])       # 30-70
  ICON="􀺶"
  #COLOR=$YELLOW
  COLOR=$WHITE
  ;;
# [3-5][0-9])     # 30-50 (unused)
#   ICON=""
#   COLOR=$YELLOW
#   ;;
[1-2][0-9])       # 10-30
  ICON="􀛩"
  COLOR=$RED
  ;;
*) 
  ICON="􀛪"        # 0-10
  COLOR=$RED
  ;;
esac

if [[ "$CHARGING" != "" ]]; then
  ICON="􀢋"
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set "$NAME" label="${PERCENTAGE}%" icon="$ICON" icon.color=$COLOR
