# Qemu_installer
Script permettant l'installation et le test de differents OS

./qemu_installer -[h|v|d|o] <Argument>
  
  Le script doit être lancé en tant que root.
  
  Rôle:                                          
  A l'aide de Qemu ce script va permettre d'installer differents systèmes d'exploitation 
  directement sur des périferiques de stockage comme des clés USB ou disques dur
  sans avoir besoin de redémarrer l'ordinateur host.
  
  Détail des fonctionnalités :
  1. Installation de systèmes d'exploitation.
  2. Teste des live cd.
  
  ```
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
  
  ```
