# https://support.yubico.com/hc/en-us/articles/360016614840-Code-signing-with-the-YubiKey-on-Windows
# To sign install.ps1
$scriptName = "install.ps1"
$SigningCertSHA1 = "623bcdb03abcba6cabea14fe8694c7953400ba42"
$TimestampServer = "http://timestamp.sectigo.com"
Signtool sign /sha1 $SigningCertSHA1 /fd SHA256 /t $TimestampServer $scriptName