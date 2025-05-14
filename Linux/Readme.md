# Linux Install Info

## Pre-requisites

- Install a browser (e.g., Firefox, Chrome)
- Desktop environment (e.g., KDE, GNOME)

## Installation Commands

```bash
sudo apt install -y kleopatra \
scdaemon \
git \
pcscd \
opensc \
opensc-pkcs11 \ 
libnss3-tools \
python3-pip
```

Configure Applications

```bash
pkcs11-register

mkdir -p ~/.gnupg
cp gpg.conf ~/.gnupg/gpg.conf
cp gpg-agent.conf ~/.gnupg/gpg-agent.conf
cp scdaemon.conf ~/.gnupg/scdaemon.conf
```

## Encryption Tools
- VeraCrypt
- Cryptomator

```bash
sudo add-apt-repository ppa:sebastian-stenzel/cryptomator
sudo apt update
sudo apt install cryptomator
apt install ./veracrypt-1.26.20-Debian-12-amd64.deb
```
