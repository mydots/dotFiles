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

if [[ $KERNEL = "Darwin" ]]; then
  INSTALL_CMD="brew install"
fi
if [[ $KERNEL = "Linux" ]]; then
  INSTALL_CMD="sudo apt-get install"
fi

configs=$(ruby -ryaml -e 'data = YAML.load_file("programs.yml"); puts(data["configs"][ARGV[0].downcase].flatten.sort.join(" "))' $KERNEL)
for config in $configs; do
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
for config in $configs; do
  if [[ -e ${PATH_TO_FILE}/${config}/install.sh  ]]; then
    bash ${PATH_TO_FILE}/${config}/install.sh
  fi
done

cd ${PATH_TO_FILE}
apps=$(ruby -ryaml -e 'data = YAML.load_file("programs.yml"); puts(data["apps"][ARGV[0].downcase].flatten.sort.join(" "))' $KERNEL)
echo "The program will install the following:${GREEN}"
for app in $apps; do
  echo ${app}
done

# Make sure User know which programs they are installing and confirm
echo "${RED}Is the correct list above correct? [y/n]${DEFAULT}"
read CORRECT
while [[ "$CORRECT" != "y" && "$CORRECT" != "n" ]]
do
  echo "Please enter y or n, is the list above correct?"
  read CORRECT
done
if [ "$CORRECT" = "y" ]; then
  echo "Ok, installing programs"
  # Finally, install the programs
  ${INSTALL_CMD} ${apps}
fi

cd ${PATH_TO_FILE}
if [[ $KERNEL = "Darwin" ]]; then
  progs=$(ruby -ryaml -e 'data = YAML.load_file("programs.yml"); puts(data["brew"][ARGV[0].downcase].flatten.sort.join(" "))' $KERNEL)
  brew cask install $progs
fi
