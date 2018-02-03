#!/bin/bash

# Arguments: pattern, replacement, file
modifyOrInsert() {
    grep -q "$1" "$3"
    if [[ $? -eq 0 ]]; then
        sudo sed -i "s/$1/$2/" "$3"
    else
        printf "\n$2\n" | sudo tee --append "$3" > /dev/null
    fi
}

user="sftpuser"
group="sftponly"
pass="QwErTy6666"
upload_dir="upload"

# Check arguments
# https://stackoverflow.com/questions/16483119/example-of-how-to-use-getopts-in-bash
usage() {
    echo "Usage: $0 [-u <username>] [-g <group>] [-p <password>] [<upload_directory>]" 1>&2;
    exit 1;
}
# First : is for silent logging.
while getopts ":u:g:p:" o; do
    case "${o}" in
        u)
            user=${OPTARG}
            ;;
        g)
            group=${OPTARG}
            ;;
        p)
            pass=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift "$((OPTIND-1))"

if [ "$#" -gt "0" ]; then
    upload_dir=$1
fi

echo "- User: $user"
echo "- Password: $pass"
echo "- Group: $group"
echo "- Upload Dir: $upload_dir"

# This if doesn't require square brackets
# because id itself is a command.
if id "$user" &> /dev/null; then
    echo "- User already exists!"
    exit 1
fi

echo "- Installing OpenSSH..."
sudo apt install openssh-server -y
if ! type sftp &> /dev/null; then
    echo "- OpenSSH isn't installed properly!"
    echo "  Please try again later."
    exit 2
fi

echo "- Setting up user account..."
sudo groupadd "$group"
sudo useradd "$user" -m -g "$group"
printf "$pass\n$pass" | sudo passwd "$user"

echo "- Setting permissions for chroot directory.."
user_dir="/home/$user"
sudo chown root:root "$user_dir"
sudo chmod 755 "$user_dir"

echo "- Creating upload directory..."
sudo mkdir "$user_dir/$upload_dir"
sudo chown $user:$group "$user_dir/$upload_dir"

# https://blog.miniasp.com/post/2011/08/11/OpenSSH-SFTP-chroot-with-ChrootDirectory.aspx
echo "- Applying secure options..."
config="/etc/ssh/sshd_config"

subsys="Subsystem sftp internal-sftp"
if ! grep "$subsys" "$config" &> /dev/null; then
    modifyOrInsert "\(^Subsystem\ssftp\s\/.*server\)" "#\1\n$subsys" "$config"
fi

match="Match Group $group"
settings="$match
    ChrootDirectory /home/%%u
    AllowTCPForwarding no
    X11Forwarding no
    ForceCommand internal-sftp"

if ! grep "$match" "$config" &> /dev/null; then
    printf "\n$settings\n" | sudo tee --append "$config" > /dev/null
fi

echo "- Restarting service..."
sudo service sshd restart

echo "- Done! You can upload your files to $user_dir/$upload_dir."
