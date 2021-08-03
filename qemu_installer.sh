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
  
  Paramètres passés : ${@}
  
  Le script doit être lancé en tant que root.
  
  Rôle:                                          
  A l'aide de Qemu ce script va permettre d'installer, tester ou démarrer différents systèmes d'exploitation directement sur ou à partir de périphériques de stockage ou de disques virtuels.
  
  Détail des fonctionnalités :
  1. Installation de systèmes d'exploitation sur un support physique ou virtuel.
  2. Teste des live cd.
  3. Exécution de systèmes déjà installés soit avec un support de stockage physique ou virtuel.

  Usage:
  ./$(basename ${0}) -[h|v]
  
  ./$(basename ${0}) -[d|o|s] <Arguments>
  
  -h : Aide.
  -v : Affiche la version.
  
  -d : Disque.(sda,sdb,sdc... ou disque virtuel au format raw)
  -o : Fichier ISO ou IMG.
  -s : Taille du disque virtuel en GB.
  
  Exemples:
  * Pour Installer Debian sur un périphérique physique (hd, ssd, usb):
  ./$(basename ${0}) -d sdb -o /home/daniel/debian.iso
  
  * Pour Installer Debian sur un disque virtuel (disque virtuel de 20 GB):
  ./$(basename ${0}) -s 20 -o /home/daniel/debian.iso  
  
  * Pour tester un image live du système Debian:
  ./$(basename ${0}) -o /home/daniel/debian.iso

  * Pour Lancer un système déjà installé sur un disque (clé USB, SSD, HD):
  ./$(basename ${0}) -d sdb
  
  * Pour Lancer un système déjà installé sur un disque virtuel :
  ./$(basename ${0}) -d /home/daniel/Qemu_vms/disk_antiX-19.4_x64-full_13692.img 

EOF
}

version() {
  local ver='2'
  local dat='01/08/21'
  cat << EOF
  
  ___ Script : $(basename ${0}) ___
  
  Version : ${ver}
  Date : ${dat}
  
EOF
}

test_img() {
  local user="$userhost"
  local ram="${ramvmmb}M"
  local cpu="$cpuvm"
  local img="$img_sys"
  
  qemu-system-x86_64 \
  -runas $user \
  -cpu host \
  -soundhw all \
  -k fr \
  -accel kvm \
  -show-cursor \
  -enable-kvm \
  -m $ram \
  -smp $cpu \
  -device virtio-net,netdev=vmnic \
  -netdev user,id=vmnic,hostfwd=tcp:127.0.0.1:2222-:22 \
  -cdrom $img \
  -boot d &
  
  pid_qemu="$!"
}

install_hard() {
  local user="$userhost"
  local ram="${ramvmmb}M"
  local cpu="$cpuvm"
  local disk="$disk_device"
  local img="$img_sys"

  qemu-system-x86_64 \
  -runas $user \
  -cpu host \
  -soundhw all \
  -k fr \
  -accel kvm \
  -show-cursor \
  -enable-kvm \
  -m $ram \
  -smp $cpu \
  -device virtio-net,netdev=vmnic \
  -netdev user,id=vmnic,hostfwd=tcp:127.0.0.1:2222-:22 \
  -drive file=${disk},format=raw \
  -cdrom $img \
  -boot once=d &
  
  pid_qemu="$!"
}

install_virt() {
  local user="$userhost"
  local ram="${ramvmmb}M"
  local cpu="$cpuvm"
  local disk="$disk_device"
  local img="$img_sys"

  local size_disk="$size_vm_img"
  local img_name="$(basename $(basename -- $img .iso) .img)"
  
  # create directory
  if ! [[ -d $dir_vm_img ]]
  then
    su -l $user -c "mkdir $dir_vm_img" -s /bin/bash
  fi

  # create virtual disk
  img_name_out="disk_${img_name}_${RANDOM}.img"
  
  qemu-img create -q -f raw ${dir_vm_img}/${img_name_out} ${size_disk}G
  
  qemu-system-x86_64 \
  -runas $user \
  -cpu host \
  -soundhw all \
  -k fr \
  -accel kvm \
  -show-cursor \
  -enable-kvm \
  -m $ram \
  -smp $cpu \
  -device virtio-net,netdev=vmnic \
  -netdev user,id=vmnic,hostfwd=tcp:127.0.0.1:2222-:22 \
  -drive file=${dir_vm_img}/${img_name_out},format=raw \
  -cdrom $img \
  -boot once=d &
  
  pid_qemu="$!"
}

start_sys() {
  user="$userhost"
  ram="${ramvmmb}M"
  cpu="$cpuvm"
  disk="$disk_device"

  qemu-system-x86_64 \
  -runas $user \
  -cpu host \
  -soundhw all \
  -k fr \
  -accel kvm \
  -show-cursor \
  -enable-kvm \
  -m $ram \
  -smp $cpu \
  -device virtio-net,netdev=vmnic \
  -netdev user,id=vmnic,hostfwd=tcp:127.0.0.1:2222-:22 \
  -drive file=${disk} \
  -boot c &
  
  pid_qemu="$!"
}

usb_host() {
  PS3="Votre choix : "
  mapfile -t usb_devices < <(lsusb | awk '{for(i=6;i<=NF;i++) printf $i" "; print ""}')

  echo -e "\n -- Menu USB -- "
  select ITEM in "${usb_devices[@]}" 'Quitter'
  do
    if [[ $ITEM == 'Quitter' ]]
    then
      echo "Fin du programme!"
      exit 0
    fi
    break
  done

  local vendorid="0x$(echo "$ITEM" | awk '{print $1}' | cut -d':' -f1)"
  local productid="0x$(echo "$ITEM" | awk '{print $1}' | cut -d':' -f2)"

  usb_option="-device usb-ehci,id=ehci -device usb-host,vendorid=$vendorid,productid=$productid"
}

### Global variables ###
# User host
readonly userhost="$(id -u 1000 -n)"

# Directory of img
readonly dir_vm_img="/home/$userhost/Qemu_vms"

# RAM for VM
readonly ramkb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
readonly ramvmmb=$(($ramkb / 2 / 1000))

# Disk
disk_device=""

# IMG
img_sys=""

# Size image disk
size_vm_img=""

# Name img out
img_name_out=""

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
  readonly cpuvm=$(($(nproc) / 2))
else
  readonly cpuvm='1'
fi

# Filter user options
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
fi

while getopts "hvd:o:s:" argument
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
      readonly disk_device_all="${OPTARG}"
      ;;
    o)
      readonly img_sys="${OPTARG}"
      ;;
    s)
      readonly size_vm_img="${OPTARG}"
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

# Install dependencies 
if ! (qemu-system-x86_64 -version)
then
  apt-get install ovmf qemu qemu-system-x86 -y
fi

if [[ ! -z ${disk_device} && ! -z ${img_sys} && -z $size_vm_img ]]
then
  readonly regex="^[s][d][a-z]$"

  if [[ $disk_device =~ ${regex} ]]
  then
    readonly disk_device="/dev/${disk_device_all}"
  else
    readonly disk_device="$disk_device_all"
  fi
  
  install_hard
elif [[ -z ${disk_device} && ! -z ${img_sys} && ! -z $size_vm_img ]]
then
  # Size of virtual disk
  ## free space of host disk
  readonly free_space_kb="$(df --type=ext4 -l --output=avail | tail -n +2)"
  readonly free_space_mb="$((${free_space_kb}/1000))" #MB
  readonly free_space_disk="$((${free_space_mb}-10000))" # Security

  readonly size_vm_img_mb="$((${size_vm_img}*1000))"

  if [[ $size_vm_img_mb -gt ${free_space_disk} ]]
  then
    echo "Pas assez d'espace disque, espace libre: ${free_space_mb}MB"
    exit 1
  elif [[ $size_vm_img_mb -lt 1000 ]]
  then
    echo "Taille trop petite, minimum: 1000 MB pour un disque virtuel"
    exit 1
  fi
  install_virt
elif [[ -z ${disk_device} && ! -z ${img_sys} && -z $size_vm_img ]]
then
  test_img
elif [[ ! -z ${disk_device} && -z ${img_sys} && -z $size_vm_img ]]
then
  start_sys
else
  echo "Erreur de saisie"
  usage
  exit 1
fi

sleep 2

clear

if (ps -q $pid_qemu -o state --no-headers)
then
  echo -e "\n\n Résumé"
  echo -e "------------------------------------\n"
  echo "Qemu en cours de fonctionnement (PID: $pid_qemu) !"
  echo "ISO/IMG : $img_sys"
  echo "Disque : $disk_device"
  echo "Nom disque dur virtuel : $img_name_out"
  echo "Taille disque dur virtuel (en GB): ${size_vm_img}"
  echo "RAM : ${ramvmmb}MB"
  echo -e "CPU : $cpuvm \n"
fi
