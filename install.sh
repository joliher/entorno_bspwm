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


function install_proceed () {
  read -p "Deseas proseguir con la instalación? y/N: " quest1

  if [ "${quest1,,}" != "y" ]; then
	echo "Abortando..."
	return 1
  else
	read -p "Deseas proseguir con la instalación? (double check) y/N: " quest2
  	if [ "${quest2,,}" != "y" ]; then
		echo "Abortando..."
		return 1
	fi
  fi

  echo "Procediendo a la instalación..."
}

function check_programs () {
	por_instalar=()
	error=0

	for i in ${programas[@]}; do
		if ! command -v $i &>/dev/null; then
			por_instalar+=("$i")
			error=1
		fi
	done
	if ! which starship &>/dev/null; then
		por_instalar+=('starship')
		error=1
	fi

	if [ $error -eq 1 ]; then
		return 1
	fi
	
	return 0
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
  echo "6) Salir"
  echo "=============================="

  read -p "Elige una opción [1-6]: " opt

  case $opt in
	1)
	  echo "Se van a instalar los siguientes programas:"
	  for i in ${programas[@]}; do
		echo -e " -$i"
	  done
	  for i in ${programas_no_apt[@]}; do
		echo -e " -$i"
	  done

	  if install_proceed; then
		sudo apt install ${programas[@]}
		# Instalación de starship
		if ! which starship &>/dev/null; then
			curl -sS https://starship.rs/install.sh | sh
		else
			echo "Starship ya se encuentra instalado"
		fi
	  fi
		;;
	2)
	  echo "Se van a instalar los siguientes programas:"
	  for i in ${opcional[@]}; do
		echo -e " -$i"
	  done

	  if install_proceed; then
		sudo apt install ${opcional[@]}
	  fi
		;;
	3)
	if ! check_programs; then
		echo "Faltan programas por instalar"
	fi

	# Preparación
	  cd $(dirname $0)
	if [ $USE_LOCAL == "true" ]; then
		echo "Usando repositorio local en $(pwd)..."
		echo "Asegurese de todos los archivos de configuración necesarios existan"
		ruta_repo=$(pwd)
		POST_CLEAN=false
	else
	  	cd /tmp && git clone https://github.com/joliher/entorno_bspwm &>/dev/null
		ruta_repo=/tmp/entorno_bspwm
		POST_CLEAN=true
	fi

	# Configuración de bspwm
	  echo "Configurando BSPWM..."
	  mkdir -p $HOME/.config/bspwm/ &>/dev/null
	if [ -d $ruta_repo/bspwm/ ]; then
		if cp -r $ruta_repo/bspwm/* $HOME/.config/bspwm/ && chmod +x $HOME/.config/bspwm/bspwmrc; then
			echo "BSPWM configurado correctamente"
		else
			echo "No se ha podido configurar BSPWM."
		fi
	else
		echo "No se ha podido configurar BSPWM."
	fi
	  echo ""

	# Configuración de sxhkd
	  echo "Configurando SXHKD..."
	  mkdir -p $HOME/.config/sxhkd/ &>/dev/null
	if [ -d $ruta_repo/sxhkd ]; then
		if cp -r $ruta_repo/sxhkd/* $HOME/.config/sxhkd/; then
			echo "SXHKD configurado correctamente"
		else
			echo "No se ha podido configurar SXHKD"
		fi
	else
		  echo "No se ha podido configurar SXHKD"
	fi
	  echo ""

	# Configuración de kitty
	  echo "Configurando KITTY"
	if [ -d $ruta_repo/kitty/ ]; then
		if cp -r $ruta_repo/kitty/* $HOME/.config/; then
			echo "KITTY configurado correctamente"
		else
			echo "No se ha podido configurar KITTY"
		fi
	else
		echo "No se ha podido configurar KITTY"
	fi
	  echo ""

	# Configuración de picom
	  echo "Configurando picom"
	if [ -d $ruta_repo/picom/ ]; then
		if cp -r $ruta_repo/picom/* $HOME/.config/; then
			echo "PICOM configurado correctamente"
		else
			echo "No se ha podido configurar PICOM"
		fi
	else
		echo "No se ha podido configurar PICOM"
	fi
	  echo ""

	# Configuración de polybar
	  echo "Configurando POLYBAR"
	  echo "Se requieren permisos de sudo para configurar POLYBAR"
	if [ -d /etc/polybar/ ] && sudo cp -r $ruta_repo/polybar/* /etc/polybar/; then
		echo "POLYBAR configurado correctamente"
	else
		echo "No se ha podido configurar POLYBAR"
	fi
	  echo ""

	# Configuración de starship
	  echo "Configurando STARSHIP"
	if ! grep -qw 'eval "$(starship init bash)"' ~/.bashrc; then
		echo "#Configuración de starship" >> ~/.bashrc
		echo -e 'eval "$(starship init bash)" \n' >> ~/.bashrc
		echo "STARSHIP configurado correctamente"
	else
		echo "STARSHIP ya se encuentra configurado. No se realizará ninguna acción adicional"
	fi
	  echo ""

	# Configuración de tmux
	  echo "Configurando TMUX..."
	if [ -d $ruta_repo/tmux/ ]; then
		if cp -r $ruta_repo/tmux/* $HOME/; then
			echo "TMUX configurado correctamente"
		else
			echo "No se ha podido configurar TMUX"
		fi
	else
		echo "No se ha podido configurar TMUX"
	fi
	  echo ""

	# Scripts
	  echo "Configurando SCRIPTS..."
	  mkdir $HOME/.scripts/ &>/dev/null
	if [ -d $ruta_repo/.scripts/ ]; then
		if cp -r $ruta_repo/.scripts/* $HOME/.scripts/ && chmod ug+x $HOME/.scripts/*; then
			echo "SCRIPTS configurados correctamente"
		else
			echo "No se han podido configurar los SCRIPTS"
		fi
	else
		echo "No se han podido configurar los SCRIPTS"
	fi
	 echo ""
	
	# Limpieza
	  if [ $POST_CLEAN == "true" ]; then
		  rm -rf /tmp/entorno_bspwm/ &>/dev/null
	  fi
		;;
	4)

		;;
	5)

		;;
	6)
		echo "Saliendo"
		exit 0
		;;
	*)
		
		;;
  esac
done

echo ""

