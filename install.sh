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


configs=(
  git
  hammerspoon
  inputrc
  macosx
  muttrc
  profile
  pryrc
  railsrc
  screenrc
  tmux
  vimrc
)

progs=(
  ack
  bash-completion
  curl
  ghostscript
  git
  htop                          # A utility like top
  hub                           # CLI to interface with github
  macvim
  mutt                          # mutt e-mail client
  nmap                          # Nmap network tool
  postgresql
  rbenv
  ruby-build
  tig                           # Tig GUI for git history log
  tmux
  tree
  vim
  watch
  wget
  yarn
)

if [[ $KERNEL = "Darwin" ]]; then
  INSTALL_CMD="brew install"
fi
if [[ $KERNEL = "Linux" ]]; then
  INSTALL_CMD="sudo apt-get install"
  progs+=(
      fluxbox                       # fluxbox environment
      gftp                          # FTP graphical user interface
      gnome-do                      # Quicksilver like utility
      openssh-server                # SSH Server
      sshfs                         # Utility to mount filesystem over SSH
      texlive-full                  # LaTeX full version
      thunderbird                   # Thunderbird e-mail client
      traceroute                    # Traceroute network utility
      vlc                           # VLC media player
      vncviewer                     # VNC client
      vpnc                          # VPN client
      xfce4-power-manager           # Power management icon in dock
      xlockmore                     # Utility to lock screen
      # aircrack-ng                   # Aircrack utility to crack WEP password
      # apache2                       # Apache server
      # enigmail                      # GPG extension for thunderbird
      # macchanger                    # MAC address changer
      # macchanger-gtk                # MAC address changer
      # pgp                           # PGP (Pretty Good Privacy) signatures program
  )
  configs+=(
    window_manager
  )
fi

for config in ${configs[@]}
do
  if [[ ! -d ${PATH_TO_FILE}/${config}  ]]; then
    git clone git@github.com:mydots/${config}.git ${PATH_TO_FILE}/${config}
    # Append to .gitignore if first time
    if [[ `grep ${config} ${PATH_TO_FILE}/.gitignore | wc -l | awk '{print $1}'` -lt 1 ]]; then
      echo "${config}" >> ${PATH_TO_FILE}/.gitignore
    fi
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
