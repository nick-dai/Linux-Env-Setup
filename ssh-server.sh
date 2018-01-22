#!/bin/bash
# Arguments:
# 1. Port number

# Arguments: pattern, replacement, file
modifyOrInsert() {
	grep -q "$1" "$3"
	if [[ $? -eq 0 ]]; then
		sudo sed -i "s/$1/$2/" "$3"
	else
		printf "\n$2\n" | sudo tee --append "$3" > /dev/null
	fi
}

if [ "$#" > 0 ]; then
	port=$1
else
	port=22
fi
echo "- Port: $port"
max_tries=3
sys_config=/etc/ssh/sshd_config
usr_ssh_dir=~/.ssh
auth_keys=$usr_ssh_dir/authorized_keys

echo "- Installing OpenSSH Server..."
sudo apt install openssh-server

# https://blog.gtwang.org/linux/linux-ssh-public-key-authentication/
echo "- Generating key pair..."
ssh_key=id_rsa
mkdir -p "$usr_ssh_dir"
chmod 700 "$usr_ssh_dir"
ssh-keygen -f "$usr_ssh_dir/$ssh_key" -t rsa -N ""
if [ ! -e $auth_keys ]; then
	touch $auth_keys
fi
chmod 644 "$auth_keys"
modifyOrInsert "*$USER@$(hostname)" "$(cat $usr_ssh_dir/$ssh_key)" "$auth_keys"

echo "- Backing up original config file..."
sudo cp $sys_config $sys_config.bak

# https://linux-audit.com/audit-and-harden-your-ssh-configuration/
echo "- Setting port..."
modifyOrInsert "^[^#]*Port .*" "Port $port" $sys_config
modifyOrInsert "^[^#]*PermitRootLogin .*" "PermitRootLogin yes" $sys_config
echo "- Restarting service..."
sudo service ssh restart

ip=$(hostname -I | sed "s/[[:space:]]//")
echo "- Remember to copy SSH key: scp -P $port $USER@$ip:$usr_ssh_dir/$ssh_key.pub"
read -n1 -r -p "- Press any key to continue..." key

echo "- Configuring security options..."
modifyOrInsert "^[^#]*PermitEmptyPasswords .*" "PermitEmptyPasswords no" $sys_config
modifyOrInsert "^[^#]*PermitRootLogin .*" "PermitRootLogin no" $sys_config

modifyOrInsert "^[^#]*PasswordAuthentication .*" "PasswordAuthentication no" $sys_config
modifyOrInsert "^[^#]*PubkeyAuthentication .*" "PubkeyAuthentication yes" $sys_config

modifyOrInsert "^[^#]*X11Forwarding .*" "X11Forwarding no" $sys_config
modifyOrInsert "^[^#]*IgnoreRhosts .*" "IgnoreRhosts yes" $sys_config
modifyOrInsert "^[^#]*UseDNS .*" "UseDNS yes" $sys_config
modifyOrInsert "^[^#]*MaxAuthTries .*" "MaxAuthTries $max_tries" $sys_config

echo "- Restarting service..."
sudo service ssh restart
sudo systemctl enable ssh

echo "- Done!"
