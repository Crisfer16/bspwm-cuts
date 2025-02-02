#!/bin/bash
clear

# Logo
echo "  ____  ____  ____  _    _  _  ____    ____  ____  ____  _  _ "
echo " / ___)(  _ \(  _ \( \/\/ )( \(  _ \  (  _ \(  _ \(  _ \( \/ )"
echo " \___ \ ) __/ )   / )    ( )  ( )   /  ) _ < ) _ < )   / )  ( "
echo " (____/(__)  (__\_)(_/\/\_)(_)\_)__\  (____/(____/(__\_)(_/\_)"
echo "                                                             "
echo "                                                              "
echo "  by cristian                                                "
echo "                                                             "

# capturar el ctrl + c
pid_script=$!

finalizacion_script(){
 
 echo "Ctrl+C capturado. ¿Quieres finalizar el proceso de instalación de bspwm? (1=si/2=no):"
    read -r finalizar  # Leer la entrada del usuario

    if [ "$finalizar" -eq 1 ]; then
        echo "Decidiste finalizar el script."
        if [ -n "$pid_script" ]; then
            kill "$pid_script" 2>/dev/null  # Terminar el proceso de manera segura
        fi
        exit 1  # Salir del script con un código de error
    else
        echo "Continuamos con el script."
    fi
}

trap finalizacion_script int

# array con el contenido de los programas

declare -a programas=(
    "bspwm"
    "git"
    "sxhkd"
    "polybar"
    "feh"
    "rofi"
    "zsh"
    "lsd"
    "picom"
    "kitty"
    "nerd-fonts"
    "dunst"
    "libnotify"
    "powerline-common"
    "awesome-terminal-fonts"
    "sddm"
    "nemo"
    "lxappearance"
    "flatpak"
    "xorg-xsetroot"
    "flameshot"
)

# Función para instalar paquetes
instalar_paquetes() {
    sudo pacman -S --noconfirm "${programas[@]}"
}

# Función para cambiar la shell a zsh
cambiar_shell() {
    chsh -s $(which zsh)
}

# Función para instalar paquetes con yay
instalar_yay_paquetes() {
    yay -S --noconfirm python-pywal python-pywalfox i3lock-fancy-git
}

instalar_oh_my_zsh() {
    # Instalar oh-my-zsh sin cambiar a zsh inmediatamente

    # borrado del fichero e zshrc ya existente para que no nos preguntea en el script para modificarlo
    rm -f $HOME/.zshrc
    env RUNZSH=no CHSH=no yes n | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
}

# Función para instalar temas de polybar
instalar_polybar_temas() {
    local polybar_dir="$HOME/polybar-themes"

    # Comprobar si el directorio ya existe
    if [ ! -d "$polybar_dir" ]; then
        echo "Clonando el repositorio de temas de Polybar..."
        git clone https://github.com/adi1090x/polybar-themes.git "$polybar_dir"
    else
        echo "El directorio de temas de Polybar ya existe."
    fi

    # Comprobar si el script setup.sh existe y es ejecutable
    local setup_script="$polybar_dir/setup.sh"
    if [ -f "$setup_script" ]; then
        echo "Ejecutando el script de configuración de Polybar..."
        cd "$polybar_dir" && echo "1" | bash "$setup_script"
    else
        echo "El script setup.sh no existe o no es ejecutable."
    fi
}

# Función para copiar archivos de configuración
copiar_configuracion() {
    # Crear directorios de configuración si no existen
    mkdir -p $HOME/.config/{bspwm,sxhkd,dunst,picom,kitty}

    # Definir rutas de origen
    local ruta="$HOME/bspwm-cris"
    local ruta_propia="$HOME/script_bspwm"
    local ruta_alternativa="$HOME/bspwm-cris-main"
    local ruta_alternativa_descargas="$HOME/Descargas/bspwm-cris-main/"

    # Verificar si alguna de las rutas existe
    if [ -d "$ruta" ]; then
        echo "Usando ruta: $ruta"
        origen="$ruta"
    elif [ -d "$ruta_alternativa" ]; then
        echo "Usando ruta: $ruta_alternativa"
        origen="$ruta_alternativa"
    elif [ -d "$ruta_alternativa_descargas" ]; then
        echo "La ruta utuliza es: $ruta_alternativa_descargas"
        origen="$ruta_alternativa_descargas"
    elif [ -d $ruta_propia ]; then
        echo "La ruta utllizada es: $ruta_propia"
        origen="$origen"
    else
        echo "No es correcta ninguna ruta puesta."
        return 1
    fi

    # Copiar archivos de configuración
    cp -r "$origen/fondo_pantalla" "$HOME/.fondo_pantalla" || { echo "Error copiando fondo_pantalla"; return 1; }
    cp "$origen/config/bspwm/bspwmrc" "$HOME/.config/bspwm/bspwmrc" || { echo "Error copiando bspwmrc"; return 1; }
    cp "$origen/config/sxhkd/sxhkdrc" "$HOME/.config/sxhkd/sxhkdrc" || { echo "Error copiando sxhkdrc"; return 1; }
    cp -r "$origen/config/polybar/cuts" "$HOME/.config/polybar/" || { echo "Error copiando grayblocks"; return 1; }
    cp "$origen/config/dunst/dunstrc" "$HOME/.config/dunst/dunstrc" || { echo "Error copiando dunstrc"; return 1; }
    cp "$origen/config/picom/picom.conf" "$HOME/.config/picom/picom.conf" || { echo "Error copiando picom.conf"; return 1; }
    cp "$origen/config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf" || { echo "Error copiando kitty.conf"; return 1; }
    cp -r "$origen/config/gtk-3.0" "$HOME/.config/gtk-3.0/" || { echo "Error copiando grayblocks"; return 1; }
    cp "$origen/.zshrc" "$HOME/.zshrc" || { echo "Error copiando .zshrc"; return 1; }
    cp "$origen/.p10k.zsh" "$HOME/.p10k.zsh" || { echo "Error copiando .p10k.zsh"; return 1; }
    cp "$origen/.Xresources" "$HOME/.Xresources" || { echo "Error copiando .p10k.zsh"; return 1; }
    cp "$origen/.gtkrc-2.0" "$HOME/.gtkrc-2.0" || { echo "Error copiando .p10k.zsh"; return 1; }
    cp -r "$origen/themes" "$HOME/.themes" || { echo "Error copiando el driectoio themes"; return 1; }
    cp -r "$origen/icons" "$HOME/.icons" || { echo "Error copiando el driectoio icons"; return 1; }

    echo "Archivos de configuración copiados exitosamente."
}


# Función para reiniciar y que surtan todos los cambios.

reinicio_sistema() {
    reinicio="(sleep 10 && reboot)"

    bash -c "$reinicio" &
}


# Función para habilitar el bloqueo de pantalla de sddm.
activacion_sddm () {
    sudo systemctl enable sddm
}

# Ejecutar funciones
instalar_paquetes
instalar_yay_paquetes
instalar_oh_my_zsh
instalar_polybar_temas
copiar_configuracion
cambiar_shell
activacion_sddm
reinicio_sistema

echo "Instalación y configuración completada. en breves se reiniciada el sistema para poder cambiar a bspwm"
