#!/bin/bash

if [ $(whoami) != "root" ]; then
	echo "Debes ejecutar este script como root"
	exit 1
fi

###########################
# Definición de variables #
###########################
programas=('bspwm' 'sxhkd' 'kitty' 'picom' 'polybar' 'tmux')
programas_no_apt=('starship')
opcional=('curl' 'tar' 'bzip2' 'wget')

function install_check () {
  read -p "Deseas proseguir con la instalación? y/N: " quest1

  if [ "${quest1,,}" != "y" ]; then
	echo "Abortando..."
	exit 1
  else
	read -p "Deseas proseguir con la instalación? (double check) y/N: " quest2
  	if [ "${quest2,,}" != "y" ]; then
		echo "Abortando..."
		exit 1
	fi
  fi

  echo "Procediendo a la instalación..."
}

########
# Main #
########
echo "Se van a instalar los siguientes programas:"
for i in ${programas[@]}; do
	echo -e " -$i"
done
for i in ${programas_no_apt[@]}; do
	echo -e " -$i"
done
echo "Así como las siguientes dependencias:"
for i in ${opcional[@]}; do
	echo -e " -$i"
done
install_check

apt install ${programas[@]} ${opcional[@]}

echo -e "\nA continuación se van a instalar los programas que no se pueden instalar mediante APT"
read -n1 -s -r -p "Presione una tecla para continuar..." && echo ""

# Instalación de starship
curl -sS https://starship.rs/install.sh | sh

###################
# Configuraciones #
###################

# Configuración de bspwm

# Configuración de sxhkd

# Configuración de kitty

# Configuración de picom

# Configuración de polybar

# Configuración de starship
if ! grep -qw 'eval "$(starship init bash)"' ~/.bashrc && which starship &>/dev/null
then
	echo "#Configuración de starship" >> ~/.bashrc
	echo -e 'eval "$(starship init bash)" \n' >> ~/.bashrc
fi

# Configuración de tmux

###########
# Scripts #
###########

