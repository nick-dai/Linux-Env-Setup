#!/bin/bash

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
cd

echo "- Detecting package manager..."
install=""
if hasCommand brew; then
    install="brew install -y"
elif hasCommand apt-get; then
    install="apt-get install -y"
elif hasCommand yum; then
    install="yum install -y"
else
    echo "- No required package manager: brew, apt-get or yum. Exiting..."
    exit 0
fi

# Check if "sudo" is required
echo "- Detecting root..."
if [ "$EUID" -ne 0 ]; then
    if ! hasCommand brew; then
        install="sudo -S $install"
    fi
fi

echo "- Checking required packages..."
$install git curl

# pkgs=(git curl)
# for pkg in "${pkgs[@]}"
# do
#   if ! hasCommand $pkg ; then
#       $install $pkg
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
$install zsh
if [ $? != 0 ]; then
    echo "  Failed. Please try again!"
    exit 0
fi

echo "- Downloading Oh My Zsh..."
printf "n\nexit\n" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
chsh -s $(which zsh)

# zsh settings file location
zshrc=~/.zshrc

if hasCommand brew ; then # For Mac
    replace="sed -i \"\""
else
    replace="sed -i"
fi

echo "- Installing plugins for Zsh..."
# Install zsh-completions
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
$replace "s/^plugins=(/plugins=(zsh-completions /g" $zshrc
$replace "s/^plugins=(/plugins=(zsh-autosuggestions /g" $zshrc
# Get line number of plugins and append one more line.
# plugin_ln=$(awk '/^plugins=\(/ {print FNR}' $zshrc)
# sed -i "$plugin_ln a\
# \ \ zsh-completions
# " $zshrc
# autoload -U compinit && compinit

echo "- Applying themes and settings..."
# Apply 'agnoster' theme
$replace "s/ZSH_THEME=\"\w*\"/ZSH_THEME=\"agnoster\"/g" $zshrc

# For Linux using Gnome.
if hasCommand gsettings ; then
    # Download Powerline fonts
    git clone https://github.com/powerline/fonts.git --depth=1
    ./fonts/install.sh
    rm -rf fonts
    # Apply Powerline fonts to fix the '~' character
    # https://askubuntu.com/questions/731774/how-to-change-gnome-terminal-profile-preferences-using-dconf-or-gsettings]
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
    cd
fi

# Hide user@hostname in zsh
user=$(whoami)
$replace "s/export DEFAULT_USER=\"\w*\"//g" $zshrc # Remove existing entry to avoid duplicate
echo "export DEFAULT_USER=\"$user\"" >> $zshrc

# Environment specific settings
# https://stackoverflow.com/questions/38086185/how-to-check-if-a-program-is-run-in-bash-on-ubuntu-on-windows-and-not-just-plain
# https://github.com/Microsoft/WSL/issues/1724#issuecomment-282420193
if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null ; then
    # Execute zsh when you run WSL by command "bash".
    bashrc=~/.bashrc
    echo "# Switch to Zsh" >> $bashrc
    echo "if test -t 1; then" >> $bashrc
    echo "    exec zsh" >> $bashrc
    echo "fi" >> $bashrc
else
    # Oh-My-Tmux
    # https://github.com/gpakosz/.tmux
    # It's buggy on WSL.
    $install tmux
    git clone https://github.com/gpakosz/.tmux.git
    ln -s -f .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .

    tmux_conf=".tmux.conf.local"
    $replace "s/\(^tmux_conf_theme_left_separator_main=.*\)/# \1/g" $tmux_conf
    $replace "s/\(^tmux_conf_theme_left_separator_sub=.*\)/# \1/g" $tmux_conf
    $replace "s/\(^tmux_conf_theme_right_separator_main=.*\)/# \1/g" $tmux_conf
    $replace "s/\(^tmux_conf_theme_right_separator_sub=.*\)/# \1/g" $tmux_conf

    $replace "s/#\(tmux_conf_theme_left_separator_main=.*\)/\1/g" $tmux_conf
    $replace "s/#\(tmux_conf_theme_left_separator_sub=.*\)/\1/g" $tmux_conf
    $replace "s/#\(tmux_conf_theme_right_separator_main=.*\)/\1/g" $tmux_conf
    $replace "s/#\(tmux_conf_theme_right_separator_sub=.*\)/\1/g" $tmux_conf

    $replace "s/^tmux_conf_theme_highlight_focused_pane=.*/tmux_conf_theme_highlight_focused_pane=false/g" $tmux_conf

    mkdir ~/.tmux/plugins
    cd ~/.tmux/plugins
    git clone https://github.com/tmux-plugins/tmux-resurrect
    echo "run-shell ~/.tmux/plugins/tmux-resurrect/resurrect.tmux" >> ~/.tmux.conf
    git clone https://github.com/tmux-plugins/tmux-continuum
    echo "run-shell ~/.tmux/plugins/tmux-continuum/continuum.tmux" >> ~/.tmux.conf
    echo "set -g @continuum-restore 'on'" >> ~/.tmux.conf
    echo "set -g @continuum-boot 'on'" >> ~/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm
    echo "set -g @plugin 'tmux-plugins/tpm'" >> ~/.tmux.conf
    echo "set -g @plugin 'tmux-plugins/tmux-sensible'" >> ~/.tmux.conf
    echo "run -b '~/.tmux/plugins/tpm/tpm'" >> ~/.tmux.conf
    tmux source-file ~/.tmux.conf
    cd
fi
