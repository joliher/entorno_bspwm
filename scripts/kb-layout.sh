#!/bin/bash

layouts=("es" "us" "gb" "de" "fr" "it")

declare -A layout_names=(
  ["es"]="Español"
  ["us"]="Inglés (EEUU)"
  ["gb"]="Inglés (Reino Unido)"
  ["de"]="Alemán"
  ["fr"]="Francés"
  ["it"]="Italiano"
)

current_layout=$(setxkbmap -query | awk '/layout:/ {print $2}')

menu=()
for code in "${layouts[@]}"; do
  name="${layout_names[$code]}"
  if [[ "$code" == "$current_layout" ]]; then
    menu+=("* $name")
  else
    menu+=("  $name")
  fi
done

selected=$(printf '%s\n' "${menu[@]}" | rofi -dmenu -p "Distribución de teclado" | xargs)

# Salir si no se eligió nada
[ -z "$selected" ] && exit

for code in "${!layout_names[@]}"; do
  nombre=$(echo ${layout_names[$code]} | xargs)
  if [ "$nombre" == "$selected" ]; then
    selected_layout="$code"
    break
  fi
done

setxkbmap $selected_layout
#notify-send "Distribución de teclado cambiada a: $selected"

