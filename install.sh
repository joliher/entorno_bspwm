#!/bin/bash

if [ $(whoami) != "root" ]; then
	echo "Debes ejecutar este script como root"
	exit 1
fi

###########################
# Definición de variables #
###########################

usuario=$(logname)
programas=('bspwm' 'sxhkd' 'kitty' 'picom' 'polybar' 'tmux' 'pulseaudio' 'curl' 'git' 'lightdm' 'lightdm-gtk-greeter')
programas_no_apt=('starship')
opcional=('tar' 'bzip2' 'wget')

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
		if ! dpkg -l $i &>/dev/null; then
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
		apt install ${programas[@]} ${opcional[@]}
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
		apt install ${opcional[@]}
	  fi
		;;
	3)
	  if ! check_programs; then
		echo "Faltan programas por instalar"
		break
	  fi

sudo -u "$usuario" bash << 'EOF'
	
	  # Preparación
		cd /tmp && git clone https://github.com/joliher/entorno_bspwm &>/dev/null
		ruta_repo=/tmp/entorno_bspwm
	  
	  # Configuración de bspwm
		mkdir $HOME/.config/bspwm/ &>/dev/null
		mv $ruta_repo/bspwm/* $HOME/.config/bspwm/
		chmod +x $HOME/.config/bspwm/bspwmrc

	  # Configuración de sxhkd
	  	mkdir $HOME/.config/sxhkd/ &>/dev/null
		mv $ruta_repo/sxhkd/* $HOME/.config/sxhkd/

	  # Configuración de kitty
		mv $ruta_repo/kitty/* $HOME/.config/

	  # Configuración de picom
		mv $ruta_repo/picom/* $HOME/.config/

	   # Configuración de starship
		if ! grep -qw 'eval "$(starship init bash)"' ~/.bashrc; then
		  echo "#Configuración de starship" >> ~/.bashrc
		  echo -e 'eval "$(starship init bash)" \n' >> ~/.bashrc
		  echo "Starship configurado"
		fi

	  # Configuración de tmux
		mv $ruta_repo/tmux/* $HOME/

	  # Scripts
	  	mkdir $HOME/.scripts/ &>/dev/null
		mv $ruta_repo/.scripts/* $HOME/.scripts/
		chmod ug+x $HOME/.scripts/*
	
EOF

	  # Configuración de polybar
		mv /tmp/entorno_bspwm/polybar/* /etc/polybar/

	  # Limpieza
		rm -rf /tmp/entorno_bspwm/ &>/dev/null


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

