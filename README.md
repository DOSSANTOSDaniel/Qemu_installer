# Qemu_installer

  - Le script doit être lancé en tant que root.
  
  ## Rôle:                                                                                   
  A l'aide de Qemu ce script va permettre d'installer, tester ou démarrer différents systèmes d'exploitation 
  directement sur ou à partir de périphériques de stockage ou de disques virtuels.
  
  ## Détail des fonctionnalités :
  1. Installation de systèmes d'exploitation sur un support physique ou virtuel.
  2. Teste des live cd.
  3. Exécution de systèmes déjà installés soit avec un support de stockage physique ou virtuel.

  ## Usage :
  ```Bash
  ./qemu_installer -[h|v]
  
  ./qemu_installer -[d|o|s] <Arguments>
  ```  
  * -h : Aide.
  * -v : Affiche la version.
  ---
  * -d : Disque.(sda,sdb,sdc... ou disque virtuel au format raw)
  * -o : Fichier ISO ou IMG.
  * -s : Taille du disque virtuel en GB.

  ## Exemples :
  * Pour Installer Debian sur un périphérique physique (hd, ssd, usb):
  ```Bash  
  ./qemu_installer -d sdb -o /home/daniel/debian.iso
  ```  
  * Pour Installer Debian sur un disque virtuel (disque virtuel de 20 GB):
  ```Bash
  ./qemu_installer -s 20 -o /home/daniel/debian.iso  
  ```  
  * Pour tester un image live du système Debian:
  ```Bash
  ./qemu_installer -o /home/daniel/debian.iso
  ```
  * Pour Lancer un système déjà installé sur un disque (clé USB, SSD, HD):
  ```Bash
  ./qemu_installer -d sdb
  ```  
  * Pour Lancer un système déjà installé sur un disque virtuel (au format raw):
  ```Bash
  ./qemu_installer -d /home/daniel/Qemu_vms/disk_antiX-19.4_x64-full_13692.img
  ```
  
  ## Autre exemple :
  ### Installation d'Antix sur un disque virtuel.
  ![Image logo google](images/cap.png)

  