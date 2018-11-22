#!/bin/bash

sudo apt-get remove docker docker-engine docker.io -y
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y

os=$(lsb_release -cs)

# If you're using kali
if [ "${os::4}" == "kali" ]; then
    # https://medium.com/@airman604/installing-docker-in-kali-linux-2017-1-fbaa4d1447fe
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    echo 'deb https://download.docker.com/linux/debian stretch stable' > /etc/apt/sources.list.d/docker.list
    apt-get update
    apt-get install docker-ce docker-compose -y
else
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
    sudo apt-get update
    sudo apt-get install docker-ce docker-compose -y
fi

sudo groupadd docker
sudo usermod -aG docker $USER
