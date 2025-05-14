# macOS Smartcard Login Configuration (Yubikey / PIV)

This project configures macOS to support smartcard-based login using a Yubikey or other PIV-compatible token. It installs root and intermediate CA certificates, sets necessary system preferences, and configures login mapping using `SmartcardLogin.plist`.

---

## 🚀 What This Script Does

1. **Copies a custom smartcard login configuration plist** to `/private/etc/SmartcardLogin.plist`.
2. **Applies macOS smartcard login system policies**, such as:
   - Enabling smartcard login
   - Enforcing smartcard-only authentication
   - Allowing user pairing
   - Configuring behavior when a card is removed
   - Controlling certificate validation behavior
3. **Removes any pre-existing trust entries** for the root and intermediate certificates (optional but helpful for debugging).
4. **Installs and trusts** your custom CA certificates:
   - Root CA as `trustRoot`
   - Intermediate CA as `trustAsRoot`

---

## 📁 File Structure

```
.
├── configure-smartcard.sh     # Main setup script
├── SmartcardLogin.plist       # Certificate-to-user mapping and trust policy
├── MyriadNetworksRootCA.crt   # Your root certificate
└── MyriadNetworksIssuingCA.crt# Your intermediate certificate
```

---

## 🛠️ Prerequisites

- **macOS with administrative privileges**
- A PIV-compatible smartcard or Yubikey with valid certificates
- Your certificate chain (Root CA and Intermediate CA) in `.crt` PEM format

---

## 🧪 How to Use

1. Place all files in the same directory.
2. Open Terminal and navigate to the script directory.
3. Run the script with elevated privileges:

```bash
chmod +x configure-smartcard.sh
sudo ./configure-smartcard.sh
```

---

## 🔐 SmartcardLogin.plist Overview

This plist maps a certificate's field (e.g., `NT Principal Name`) to the local user's directory attribute `AltSecurityIdentities`, enabling Kerberos-style mapping.

Example config:

```xml
<key>AttributeMapping</key>
<dict>
  <key>dsAttributeString</key>
  <string>dsAttrTypeStandard:AltSecurityIdentities</string>
  <key>fields</key>
  <array>
    <string>NT Principal Name</string>
  </array>
  <key>formatString</key>
  <string>Kerberos:$1</string>
</dict>
```

It also specifies SHA-256 fingerprints of trusted authorities in the `TrustedAuthorities` key.

---

## 🧾 Troubleshooting

- **Certificate not trusted?**
  - Make sure the Root CA is installed in the **System** keychain and marked as `trustRoot`.
  - Check that the SHA-256 fingerprints in `SmartcardLogin.plist` match your actual certs.

- **Login not working?**
  - Use the `security verify-cert -c yourCert.crt -R ocsp` command to verify trust and OCSP behavior.
  - Review logs from `log stream --predicate 'process == "pivtoken"'` or `trustd`.

---

## ✅ Tested With

- macOS Ventura / Sonoma
- Yubikey 5 NFC
- Custom internal PKI (Myriad Networks CA)

---

## 📌 Notes

- You can adjust OCSP enforcement by changing this setting:

```bash
sudo defaults write /Library/Preferences/com.apple.security.smartcard checkCertificateTrust -int 1
```

Where:
- `0`: no trust checking
- `1`: check chain only
- `2`: require OCSP response

- `tokenRemovalAction` can be changed to `1` (lock) or `2` (logout) for stricter security.

---

## 📤 Deployment

For MDM or mass deployment, this script can be packaged into a `.pkg` installer or translated into a `.mobileconfig` profile with custom payloads.

---

## 🧑‍💻 Author

Created by Jack Nelson  
Contact: [jack@jacknelson.xyz](mailto:jack@jacknelson.xyz)

---
