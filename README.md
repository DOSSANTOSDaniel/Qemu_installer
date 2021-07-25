# Qemu_installer
Script permettant l'installation et le test de differents OS sur differents supports

./qemu_installer -[h|v|d|o] <Argument>
  
  Le script doit être lancé en tant que root.
  
  ### Rôle:                                          
  A l'aide de Qemu ce script va permettre d'installer differents systèmes d'exploitation 
  directement sur des périferiques de stockage comme des clés USB ou disques dur
  sans avoir besoin de redémarrer l'ordinateur host.
  
  Détail des fonctionnalités :
  1. Installation de systèmes d'exploitation.
  2. Teste des live cd.
  
  ```
  ### Usage :
  ```Bash
  ./qemu_installer -[h|v]
  
  ./qemu_installer -[d|o] <Argument>
  
  -h : Aide.
  -v : Affiche la version.
  
  -d : Disque.(sda,sdb,sdc...)
  -o : Fichier ISO ou IMG.(fichier.iso)
  ```
  ### Exemples :
  * Pour Installer Debian sur le péripherique sdb :
  ```Bash
  ./qemu_installer -d sdb -o /home/daniel/debian.iso
  ```
  
  * Pour tester une image iso de Debian :
  ```Bash
  ./qemu_installer -o /home/daniel/debian.iso
  ```
  
  * Pour Lancer un système d'exploitation déjà installé sur un disque (clé USB, SSD, HD) :
  ```Bash
  ./qemu_installer -d sdb
  ```
  

