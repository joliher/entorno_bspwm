#!/bin/bash

# Obtener descripciones y nombres de los sinks
mapfile -t descriptions < <(pactl list sinks | grep -E 'Descripción:' | sed 's/^\s*Descripción: //')
mapfile -t names < <(pactl list sinks | grep -E 'Nombre:' | awk '{print $2}')

# Obtener el sink predeterminado actual
current_sink=$(pactl info | grep "Destino por defecto" | awk -F': ' '{print $2}')

# Construir menú con asterisco para el dispositivo activo
menu=()
for i in "${!descriptions[@]}"; do
    desc="${descriptions[$i]}"
    name="${names[$i]}"
    if [[ "$name" == "$current_sink" ]]; then
        menu+=("* $desc")
    else
        menu+=("  $desc")
    fi
done

# Mostrar menú con rofi
selected_description=$(printf '%s\n' "${menu[@]}" | rofi -dmenu -p "Selecciona dispositivo")

# Salir si no se seleccionó nada
[ -z "$selected_description" ] && exit 1

# Limpiar asterisco y espacios
selected_description=$(echo "$selected_description" | sed 's/^[* ]*//')

# Obtener el nombre del sink seleccionado
for i in "${!descriptions[@]}"; do
  if [[ "${descriptions[$i]}" == "$selected_description" ]]; then
    selected_name="${names[$i]}"
    break
  fi
done

# Si se encontró, cambiar dispositivo y mover streams
if [ -n "$selected_name" ]; then
    pactl set-default-sink "$selected_name"
    for stream in $(pactl list short sink-inputs | cut -f1); do
        pactl move-sink-input "$stream" "$selected_name"
    done
fi

