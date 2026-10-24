#!/bin/bash

control_center=(
  padding_left=10
  padding_right=10
  icon=""
  icon.font="SF Symbols:Regular:14.0"
  #click_script="osascript -e 'tell application \"System Events\" to tell process \"Control Center\" to perform action \"AXPress\" of menu bar item 2 of menu bar 1'"
)
echo "test"
sketchybar --add alias "Centre de contrôle,BentoBox" right
sketchybar --add alias "Control Center,Bluetooth" right
sketchybar --query default_menu_items
echo "test2"
#sketchybar --add item control_center right \
#    --set control_center "${control_center[@]}"
