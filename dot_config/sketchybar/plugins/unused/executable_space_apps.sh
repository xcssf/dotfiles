#!/bin/bash
# plugins/space_apps.sh
# Affiche les icônes des apps ouvertes sur un space donné

# ID du space à partir du nom de l’item SketchyBar (ex: "space.3" → 3)
SPACE_ID=$(echo "$NAME" | awk -F'.' '{print $2}')

# Supprimer les anciens sous-items associés à ce space
for item in $(sketchybar --query bar | jq -r ".items[] | select(startswith(\"space_${SPACE_ID}_app\"))"); do
  sketchybar --remove "$item"
done

# Récupérer les apps ouvertes dans ce space via Yabai
apps=$(yabai -m query --windows --space "$SPACE_ID" | jq -r '.[].app' | sort -u)

# Si aucune app ouverte sur ce space, on quitte
[ -z "$apps" ] && exit 0

# Ajouter un item par app ouverte dans ce space
i=0
for app in $apps; do
  subitem="space_${SPACE_ID}_app_${i}"

  sketchybar --add item "$subitem" right \
             --set "$subitem" \
                associated_space=$SPACE_ID \
                icon.background.image="app.$app" \
                icon.padding_left=3 \
                icon.padding_right=3 \
                label.drawing=off \
                background.drawing=off \
                display=active

  ((i++))
done