#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/wifi.sh

source "$CONFIG_DIR/icons.sh"

wifi=(
  padding_left=0
  padding_right=-8
  width=23
  align=right
  y_offset=1
  icon="$WIFI_DISCONNECTED"
  icon.font="$FONT_TEXT:Regular:14.5"
  script="$PLUGIN_DIR/wifi.sh"
  #background.color=$RED
  #click_script="osascript -e 'tell application \"System Events\" to tell process \"Centre de contrôle\" to perform action \"AXPress\" of menu bar item 2 of menu bar 1'"
)

sketchybar --add item wifi right \
  --set wifi "${wifi[@]}" \
  --subscribe wifi wifi_change mouse.clicked
