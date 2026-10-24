#!/bin/bash

battery=(
	padding_left=0
	padding_right=2
	width=60
	align=right
	#background.color=$RED
	label.drawing=on
	label.font="$FONT_TEXT:Regular:12.0"
	icon.font="$FONT_TEXT:Regular:16.0"
	icon.padding_right=5
	script="$PLUGIN_DIR/battery.sh"
	update_freq=120
	updates=on
	#background.color=$BLACK
)

sketchybar --add item battery right \
	--set battery "${battery[@]}" \
	--subscribe battery power_source_change system_woke
