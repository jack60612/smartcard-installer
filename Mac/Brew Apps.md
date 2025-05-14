# Apps to Install

## Installing apps

```bash
brew install --cask nextcloud
brew install --cask yubico-authenticator
brew install --cask yubico-yubikey-manager
brew tap macos-fuse-t/homebrew-cask
brew install fuse-t
brew install fuse-t-sshfs
brew install --cask cryptomator
brew install --cask gpg-suite
brew install --cask gpg-suite-pinentry
brew install python3
```

## Configuring GPG

```bash
mkdir -p ~/.gnupg
cp gpg.conf ~/.gnupg/gpg.conf
cp gpg-agent.conf ~/.gnupg/gpg-agent.conf
cp scdaemon.conf ~/.gnupg/scdaemon.conf
```

<https://www.chrisdeluca.me/2020/11/28/fixing-gpg-yubikey.html>
copy files from flash drive.
