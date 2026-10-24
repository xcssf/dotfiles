#!/bin/bash

#Filename: ~/github/dotfiles-latest/sketchybar/felixkratz/items/calendar.sh

calendar=(
	# If showing the time, leave the width as 45
	# label.width=45
	padding_right=-6
	width=145
	#label.width=10
	#label.align=right
	icon.font="$FONT_TEXT:Regular:13.0"
	update_freq=10
	script="$PLUGIN_DIR/calendar.sh"
	#background.color=$RED
	#click_script="$PLUGIN_DIR/zen.sh"
)

sketchybar --add item calendar right \
	--set calendar "${calendar[@]}" \
	--subscribe calendar system_woke
