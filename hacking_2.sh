#!/bin/bash

sudo apt-get update
cd ~/

# https://github.com/longld/peda
sudo apt-get install gdb -y
# gdb-peda
# git clone https://github.com/longld/peda.git ~/peda
# echo "source ~/peda/peda.py" >> ~/.gdbinit
# pwngdb
# git clone https://github.com/scwuaptx/Pwngdb.git 
# cp ~/Pwngdb/.gdbinit ~/

# gef
wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

# radare2
# git clone https://github.com/radare/radare2
# ./radare2/sys/install.sh   # just run this script to update r2 from git

# https://github.com/Gallopsled/pwntools
# For Python 2
sudo apt-get install python2.7 python-pip python-dev git libssl-dev libffi-dev build-essential -y
sudo pip install --upgrade pip pwntools
# For Python 3
sudo apt-get install python3 python3-dev python3-pip git -y
sudo pip3 install --upgrade pip
sudo pip3 install --upgrade git+https://github.com/arthaud/python3-pwntools.git

# sudo apt-get install binwalk -y

# sudo pip install ipython

# Avoid "No such file or directory" message when you execute a 32-bit binary in a 64-bit Linux.
# https://askubuntu.com/questions/133389/no-such-file-or-directory-but-the-file-exists
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 -y

# https://askubuntu.com/questions/453681/gcc-wont-link-with-m32/453687#453687
# Compile 32-bit program with GCC
sudo apt-get install gcc-multilib g++-multilib -y

# OneGadget
# sudo apt-get install ruby -y
# sudo gem install one_gadget

# The Ultimate vimrc
# git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
# sh ~/.vim_runtime/install_awesome_vimrc.sh