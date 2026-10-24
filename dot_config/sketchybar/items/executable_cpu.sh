#!/bin/bash

cpu_top=(
  padding_right=0
  width=0
  y_offset=6
  label.font="$FONT_TEXT:Regular:8"
  label=""
  icon.drawing=off
  label.drawing=off
)

cpu_percent=(
  padding_left=0
  padding_right=13
  width=41
  y_offset=0
  label.font="$FONT_TEXT:Regular:12.0"
  label="0%"
  icon.drawing=off
  update_freq=4
  mach_helper="$HELPER"
  #background.color=$RED
)

cpu_sys=(
  padding_right=3
  width=0
  y_offset=8
  graph.color=$RED
  graph.fill_color=$WHITE
  label.drawing=off
  icon.drawing=off
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
  #background.color=$GREEN
)

cpu_user=(
  padding_right=3
  width=30
  y_offset=8
  graph.color=$WHITE
  label.drawing=off
  icon.drawing=off
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
  #background.color=$BLUE
)

sketchybar --add item cpu.percent right          \
           --set cpu.percent "${cpu_percent[@]}" \
                                                 \
           --add graph cpu.sys right 25          \
           --set cpu.sys "${cpu_sys[@]}"         \
                                                 \
           --add graph cpu.user right 25         \
           --set cpu.user "${cpu_user[@]}"       \
                                                 \
           --add item cpu.top right              \
           --set cpu.top "${cpu_top[@]}"         \