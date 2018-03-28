#!/bin/bash

sudo apt-get update

# https://github.com/longld/peda
sudo apt-get install gdb -y
git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >> ~/.gdbinit
echo "DONE! debug your program with gdb and enjoy"

# https://github.com/Gallopsled/pwntools
sudo apt-get install python2.7 python-pip python-dev git libssl-dev libffi-dev build-essential -y
sudo pip install --upgrade pip
sudo pip install --upgrade pwntools

sudo apt-get install binwalk -y

sudo pip install ipython

# Avoid "No such file or directory" message when you execute a 32-bit binary in a 64-bit Linux.
# https://askubuntu.com/questions/133389/no-such-file-or-directory-but-the-file-exists
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 -y