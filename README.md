# Linux-Env-Setup
Here are some scripts that I use to customize my Linux environment.

## EC2-Lamp-Drupal
- Install **MariaDB, PHP7.0, Apache2, Drupal 7.56 on AWS EC2 Linux**.
- Fix some scripting errors in official documents.
- Fix permissions for Drupal.

## Gdb-peda
- Install **gdb-peda**.

## My-Apps
- Install apps I often use.

## Set-Static-IP
- Tested on **Ubuntu 16.04**.
- Set static IP with **Network Manager**.
- Automatically detect current IP segment and only change the last byte of it.
- Suitable for private IP.
- Syntax:
```
./set-static-ip.sh <last_byte_of_desired_IP>
```

## SSH-Server
- Tested on **Ubuntu 16.04 and Kali 2017.1**.
- Install openssh and automatically generate key.
- Customize port number.
- Strengthen security options.
- Syntax:
```
./ssh-server.sh <port>
```

## Zsh
- Tested on **Ubuntu 16.04, Kali 2017.1 and MacOS**.
- Install zsh, oh-my-zsh, zsh-completions.
- Install Arc-OSX-Icons, Ultra-Flat-Icons, OSX-Arc-Theme for Gnome.
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