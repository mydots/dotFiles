#!/bin/bash

export    RED="[0;31m"
export    GREEN="[0;32m"
export    DEFAULT="[0;39m"

KERNEL="$(uname -s)";

PATH_TO_FILE="$(cd `dirname $0` && pwd)";

set -e

touch ~/.keys
if [[ "$EMAIL_0" == "" ]]; then
  echo "Please enter your email" 
  read EMAIL_0
  echo "export EMAIL_0=${EMAIL_0}" >> ~/.keys
fi
source ~/.keys


configs=(profile vimrc pryrc git railsrc window_manager macosx muttrc screenrc tmux inputrc)

for config in ${configs[@]}
do
  if [[ ! -d ${PATH_TO_FILE}/${config}  ]]; then 
    git clone git@github.com:frankywahl/_${config}.git ${PATH_TO_FILE}/${config} 
    # Append to .gitignore if first time
    if [[ `grep ${config} ${PATH_TO_FILE}/.gitignore | wc -l | awk '{print $1}'` -lt 1 ]]; then
      echo "${config}" >> ${PATH_TO_FILE}/.gitignore
    fi
    cd ${PATH_TO_FILE}/${config}
    git remote rename origin Github
  else
    cd ${PATH_TO_FILE}/${config}
    git pull 
  fi
done
git submodule init && git submodule update  
for config in ${configs[@]}
do
  if [[ -e ${PATH_TO_FILE}/${config}/install.sh  ]]; then 
    bash ${PATH_TO_FILE}/${config}/install.sh 
  fi
done


progs=(watch tig curl wget htop nmap ghostscript tree ruby-build rbenv vim tmux)

if [[ $KERNEL = "Darwin" ]]; then
  INSTALL_CMD="brew install"
fi
if [[ $KERNEL = "Linux" ]]; then
  INSTALL_CMD="sudo apt-get install"
  progs+=(
      openssh-server                # SSH Server
      fluxbox                       # fluxbox environment 
      mutt                          # mutt e-mail client
      thunderbird                   # Thunderbird e-mail client 
      vlc                           # VLC media player
      mplayer                       # Mplayer media player
      subversion                    # SVN version control system
      gftp                          # FTP graphical user interface
      xlockmore                     # Utility to lock screen
      xfce4-power-manager           # Power management icon in dock
      sshfs                         # Utility to mount filesystem over SSH
      gnome-do                      # Quicksilver like utility
      texlive-full                  # LaTeX full version
      tig                           # Tig GUI for git history log
      aircrack-ng                   # Aircrack utility to crack WEP password
      macchanger                    # MAC address changer 
      macchanger-gtk                # MAC address changer 
      pgp                           # PGP (Pretty Good Privacy) signatures program 
      enigmail                      # GPG extension for thunderbird 
      mysql-server                  # MySQL server
      apache2                       # Apache server
      phpmyadmin                    # PhpMyAdmin (for MySQL server)
      libapache2-mod-auth-mysql     # Required by apache and MySQL
      python-mysqldb                # MySQL in python scripts
      vpnc                          # VPN client
      network-manager-vpnc
      network-manager-openvpn
      network-manager-pptp
      vncviewer                     # VNC client
      screen                        # Screen Manager
      htop                          # A utility like top
      traceroute                    # Traceroute network utility
      nmap                          # Nmap network tool
     php5-gd                        # Needed for securimage captcha code
     postfix                        # Needed to send mail via website
      )
fi


# Get length of array
let number_of_progs=${#progs[@]}-1;

# Make one long list out of it
all_progs=""
echo "The program will install the following:${GREEN}"
for i in `seq 0 ${number_of_progs}`; do 
  echo "  ${progs[$i]}"
  all_progs=" $all_progs ${progs[$i]}";
done

# Make sure User know which programs they are installing and confirm 
echo "${RED}Is the correct list above correct? [y/n]${DEFAULT}"
read CORRECT
while [[ "$CORRECT" != "y" && "$CORRECT" != "n" ]]
do
  echo "Please enter y or n, is the list above correct?"
  read CORRECT
done
if [ "$CORRECT" = "n" ]; then
  echo "Ok, Not installing ports program"
  exit 1
fi

# Finally, install the programs
${INSTALL_CMD} ${all_progs}
