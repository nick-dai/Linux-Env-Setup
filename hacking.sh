#!/bin/bash

sudo apt-get update

# https://github.com/longld/peda
sudo apt-get install gdb -y
git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >> ~/.gdbinit
echo "DONE! debug your program with gdb and enjoy"

# https://github.com/Gallopsled/pwntools
# For Python 2
sudo apt-get install python2.7 python-pip python-dev git libssl-dev libffi-dev build-essential -y
sudo pip install --upgrade pip
sudo pip install --upgrade pwntools
# For Python 3
sudo apt install python3 python3-dev python3-pip git -y
sudo pip3 install --upgrade pip
sudo pip3 install --upgrade git+https://github.com/arthaud/python3-pwntools.git

sudo apt-get install binwalk -y

sudo pip install ipython

# Avoid "No such file or directory" message when you execute a 32-bit binary in a 64-bit Linux.
# https://askubuntu.com/questions/133389/no-such-file-or-directory-but-the-file-exists
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 -y

# https://askubuntu.com/questions/453681/gcc-wont-link-with-m32/453687#453687
# Compile 32-bit program with GCC
sudo apt-get install gcc-multilib g++-multilib -y
