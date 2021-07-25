#!/bin/bash
#-*- coding: UTF8 -*-

#--------------------------------------------------#
# Script_Name: qemu_installer.sh	                               
#                                                   
# Author:  'dossantosjdf@gmail.com'                 
# Date: dim. 25 juil. 2021 12:32:00                                             
# Version: 1.0                                      
# Bash_Version: 5.0.17(1)-release                                     
#--------------------------------------------------#
# Description:                                      
#                                                   
#                                                   
# Options:                                          
#                                                   
# Usage: ./qemu_installer.sh                                            
#                                                   
# Limits:                                           
#                                                   
# Licence:                                          
#--------------------------------------------------#

set -eu

### Includes ###

### Constants ###

### Fonctions ###

usage() {
  cat << EOF
  
  ___ Script : $(basename ${0}) ___
  
  Parametres passés : ${@}
  
  $(basename ${0}) -[h|v|d|o] <Argument>
  
  Le script doit être lancé en tant que root.
  
  Rôle:                                          
  A l'aide de Qemu ce script va permettre d'installer differents systèmes d'exploitation 
  directement sur des périferiques de stockage comme des clés USB ou disques dur
  sans avoir besoin de redémarrer l'ordinateur host.

  Détail des fonctionnalités :
  1. Installation de systèmes d'exploitation.
  2. Teste des live cd.

  Usage:
  ./$(basename ${0}) -[h|v]
  
  ./$(basename ${0}) -[d|o] <Argument>
  
  -h : Aide.
  -v : Affiche la version.
  
  -d : Disque.(sda,sdb,sdc...)
  -o : Fichier ISO ou IMG.(fichier.iso)
  
  Exemple:
  * Pour Installer Debian sur le péripherique sdb :
  ./$(basename ${0}) -d sdb -o /home/daniel/debian.iso
  
  * Pour tester le système Debian :
  ./$(basename ${0}) -o /home/daniel/debian.iso

EOF
}

version() {
  local ver='1'
  local dat='25/07/21'
  cat << EOF
  
  ___ Script : $(basename ${0}) ___
  
  Version : ${ver}
  Date : ${dat}
  
EOF
}

test_iso() {
  qemu-system-x86_64 \
  -runas $userhost \
  -cpu host \
  -no-acpi \
  -soundhw all \
  -k fr \
  -accel kvm \
  -m ${ramvmmb}M \
  -smp cpus=1,cores=$cpuvm,sockets=1,maxcpus=$cpuvm \
  -netdev user,id=network0 -device rtl8139,netdev=network0 \
  -cdrom $isovm \
  -boot d &
  
  pid_qemu="$!"
}

install_iso() {
  qemu-system-x86_64 \
  -runas $userhost \
  -cpu host \
  -no-acpi \
  -soundhw all \
  -k fr \
  -accel kvm \
  -m ${ramvmmb}M \
  -smp cpus=1,cores=$cpuvm,sockets=1,maxcpus=$cpuvm \
  -netdev user,id=network0 -device rtl8139,netdev=network0 \
  -drive file=${diskvm},format=raw \
  -cdrom $isovm \
  -boot once=d &
  
  pid_qemu="$!"
}

start_system() {
  qemu-system-x86_64 \
  -runas $userhost \
  -cpu host \
  -no-acpi \
  -soundhw all \
  -k fr \
  -accel kvm \
  -m ${ramvmmb}M \
  -smp cpus=1,cores=$cpuvm,sockets=1,maxcpus=$cpuvm \
  -netdev user,id=network0 -device rtl8139,netdev=network0 \
  -drive file=${diskvm},format=raw \
  -boot c &
  
  pid_qemu="$!"
}

### Global variables ###
# user
userhost="$(id -u 1000 -n)"

# nb ram
ramkb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
ramvmmb=$(($ramkb / 2 / 1000))

# Disk
diskvm=""

# ISO
isovm=""

### Main ###

if [[ $(id -u) -ne 0 ]]
then
  echo "Le script doit être lancé en tant que root"
  usage
  exit 1
fi

# nb proc
if [[ $(nproc) -gt 1 ]]
then
  cpuvm=$(($(nproc) / 2))
else
  cpuvm='1'
fi


# Filtrage des options utilisateur
if [[ ${#} -eq "0" ]]
then
  echo "-----> Il manque des options !"
  usage
  exit 1
elif [[ ${#} -gt "4" ]]
then
  echo "-----> Il y a trop d'options !"
  usage
  exit 1
elif [[ ${1} =~ ^[^-.] ]]
then
  echo "-----> ${1} n'est pas une option valide ! "
  usage
  exit 1
elif [[ ${1} == '-o' ]]
then
  echo "-----> ${1} Les parametres doivent commencer par -d ! "
  usage
  exit 1
fi


while getopts "hvd:o:" argument
do
  case "${argument}" in
    h)
      usage
      exit 1
      ;;
    v)
      version
      exit 1
      ;;
    d)
      readonly diskvm="/dev/${OPTARG}"
      ;;
    o)
      readonly isovm="${OPTARG}"
      ;;
    :)
      echo "L'option nécessite un argument."
      usage
      exit 1
      ;;
    \?)
      echo "Option invalide !"
      usage
      exit 1
      ;;
    *)
      exit 1
      ;;
  esac
done

# Install
apt-get install ovmf qemu qemu-system-x86 -y

regex="^[s][d][a-z]$"

if [[ ! $(basename $diskvm) =~ ${regex} ]]
then
  echo "Erreur de saisie ! :"
  echo " La valeur $(basename $diskvm) n'est pas permise !"
  usage
  exit 1
fi

if [[ -z ${diskvm} ]]
then
  test_iso
elif [[ -z $isovm ]]
then
  start_system
else
  install_iso
fi

sleep 2

clear

if (ps -q $pid_qemu -o state --no-headers)
then
  echo -e "\n\n Résumé"
  echo -e "------------------------------------\n"
  echo "Qemu en cours de fonctionnement (PID: $pid_qemu) !"
  echo "ISO : $isovm"
  echo "Disque : $diskvm"
  echo "RAM : ${ramvmmb}mb"
  echo -e "CPU : $cpuvm \n"
fi
