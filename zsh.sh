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
# if [[ "$1" != "" ]]; then
#     printf "$1\n" | chsh -s $(which zsh)
# else
#     chsh -s $(which zsh)
# fi

# zsh settings file location
zshrc=~/.zshrc

echo "- Installing plugins for Zsh..."
# Install zsh-completions
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
sed -i "s/^plugins=(/plugins=(zsh-completions /g" $zshrc
sed -i "s/^plugins=(/plugins=(zsh-autosuggestions /g" $zshrc
# Get line number of plugins and append one more line.
# plugin_ln=$(awk '/^plugins=\(/ {print FNR}' $zshrc)
# sed -i "$plugin_ln a\
# \ \ zsh-completions
# " $zshrc
# autoload -U compinit && compinit

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
    # Some aliases for WSL
    # echo "alias cmd='cmd.exe /c'" >> $zshrc
    # echo "alias pws='powershell.exe -c'" >> $zshrc
    # For WSL Beta before Fall Creator Update
    # Also for executing zsh when you run WSL by command "bash".
    bashrc=~/.bashrc
    echo "# Switch to Zsh" >> $bashrc
    echo "if test -t 1; then" >> $bashrc
    echo "    exec zsh" >> $bashrc
    echo "fi" >> $bashrc
else
    # Oh-My-Tmux
    # https://github.com/gpakosz/.tmux
    # It's buggy on WSL.
    sudo apt update && sudo apt install tmux -y
    cd
    git clone https://github.com/gpakosz/.tmux.git
    ln -s -f .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .

    tmux_conf=".tmux.conf.local"
    sed -i "s/\(^tmux_conf_theme_left_separator_main=.*\)/# \1/g" $tmux_conf
    sed -i "s/\(^tmux_conf_theme_left_separator_sub=.*\)/# \1/g" $tmux_conf
    sed -i "s/\(^tmux_conf_theme_right_separator_main=.*\)/# \1/g" $tmux_conf
    sed -i "s/\(^tmux_conf_theme_right_separator_sub=.*\)/# \1/g" $tmux_conf

    sed -i "s/#\(tmux_conf_theme_left_separator_main=.*\)/\1/g" $tmux_conf
    sed -i "s/#\(tmux_conf_theme_left_separator_sub=.*\)/\1/g" $tmux_conf
    sed -i "s/#\(tmux_conf_theme_right_separator_main=.*\)/\1/g" $tmux_conf
    sed -i "s/#\(tmux_conf_theme_right_separator_sub=.*\)/\1/g" $tmux_conf

    sed -i "s/^tmux_conf_theme_highlight_focused_pane=.*/tmux_conf_theme_highlight_focused_pane=false/g" $tmux_conf

    git clone https://github.com/tmux-plugins/tmux-resurrect
    echo "run-shell ~/tmux-resurrect/resurrect.tmux" >> ~/.tmux.conf
    git clone https://github.com/tmux-plugins/tmux-continuum
    echo "run-shell ~/tmux-continuum/continuum.tmux" >> ~/.tmux.conf
    tmux source-file ~/.tmux.conf

fi

user=$(whoami)
sed -i "s/export DEFAULT_USER=\"\w*\"//g" $zshrc # Remove existing entry to avoid duplicate
echo "export DEFAULT_USER=\"$user\"" >> $zshrc