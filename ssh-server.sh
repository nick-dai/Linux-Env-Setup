#!/bin/bash

# Arguments: pattern, replacement, file
modifyOrInsert() {
	grep -q "$1" "$3"
	if [[ $? -eq 0 ]]; then
		sudo sed -i "s/$1/$2/" "$3"
	else
        # Stdout of echo will be under regular permissions, and cause a Permission Denied.
		printf "\n$2\n" | sudo tee --append "$3" > /dev/null
	fi
}

port="22"
max_tries="3"
sys_config="/etc/ssh/sshd_config"
root_login="0"
password_login="0"

usage() {
    echo "Usage: $0 [-p <port>] [-r] [-w]"
    echo
    echo "OPTIONS"
    echo "    -p    Specify port number."
    echo "    -r    Enable Root Login."
    echo "    -w    Enable Password Login."
    exit 1;
}
# First : is for silent logging.
while getopts ":p:rw" o; do
    case "${o}" in
        p)
            port=${OPTARG}
            ;;
        r)
            root_login="1"
            ;;
        w)
            password_login="1"
            ;;
        *)
            usage
            ;;
    esac
done
shift "$((OPTIND-1))"

echo "- Installing OpenSSH Server..."
sudo apt update
sudo apt install openssh-server -y

echo "- Backing up original config file..."
sudo cp $sys_config $sys_config.bak

# https://linux-audit.com/audit-and-harden-your-ssh-configuration/
echo "- Setting port..."
modifyOrInsert "^[^#]*Port .*" "Port $port" $sys_config

echo "- Configuring security options..."
if [[ "$root_login" -eq "1" ]]; then
	modifyOrInsert "^[^#]*PermitRootLogin .*" "PermitRootLogin yes" $sys_config
else
	modifyOrInsert "^[^#]*PermitRootLogin .*" "PermitRootLogin no" $sys_config
fi

if [[ "$password_login" -eq "1" ]]; then
	modifyOrInsert "^[^#]*PasswordAuthentication .*" "PasswordAuthentication yes" $sys_config
else
	modifyOrInsert "^[^#]*PasswordAuthentication .*" "PasswordAuthentication no" $sys_config
fi
modifyOrInsert "^[^#]*PermitEmptyPasswords .*" "PermitEmptyPasswords no" $sys_config
modifyOrInsert "^[^#]*PubkeyAuthentication .*" "PubkeyAuthentication yes" $sys_config
modifyOrInsert "^[^#]*X11Forwarding .*" "X11Forwarding yes" $sys_config
modifyOrInsert "^[^#]*IgnoreRhosts .*" "IgnoreRhosts yes" $sys_config
modifyOrInsert "^[^#]*UseDNS .*" "UseDNS yes" $sys_config
modifyOrInsert "^[^#]*MaxAuthTries .*" "MaxAuthTries $max_tries" $sys_config

echo "- Restarting service..."
sudo service ssh restart
sudo systemctl enable ssh

echo "- Done!"
