#!/bin/bash

ssh_dir=~/.ssh
key=id_rsa
host=""
port=22
user=""

usage() {
    echo "Usage: $0 [-a <alias>] [-p <host_ssh_port>] user@host" 1>&2;
    exit 1;
}
# First : is for silent logging.
while getopts ":p:a:" o; do
    case "${o}" in
        p)
            port=${OPTARG}
            ;;
        a)
            key=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift "$((OPTIND-1))"

if [[ ! -z "$1" ]]; then
    user=$(cut -d'@' -f1 <<< "$1")
    host=$(cut -d'@' -f2 <<< "$1")
fi

if [[ -z "$host" ]] || [[ -z "$user" ]]; then
    usage
    exit 1
fi

echo "- Installing SSH..."
sudo apt update
sudo apt install openssh-server -y

# https://blog.gtwang.org/linux/linux-ssh-public-key-authentication/
# https://medium.com/@awonwon/how-to-setup-ssh-config-%E4%BD%BF%E7%94%A8-ssh-%E8%A8%AD%E5%AE%9A%E6%AA%94-74ad46f99818
config="\n\nHost $key\nHostName $host\nPort $port\nIdentitiesOnly yes\nIdentityFile $ssh_dir/$key\nUser $user\n\n"

echo "- Generating key pair..."
if [[ ! -d "$ssh_dir" ]]; then
    mkdir -p "$ssh_dir"
fi
chmod 700 "$ssh_dir"
ssh-keygen -f $ssh_dir/$key -t rsa -N ""

echo "- Copying to Server..."
ssh-copy-id -i $ssh_dir/$key -p $port $user@$host

echo "- Generating SSH config..."
printf "$config" >> $ssh_dir/config
chmod 600 $ssh_dir/config

echo "- Done!"
