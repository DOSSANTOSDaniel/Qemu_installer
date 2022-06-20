# Qemu_installer
  
## Rôle                                                                                   
  A l'aide de Qemu ce script va permettre d'installer, tester ou démarrer différents systèmes d'exploitation 
  directement sur ou à partir de périphériques de stockage ou de disques virtuels.
  
## Détail des fonctionnalités
  1. Installation de systèmes d'exploitation sur un support physique ou virtuel.
  2. Teste de live cd.
  3. Exécution de systèmes déjà installés soit avec un support de stockage physique ou virtuel.
  4. Exécution de live cd avec un support de stockage physique ou virtuel, dans le but par exemple de réparer le Grub sur une installation.
  5. Passthrough USB, se qui va nous permettre d’accéder à un périphérique USB sur la machine host directement à partir de la machine virtuelle.
  6. Connexion SSH à partir du port 2222.

## Infos
  - Le script doit être lancé en tant que root.
  - Ce script est seulement compatible avec des installations en 64bits.
  - Création du dossier /home/$USER/Qemu_vms/ pour stocker les images disque, si utilisation.
  - Chaque disque virtuel est crée au format RAW.
  - Démarrer un seul système d'exploitation à la fois sur votre machine.
  - Choix de certaines données :
	  + Mémoire RAM pour la VM : Mémoire RAM de la machine physique divisée par deux.
	  + Cœurs CPU : Cœurs CPU de ma machine physique divisée par deux.
	  + Mémoire du disque virtuel : Données par l'utilisateur. 
 
## Usage
  ```Bash
  ./qemu_installer -[h|v|u]
  
  ./qemu_installer -[d|o|s] <Arguments>
  ```  
  * -h : Aide.
  * -v : Affiche la version.
  * -u : Passthrough USB.
  
  * -d : Disque.(sda,sdb,sdc... ou disque virtuel)
  * -o : Fichier ISO ou IMG.
  * -s : Taille du disque virtuel en GB.

## Exemples

La commande pour connaître le nom du disque à utiliser : 
```Bash
$ lsblk --exclude 7
```

  * Pour Installer Debian sur un périphérique physique (hd, ssd, usb):
  ```Bash  
  sudo ./qemu_installer -d sdb -o /home/daniel/debian.iso
  ```  
  * Pour Installer Debian sur un disque virtuel (disque virtuel de 20 GB):
  ```Bash
  sudo ./qemu_installer -s 20 -o /home/daniel/debian.iso  
  ```  
  * Pour tester un image live du système Debian:
  ```Bash
  sudo ./qemu_installer -o /home/daniel/debian.iso
  ```
  * Pour Lancer un système déjà installé sur un disque (clé USB, SSD, HD):
  ```Bash
  sudo ./qemu_installer -d sdb
  ```  
  * Pour Lancer un système déjà installé sur un disque virtuel :
  ```Bash
  sudo ./qemu_installer -d /home/daniel/Qemu_vms/disk_antiX-19.4_x64-full_13692.img
  ```
  * Pour modifier un système déjà installé avec l'aide d'un live cd (En cas de problème avec Grub par exemple):
  ```Bash
  sudo ./qemu_installer -d /home/daniel/Qemu_vms/disk_debian-10-28595.img -o rescatux-0.73.iso
  ```
  
## Autre exemple
### Installation de Manjaro sur un disque virtuel de 10 GB (format RAW) et activation du passthrough USB, se qui va nous permettre d’accéder à un périphérique USB directement à partir de la machine virtuelle.

1. Lancer le script.
  ```Bash
  sudo ./qemu_installer.sh -s 10 -o manjaro-sway-21.0-210428-linux510.iso -u  
  ``` 
2. Choisir le périphérique USB.

3. Lancement de l'installation.
  ![capture](https://github.com/DOSSANTOSDaniel/Qemu_installer/blob/main/images/Cap.png)

## A faire
  
- [ ] Ajouter la possibilité de démarrer des installations en EFI.
- [ ] Fonction de partitionnement automatique des périphériques de stockage pour des installations type.
- [ ] Avoir le copier coller dans la fenêtre Qemu.
- [ ] Ajouter TPM2 pour les installations de Windows 11.
- [ ] Créer une meilleure gestion des ressources automatiquement ou laisser l'utilisateur choisir.
- [ ] Pouvoir choisir l'architecture.
