#!/usr/bin/env bash

# variables para opción

exit_menu="Exit Menu"

# Obtener el dispositivo de audio actual
current_sink=$(pactl info | grep "Default Sink" | awk '{print $3}')

# Listar los dispositivos de salida de audio
devices=$(pactl list short sinks | awk '{print $2}')

# Fichero del tema personalizado para rofi
CUSTOM_RASI="$HOME/.config/polybar/cuts/scripts/rofi/custom_audio.rasi"

# Crear la salida con el dispositivo activo en una línea separada y un separador
output="* $current_sink (Active)\n"  # Línea del dispositivo activo
output+="$exit_menu\n"                          # Agregar un separador de línea
output+=$(echo "$devices" | grep -v "$current_sink")  # Agregar otros dispositivos

# Mostrar el menú usando el tema personalizado y permitir interacción con teclado o ratón
selected_device=$(echo -e "$output" | rofi -dmenu -i -theme "$CUSTOM_RASI" -p "Select Audio Output:")


# Si se selecciona un dispositivo y no es el dispositivo activo, cambiarlo
if [[ -n "$selected_device" ]] && [[ "$selected_device" != *"(Active)" ]]; then
	pactl set-default-sink "$selected_device"
	notify-send "Audio Output" "Changed to $selected_device"
elif [[ "$selected_device" == "$exit_menu" ]]; then
	notify-send "Audio Output" "you left the menu"
else
    notify-send "Audio Output" "No device selected or already active"
fi

