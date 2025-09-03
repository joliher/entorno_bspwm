#!/bin/bash

###########################
# Definición de variables #
###########################

programas=('bspwm' 'sxhkd' 'kitty' 'picom' 'polybar' 'tmux' 'pulseaudio' 'curl' 'git')
programas_no_apt=('starship')
opcional=('tar' 'bzip2' 'wget' 'lightdm' 'lightdm-gtk-greeter' 'vim')

USE_LOCAL=false

while [ $# -gt 0 ]; do
	case $1 in
		--local) USE_LOCAL=true ;;
	esac
	shift
done  


function continue_check () {
  read -p "Deseas proseguir? y/N: " quest1

  if [ "${quest1,,}" != "y" ]; then
	echo "Abortando..."
	return 1
  else
	read -p "¿Estás seguro? (double check) y/N: " quest2
	if [ "${quest2,,}" != "y" ]; then
		echo "Abortando..."
		return 1
	fi
  fi

  echo "Procediendo..."
  return 0
}

function clear_screen () {
	echo
	read -n1 -s -p "Presione una tecla para continuar..."
	clear
}

########
# Main #
########

while true; do

  echo "=============================="
  echo "        MENÚ PRINCIPAL        "
  echo "=============================="
  echo "1) Instalar entorno"
  echo "2) Instalar opcionales"
  echo "3) Configurar entorno"
  echo "4) Comprobar instalaciones"
  echo "5) Ver configuración"
  echo "6) Eliminar entorno"
  echo "7) Salir"
  echo "=============================="

  read -p "Elige una opción [1-7]: " opt
  echo

  case $opt in
	1)
	echo "Se van a instalar los siguientes programas:"
	  for i in ${programas[@]}; do
		echo -e " -$i"
	  done
	  for i in ${programas_no_apt[@]}; do
		echo -e " -$i"
	  done

	  if continue_check; then
		sudo apt install ${programas[@]}
		# Instalación de starship
		if ! command -v starship &>/dev/null; then
			curl -sS https://starship.rs/install.sh | sh
		else
			echo "Starship ya se encuentra instalado"
		fi
	  fi
	clear_screen
		;;
	2)
	echo "Se van a instalar los siguientes programas:"
	  for i in ${opcional[@]}; do
		echo -e " -$i"
	  done

	  if continue_check; then
		sudo apt install ${opcional[@]}
	  fi
	clear_screen
		;;
	3)
	error=0
	echo "Comprobando disponibilidad de los programas..."
	  for i in ${programas[@]}; do
		if ! command -v $i &>/dev/null; then
			error=1
			break
		fi
	  done
	  if [ $error -eq 1 ]; then
		echo "Faltan programas por instalar. NO se procederá a la configuración."
		echo "Para comprobar qué programas faltan, consulte la opción 4 del menú"
		break
	  else
		echo "Todos los programas PRINCIPALES se encuentran instalados."
		echo "Procediendo a la configuración..."
	  fi

	# Preparación
	cd $(dirname $0)
	  if [ $USE_LOCAL == "true" ]; then
		echo "Usando repositorio local en $(pwd)..."
		ruta_repo=$(pwd)
		POST_CLEAN=false
	  else
		if [ -d /tmp/entorno_bspwm/ ]; then
			rm -rf /tmp/entorno_bspwm/
		fi
		cd /tmp && git clone https://github.com/joliher/entorno_bspwm &>/dev/null
		ruta_repo=/tmp/entorno_bspwm
		POST_CLEAN=true
	  fi

	# Configuración de bspwm
	echo "Configurando BSPWM..."
	mkdir -p $HOME/.config/bspwm/ &>/dev/null
	  if [ -d $ruta_repo/bspwm/ ]; then
		if cp -r $ruta_repo/bspwm/* $HOME/.config/bspwm/ && chmod +x $HOME/.config/bspwm/bspwmrc; then
			echo "BSPWM configurado correctamente."
		else
			echo "La configuración de BSPWM no se ha podido copiar correctamente."
		        error=1
		fi
	  else
		echo "El directorio $ruta_repo/bspwm/ no existe. BSPWM no se configurará."
	  fi
	echo

	# Configuración de sxhkd
	echo "Configurando SXHKD..."
	mkdir -p $HOME/.config/sxhkd/ &>/dev/null
	  if [ -d $ruta_repo/sxhkd ]; then
		if cp -r $ruta_repo/sxhkd/* $HOME/.config/sxhkd/; then
			echo "SXHKD configurado correctamente."
		else
			echo "La configuración de SXHKD no se ha podido copiar correctamente."
			error=1
		fi
	  else
		echo "El directorio $ruta_repo/sxhkd/ no existe. SXHKD no se configurará."
	  fi
	echo

	# Configuración de kitty
	echo "Configurando KITTY..."
	  if [ -d $ruta_repo/kitty/ ]; then
		if cp -r $ruta_repo/kitty/* $HOME/.config/; then
			echo "KITTY configurado correctamente."
		else
			echo "La configuración de KITTY no se ha podido copiar correctamente."
			error=1
		fi
	  else
		echo "El directorio $ruta_repo/kitty/ no existe. KITTY no se configurará."
	  fi
	echo

	# Configuración de picom
	echo "Configurando picom..."
	  if [ -d $ruta_repo/picom/ ]; then
		if cp -r $ruta_repo/picom/* $HOME/.config/; then
			echo "PICOM configurado correctamente."
		else
			echo "La configuración de PICOM no se ha podido copiar correctamente."
			error=1
		fi
	  else
		echo "El directorio $ruta_repo/picom/ no existe. PICOM no se configurará."
	  fi
	echo

	# Configuración de polybar
	echo "Configurando POLYBAR..."
	echo "Se requieren permisos de sudo para configurar POLYBAR."
	  if [ -d /etc/polybar/ ] && sudo cp -r $ruta_repo/polybar/* /etc/polybar/; then
		echo "POLYBAR configurado correctamente."
	  else
		echo "La configuración de POLYBAR no se ha podido copiar correctamente."
		error=1
	  fi
	echo

	# Configuración de starship
	echo "Configurando STARSHIP..."
	  if ! grep -qw 'eval "$(starship init bash)"' ~/.bashrc; then
		echo "#Configuración de starship" >> ~/.bashrc
		echo -e 'eval "$(starship init bash)" \n' >> ~/.bashrc
		echo "STARSHIP configurado correctamente."
	  else
		echo "STARSHIP ya se encuentra configurado. No se realizará ninguna acción adicional."
	  fi
	echo

	# Configuración de tmux
	echo "Configurando TMUX..."
	  if [ -d $ruta_repo/tmux/ ]; then
		if cp -r $ruta_repo/tmux/* $HOME/; then
			echo "TMUX configurado correctamente."
		else
			echo "La configuración de TMUX no se ha podido copiar correctamente."
			error=1
		fi
	  else
		echo "El directorio $ruta_repo/tmux/ no existe. TMUX no se configurará."
	  fi
	echo

	# Scripts
	echo "Configurando SCRIPTS..."
	mkdir $HOME/.scripts/ &>/dev/null
	  if [ -d $ruta_repo/.scripts/ ]; then
		if cp -r $ruta_repo/.scripts/* $HOME/.scripts/ && chmod ug+x $HOME/.scripts/*; then
			echo "SCRIPTS configurados correctamente."
		else
			echo "Los SCRIPTS no se han podido copiar correctamente."
			error=1
		fi
	  else
		echo "El directorio $ruta_repo/.scripts/ no existe. Los SCRIPTS no se configurarán."
	  fi
	echo
	
	  if [ $error -eq 1 ]; then
		echo "Compruebe los permisos de escritura y vuelva a intentarlo." && echo
	  fi

	# Limpieza
	  if [ $POST_CLEAN == "true" ]; then
		echo "Eliminando repositorio temporal..."
		rm -rf /tmp/entorno_bspwm/ &>/dev/null
		echo "Hecho."
	  fi
	clear_screen
		;;
	4)
	echo "Estado de los programas PRINCIPALES que componen el entorno: "
	  for i in ${programas[@]}; do
		prog_path=$(command -v $i)
		if [ ! -z $prog_path ]; then
			echo "$i se encuentra instalado en $prog_path"
		else
			echo "$i no se encuentra instalado o no se encuentra en \$PATH"
		fi
	  done
	clear_screen
		;;
	5)
	echo "===================================="
	echo " Programas principales y sus rutas "
	echo "===================================="
	echo

	declare -A rutas
	rutas=(
	  [bspwm]="$HOME/.config/bspwm/"
	  [sxhkd]="$HOME/.config/sxhkd/"
	  [kitty]="$HOME/.config/kitty/"
	  [picom]="$HOME/.config/picom.conf"
	  [polybar]="/etc/polybar/ (global)"
	  [starship]="~/.bashrc (se inicializa aqui)"
	  [tmux]="$HOME/.tmux.conf"
	)

	for prog in ${!rutas[@]}; do
		echo " $prog → ${rutas[$prog]}"
	done
	echo " scripts → $HOME/.scripts/"
	clear_screen
		;;
	6)
	echo "A continuación se van a desinstalar los siguientes programas:"
	for i in ${programas[@]}; do
		echo -e " -$i"
	done
	for i in ${programas_no_apt[@]}; do
		echo -e " -$i"
	done

	if continue_check; then
		#sudo apt remove ${programas[@]}
		echo "No se han eliminado los ficheros de configuración."
		echo "Si desea eliminarlos, acceda a la opción 5 del menú."
		echo

		# Backup .bashrc
		if [ -f ~/.bashrc.bak ]; then
			echo "CUIDADO. Ya existe un backup del fichero .bashrc"
			echo "Continuar implicará PERDER esta copia de seguridad."
			if ! continue_check; then
				echo "Se ha cancelado la operación."
				clear_screen
				break
			fi
			echo
		fi
		if cp ~/.bashrc ~/.bashrc.bak; then
			echo "Se ha generado un backup del fichero bashrc en ~/.bashrc.bak"
			echo "Si ha perdido alguna configuración, asegúrese de restaurarla a través de este backup."
			echo
		fi

		# Desinstalar Starship
		echo "Desinstalando Starship..."
		if sh -c 'rm -f "$(command -v 'starship') 2>/dev/null"' \
		  && grep -vwe 'eval "$(starship init bash)"' -e '#Configuración de starship' ~/.bashrc > /tmp/bashrc.tmp \
		  && mv /tmp/bashrc.tmp ~/.bashrc; then
			echo "Se ha desinstalado Starship correctamente."
		fi
	fi

		;;
	7)
		echo "Saliendo"
		exit 0
		;;
	*)
		
		;;
  esac
done

echo

