#!/bin/bash

# Draw one app icon per running application on the current space.
#
# SketchyBar items are named by index:
#   space.<space_id>.app.<index>
#
# When an app closes, we remove only indexes that are no longer needed. This
# keeps the implementation simple while avoiding stale/duplicated icons caused
# by deleting "the last item" returned by SketchyBar in an unknown order.

item_exists() {
  sketchybar --query "$1" >/dev/null 2>&1
}

get_current_space() {
  echo "space.$(echo "$INFO" | jq -r '.space')"
}

get_apps() {
  apps=()

  while IFS= read -r app; do
    apps+=("$app")
  done < <(echo "$INFO" | jq -r '.apps // {} | keys[]')
}

get_space_app_items() {
  app_items=()

  while IFS= read -r item; do
    app_items+=("$item")
  done < <(
    sketchybar --query bar \
      | jq -r ".items[]? | select(startswith(\"${space}.app.\") and test(\"[0-9]+$\"))"
  )
}

remove_stale_app_items() {
  local item index

  for item in "${app_items[@]}"; do
    index="${item##*.}"

    if [[ "$index" =~ ^[0-9]+$ ]] && (( index >= ${#apps[@]} )); then
      sketchybar --remove "$item"
    fi
  done
}

upsert_app_items() {
  local index app item

  for index in "${!apps[@]}"; do
    app="${apps[$index]}"
    item="${space}.app.${index}"

    if ! item_exists "$item"; then
      sketchybar --add item "$item" left
      sketchybar --move "$item" after "$space"
    fi

    sketchybar --set "$item" \
      icon.background.drawing=on \
      icon.background.image="app.${app}"
  done
}

update_space_app_icons() {
  space=$(get_current_space)

  get_apps
  get_space_app_items
  remove_stale_app_items
  upsert_app_items
}

if [[ "$SENDER" == "space_windows_change" ]]; then
  update_space_app_icons
fi
