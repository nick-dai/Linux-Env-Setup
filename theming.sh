#!/bin/bash

# Apply these themes and icons only to Gnome-based Linux.
if type gsettings &> /dev/null ; then
    cd
    # Install icons
    git clone https://github.com/LinxGem33/Arc-OSX-Icons.git
    sudo mv Arc-OSX-Icons/src/Arc-OSX-D /usr/share/icons
    sudo mv Arc-OSX-Icons/src/Arc-OSX-P /usr/share/icons
    sudo mv Arc-OSX-Icons/src/Paper-Mono-Dark /usr/share/icons
    sudo mv Arc-OSX-Icons/src/Paper /usr/share/icons
    rm -rf Arc-OSX-Icons

    # Install themes for Linux
    # https://github.com/LinxGem33/OSX-Arc-White/releases
    sudo apt install -y gnome-themes-standard gtk2-engines-murrine
    osx_url[0]="https://github.com/LinxGem33/OSX-Arc-White/releases/download/v1.4.7/osx-arc-collection_1.4.7_amd64.deb"
    osx_url[1]="https://github.com/LinxGem33/OSX-Arc-White/releases/download/v1.4.7/osx-arc-collection_1.4.7_i386.deb"
    index=1
    if [ "$(getconf LONG_BIT)" -eq "64" ] ; then
        index=0
    fi
    # Remove patterns matching "*/"
    osx_filename=${osx_url[index]##*/}
    wget ${osx_url[index]}
    sudo dpkg -i $osx_filename
    rm -rf $osx_filename

    # printf "\n" | sudo add-apt-repository ppa:noobslab/themes
    printf "\n" | sudo add-apt-repository ppa:noobslab/icons
    sudo apt update
    # sudo apt install -y flatabulous-theme
    sudo apt install -y ultra-flat-icons

    # Set themes and icons
    # https://askubuntu.com/questions/262868/how-to-set-icons-and-theme-from-terminal
    gsettings set org.gnome.desktop.interface gtk-theme "OSX-Arc-Darker"
    gsettings set org.gnome.desktop.wm.preferences theme "OSX-Arc-Darker"
    gsettings set org.gnome.desktop.interface icon-theme "Arc-OSX-P"
fi