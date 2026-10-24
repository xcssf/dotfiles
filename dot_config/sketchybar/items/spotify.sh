#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/wifi.sh
source "colors.sh"
spotify=(
  padding_left=232
  padding_right=0
  width=430
  #background.color=$RED
  label.font="$FONT_TEXT:Regular:13.0"
  label.padding_left=5
  label.width=250
  label.align="left"
  icon.font="sketchybar-app-font:Regular:13.0"
  icon.y_offset=0
  script="$PLUGIN_DIR/spotify.sh"
  #background.color=$RED
  #label.width=0
  #icon="$WIFI_DISCONNECTED"
  #icon.font="$FONT_TEXT:Regular:14.5"
  #script="$PLUGIN_DIR/wifi.sh"
  #click_script="osascript -e 'tell application \"System Events\" to tell process \"Centre de contrôle\" to perform action \"AXPress\" of menu bar item 2 of menu bar 1'"
)

#spotify_back=(
#    script="$PLUGIN_DIR/spotify.sh"
#    drawing=off
#    icon="􀊊"
#)

#spotify_playpause=(
#    script="$PLUGIN_DIR/spotify.sh"
#    drawing=off
#)

#spotify_forward=(
#    script="$PLUGIN_DIR/spotify.sh"
#    icon="􀊌"
#    drawing=off
#)

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"

sketchybar --add event spotify_update $SPOTIFY_EVENT \
           \
           --add item spotify center \
           --set spotify "${spotify[@]}" \
           --subscribe spotify spotify_update mouse.entered.global mouse.exited.global \
           #--add item spotify.back center \
           #--set spotify.back "${spotify_back[@]}" \
           #--subscribe spotify.back mouse.clicked \
           #\
           #--add item spotify.playpause center \
           #--set spotify.playpause "${spotify_playpause[@]}" \
           #--subscribe spotify.playpause mouse.clicked \
           #\
           #--add item spotify.forward center \
           #--set spotify.forward "${spotify_forward[@]}" \
           #--subscribe spotify.forward mouse.clicked \