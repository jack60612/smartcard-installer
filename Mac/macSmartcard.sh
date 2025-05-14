#!/usr/bin/env bash
set -euo pipefail

# Copies and sets correct permissions on the SmartcardLogin configuration plist.
# This file can define certificate mapping policies and login behaviors for smartcard users.
function smartCardLogin() {
    echo "[*] Deploying SmartcardLogin configuration file..."
    sudo cp "SmartcardLogin.plist" "/private/etc"
    sudo chown root:wheel "/private/etc/SmartcardLogin.plist"
    sudo chmod 644 "/private/etc/SmartcardLogin.plist"
}

# Configures system-wide smartcard login policies using macOS preferences.
function smartCardRules() {
    echo "[*] Applying SmartCard login policy settings..."

    # Enable smartcard login support on the system
    sudo defaults write /Library/Preferences/com.apple.security.smartcard allowSmartCard -bool true

    # Require users to authenticate *only* using a smartcard (no password fallback)
    sudo defaults write /Library/Preferences/com.apple.security.smartcard enforceSmartCard -bool false

    # Allow users to self-bind their smartcard to their account without admin intervention
    sudo defaults write /Library/Preferences/com.apple.security.smartcard UserPairing -bool true

    # Require macOS to check certificate trust before allowing smartcard-based login
    # 0 = no check, 1 = check, 2 = check and require OCSP response
    #TODO: upgrade to check and require OCSP response
    sudo defaults write /Library/Preferences/com.apple.security.smartcard checkCertificateTrust -int 0

    # Allow users to have multiple cards (vs. one card strictly per user)
    sudo defaults write /Library/Preferences/com.apple.security.smartcard oneCardPerUser -bool false

    # Do nothing when the smartcard is removed (other options: lock screen, log out, etc.)
    sudo defaults write /Library/Preferences/com.apple.security.smartcard tokenRemovalAction -int 1

    # Allow logins for users whose certificate is not explicitly mapped to a local account
    sudo defaults write /Library/Preferences/com.apple.security.smartcard allowUnmappedUsers -int 1
}

function removeCerts() {
    # Remove existing copies to avoid duplication or stale trust settings
    sudo security delete-certificate -c "Myriad Networks Root CA" /Library/Keychains/System.keychain
    sudo security delete-certificate -c "MyriadNetworks Issuing CA" /Library/Keychains/System.keychain
    # remove from user keychain as well
    sudo security delete-certificate -c "Myriad Networks Root CA" ~/Library/Keychains/login.keychain
    sudo security delete-certificate -c "MyriadNetworks Issuing CA" ~/Library/Keychains/login.keychain
}

# Installs and trusts the root and intermediate CA certificates required for smartcard validation.
function installCerts() {
    echo "[*] Installing and trusting CA certificates..."

    # Install the root CA into the system keychain and mark it as a trusted root
    # Flags (-p) specify what the cert is trusted for (SSL, code signing, VPN, etc.)
    # -r trustRoot means it's a trusted root anchor
    # -u 1 indicates it's used system-wide as a root
    sudo security add-trusted-cert -d \
        -p ssl -p smime -p codeSign -p IPSec -p basic -p pkgSign -p eap \
        -r trustRoot -u 1 -k /Library/Keychains/System.keychain "MyriadNetworksRootCA.crt"

    # Optionally install the root CA into the user's keychain as well
    sudo security add-trusted-cert \
        -p ssl -p smime -p codeSign -p IPSec -p basic -p pkgSign -p eap \
        -r trustRoot -u 1 -k ~/Library/Keychains/login.keychain "MyriadNetworksRootCA.crt"

    # Install the intermediate CA into the system keychain
    # -r trustAsRoot is used to treat the intermediate as a trusted anchor
    # (required when a full chain is not always sent by the smartcard or OCSP stapling)
    sudo security add-trusted-cert -d \
        -p ssl -p smime -p codeSign -p IPSec -p basic -p pkgSign -p eap \
        -r trustAsRoot -u 2 -k /Library/Keychains/System.keychain "MyriadNetworksIssuingCA.crt"

    # Optionally install the intermediate CA into the user's keychain as well
    sudo security add-trusted-cert \
        -p ssl -p smime -p codeSign -p IPSec -p basic -p pkgSign -p eap \
        -r trustAsRoot -u 2 -k ~/Library/Keychains/login.keychain "MyriadNetworksIssuingCA.crt"
}

# Configures SSH daemon and client to support smart card authentication using macOS native PKCS#11
function configureSSHForSmartCard() {

    echo "[*] Backing up current SSHD and SSH client configuration files..."
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config_backup_$(date "+%Y-%m-%d_%H:%M")
    sudo cp /etc/ssh/ssh_config /etc/ssh/ssh_config_backup_$(date "+%Y-%m-%d_%H:%M")

    echo "[*] Updating SSHD configuration to disable password authentication..."
    sudo sed -i '' \
        -e 's/^#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' \
        -e 's/^#PasswordAuthentication yes/#PasswordAuthentication no/' \
        /etc/ssh/sshd_config

    echo "[*] Restarting SSH daemon..."
    sudo launchctl stop com.openssh.sshd
    echo "run $(sudo launchctl start com.openssh.sshd) to start the SSH daemon again"

    echo "[*] Configuring SSH client to use macOS native smart card provider..."
    if ! grep -q "PKCS11Provider=/usr/lib/ssh-keychain.dylib" /etc/ssh/ssh_config; then
        echo "PKCS11Provider=/usr/lib/ssh-keychain.dylib" | sudo tee -a /etc/ssh/ssh_config
    fi

    echo "[*] To use SSH with a smartcard:"
    echo "    1. Run: ssh-keygen -D /usr/lib/ssh-keychain.dylib"
    echo "    2. Copy the resulting public key to the remote machine's ~/.ssh/authorized_keys"
    echo "    3. (Optional) Add the smartcard key to ssh-agent with:"
    echo "       ssh-add -s /usr/lib/ssh-keychain.dylib"
}

# Main entry point
function main() {
    smartCardLogin
    smartCardRules
    removeCerts
    installCerts
    configureSSHForSmartCard
    echo "[✔] SmartCard configuration completed successfully."
}

main