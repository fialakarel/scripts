#!/bin/sh

# This script will initialize kubectl

#Author    :Karel Fiala
#Email     :fiala.karel@gmail.com
#Version   :v1.0.0
#Date      :20200530
#Usage     :wget -q https://raw.githubusercontent.com/fialakarel/scripts/master/ci/install-kubectl.sh -O - | sh -

set -ef

log() {
    echo "[install-kubectl] ${*}"
}

log 'Getting latest stable version number'
stable_version="$(wget --quiet "https://storage.googleapis.com/kubernetes-release/release/stable.txt" -O -)"

log 'Downloading kubectl'
wget --quiet "https://storage.googleapis.com/kubernetes-release/release/${stable_version}/bin/linux/amd64/kubectl" -O /usr/bin/kubectl

log 'Setting permissions'
chmod +x /usr/bin/kubectl
