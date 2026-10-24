#!/bin/bash

network_down=(
    padding_right=-6
    width=44
    y_offset=0
    label.font="$FONT_TEXT:Regular:12.0"
    script="$PLUGIN_DIR/network.sh"
    update_freq=5
    icon=""
    icon.font="$FONT:Regular:7.0"
    icon.highlight_color=0xff10528c
    #background.color=$BLACK
)

#network_up=(
#    y_offset=5
#    width=0
#    label.font="$FONT:Regular:7.0"
#    icon=""
#    icon.font="$FONT:Regular:7.0"
#    icon.highlight_color=0xff8b0a0d
#    update_freq=5
#    script="$PLUGIN_DIR/network.sh"
#)

sketchybar --add item network_down right \
           --set network_down "${network_down[@]}"
           #--add item network_up right \
           #--set network_up "${network_up[@]}" \
