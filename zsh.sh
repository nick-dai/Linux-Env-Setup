#!/bin/bash

# This file supports the following arguments:
# 1. Password of the current account

# The following codes are based on these articles:
# http://www.jianshu.com/p/9a5c4cb0452d
# http://icarus4.logdown.com/posts/177661-from-bash-to-zsh-setup-tips
# https://gist.github.com/renshuki/3cf3de6e7f00fa7e744a

# Detect if a command exists
hasCommand() { # Declare a function
    # type: find if a command is defined in shell
    # If no return is declared in a function, it automatically returns the execution result of the last line in the function
    # $[num]: get a certain argument passed to this function, starting from 1
    type $1 &> /dev/null # Output the result to the null device
}

# Get system's bit
bit=$(getconf LONG_BIT)

echo "- Detecting package manager..."
pkgmgr="" # Declare a variable
if hasCommand brew; then # "brew" here is an argument for the function "hasCommand".
    pkgmgr="brew"
elif hasCommand apt; then
    pkgmgr="apt"
else
    echo "- No required package manager: brew, apt-get."
    exit 0
fi
echo "- You are using '$pkgmgr'."
inst="$pkgmgr install -y"

# Check if "sudo" is required
dosu=""
echo "- Detecting root permission..."
if [ "$EUID" -ne 0 ]; then
    if ! hasCommand brew; then
        dosu="sudo -S"
    fi
fi

echo "- Checking required packages..."
if [[ "$1" != "" ]]; then
    printf "$1\n" | $dosu $inst git curl
else
    $dosu $inst git curl
fi
# pkgs=(git curl)
# for pkg in "${pkgs[@]}"
# do
#   if ! hasCommand $pkg ; then
#       $dosu $inst $pkg
#       # $?: the execution result of the previous line
#       # A command executed successfully will return 0 (IMPORTANT: it's not false!)
#       if [ $? != 0 ]; then # Add a space at the beginning and end of a command in 'if' brackets.
#           echo "  Required package not found: $pkg."
#           exit 2
#       fi
#   fi
#   echo "  Required package is installed: $pkg."
# done

echo "- Installing zsh..."
$dosu $inst zsh
if [ $? != 0 ]; then
    echo "  Failed. Please try again!"
    exit 0
fi

echo "- Downloading Oh My Zsh..."
if [[ "$1" != "" ]]; then
    printf "$1\nexit\n" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# echo "- Setting zsh as your default shell..."
# # chsh: change your shell
# chsh -s $(which zsh)

# echo "- Installing zsh-completions..."
# git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
# if [ $? == 0 ]; then
#     echo "- Integrating zsh with zsh-completions..."
#     echo "# zsh-completions" >> $zshrc
#     echo "fpath=(/usr/local/share/zsh-completions \$fpath)" >> $zshrc
# else
#     echo "  Failed."
# fi

# zsh settings file location
zshrc=~/.zshrc

echo "- Applying themes and settings..."
# Apply 'agnoster' theme
if hasCommand brew ; then # For Mac
    sed -i "" "s/ZSH_THEME=\"\w*\"/ZSH_THEME=\"agnoster\"/g" $zshrc
else
    sed -i "s/ZSH_THEME=\"\w*\"/ZSH_THEME=\"agnoster\"/g" $zshrc
fi

# Download Powerline fonts
git clone https://github.com/powerline/fonts.git --depth=1
./fonts/install.sh
rm -rf fonts

if hasCommand gsettings ; then
    # Apply Powerline fonts to fix the '~' character
    # https://askubuntu.com/questions/731774/how-to-change-gnome-terminal-profile-preferences-using-dconf-or-gsettings]
    # For Linux using Gnome.
    profile=$(gsettings get org.gnome.Terminal.ProfilesList default) # Get defualt profile used by terminal
    profile=${profile:1:-1} # Remove leading and trailing single quotes
    # gsettings list-keys "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/"
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" font "Ubuntu Mono derivative Powerline 14"
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-system-font false
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" allow-bold false
    # Change theme of Terminal
    git clone git://github.com/sigurdga/gnome-terminal-colors-solarized.git ~/.solarized
    cd ~/.solarized
    printf "1\n1\nYES\n1\n" | ~/.solarized/install.sh
fi

# Hide user@hostname in zsh
# https://stackoverflow.com/questions/38086185/how-to-check-if-a-program-is-run-in-bash-on-ubuntu-on-windows-and-not-just-plain
# https://github.com/Microsoft/WSL/issues/1724#issuecomment-282420193
if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null ; then
    echo "alias cmd='cmd.exe /c'" >> $zshrc
    echo "alias pws='powershell.exe -c'" >> $zshrc
#     bashrc="~/.bashrc"
#     echo "# Switch to Zsh" >> $bashrc
#     echo "if test -t 1; then" >> $bashrc
#     echo "    exec zsh" >> $bashrc
#     echo "fi" >> $bashrc
else
    user=$(whoami)
    sed -i "s/export DEFAULT_USER=\"\w*\"//g" $zshrc # Remove existing entry to avoid duplicate
    echo "export DEFAULT_USER=\"$user\"" >> $zshrc
fi

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