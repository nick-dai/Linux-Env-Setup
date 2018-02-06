#!/bin/bash

# Detect if a command exists
hasCommand() { # Declare a function
    # type: find if a command is defined in shell
    # If no return is declared in a function, it automatically returns the execution result of the last line in the function
    # $[num]: get a certain argument passed to this function, starting from 1
    type $1 &> /dev/null # Output the result to the null device
}

# Apply these themes and icons only to Gnome-based Linux.
if hasCommand gsettings ; then
    # Install icons
    git clone https://github.com/LinxGem33/Arc-OSX-Icons.git
    $dosu mv Arc-OSX-Icons/src/Arc-OSX-D /usr/share/icons
    $dosu mv Arc-OSX-Icons/src/Arc-OSX-P /usr/share/icons
    $dosu mv Arc-OSX-Icons/src/Paper-Mono-Dark /usr/share/icons
    $dosu mv Arc-OSX-Icons/src/Paper /usr/share/icons
    rm -rf Arc-OSX-Icons

    # Install themes for Linux
    # https://github.com/LinxGem33/OSX-Arc-White/releases
    $dosu $inst gnome-themes-standard gtk2-engines-murrine
    osx_url[0]="https://github.com/LinxGem33/OSX-Arc-White/releases/download/v1.4.3/osx-arc-collection_1.4.3_amd64.deb"
    osx_url[1]="https://github.com/LinxGem33/OSX-Arc-White/releases/download/v1.4.3/osx-arc-collection_1.4.3_i386.deb"
    index=1
    if [ "$bit" -eq "64" ] ; then
        index=0
    fi
    # Remove patterns matching "*/"
    filename=${osx_url[index]##*/}
    wget ${osx_url[index]}
    if [[ "$1" != "" ]]; then
        printf "$1\nexit\n" | $dosu dpkg -i $filename
    else
        $dosu dpkg -i $filename
    fi
    rm -rf $filename

    printf "\n" | $dosu add-apt-repository ppa:noobslab/themes
    printf "\n" | $dosu add-apt-repository ppa:noobslab/icons
    $dosu $pkgmgr update
    $dosu $inst flatabulous-theme ultra-flat-icons
fi