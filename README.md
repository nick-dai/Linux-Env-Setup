# Linux-Env-Setup
Here are some scripts that I use to customize my Linux environment.

## EC2-Lamp-Drupal
- Install **MariaDB, PHP7.0, Apache2, Drupal 7.56 on AWS EC2 Linux**.
- Fix some scripting errors in official documents.
- Fix permissions for Drupal.

## Hacking
- Install **gdb-peda, pwntools, python3-pwntools, binwalk, ipython**.

## My-Apps
- Install **vim, htop, tmux**.

## Set-Static-IP
- Tested on **Ubuntu 16.04**.
- Set static IP with **Network Manager**.
- Automatically detect current IP segment and only change the last byte of it.
- Suitable for private IP.
- Syntax:
```
./set-static-ip.sh <last_byte_of_desired_IP>
```

## SSH-Server & SSH-Client
- Tested on **Ubuntu 16.04 and Kali 2017.1**.
- Install openssh and automatically generate key.
- Strengthen security options.
- Syntax:
```
# SSH-Server
# -r: Enable Root Login
# -w: Enable Password Login
./ssh-server.sh [-p <port>] [-r] [-w]
# SSH-Client
./ssh-client.sh [-a <alias>] [-p <port>] <user>@<host>
```

## Zsh
- Tested on **Ubuntu 16.04, Kali 2017.1 and MacOS**.
- Install zsh, oh-my-zsh, zsh-completions.
- Apply Powerline fonts and Solarized for Gnome's terminal.
- Totally automatically install if your password is provided.
- Syntax:
```
./zsh.sh <your_password>
```

## Sftp-Server
- Tested on **Ubuntu 16.04, Kali 2017.1**.
- Automatically configure SFTP server.
- Create a new user with custom settings.
- With default settings, a user "sftpuser:sftponly" will be created with a password "QwErTy6666", and its upload directory will be in ~/upload.
- Syntax:
```
./sftp-server.sh [-u <username>] [-g <group>] [-p <password>] [<upload_directory>]
```

## Theming
- Install Arc-OSX-Icons, Ultra-Flat-Icons, OSX-Arc-Theme for Gnome.

## Docker
- Automatically install docker.