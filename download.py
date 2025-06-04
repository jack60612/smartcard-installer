from pathlib import Path
import platform
import os
from dataclasses import dataclass
import urllib.request

download_all: bool = False

base_url: str = "https://tools.myriadnetworks.com/Applications/SmartCard/"

# list of executables per platform
windows_list: list[str] = [
    base_url + "VeraCrypt_Setup_1.26.20.exe",
    base_url + "Yubico_Authenticator_Installer.exe",
    base_url + "OpenSC-0.26.1_win64.msi",
    base_url + "yubikey-manager-5.6.1-win64.msi",
    
]
linux_list: list[str] = [
    base_url + "veracrypt-1.26.20-Debian-12-amd64.deb",
    
]
mac_list: list[str] = [
    base_url + "OpenSC-0.26.1.dmg",
    base_url + "VeraCrypt_FUSE-T_1.26.20.dmg",
]


@dataclass
class FileDownloader:
    name: str
    download_list: list[str]

    def download_files(self) -> None:
        """
        This function will download the files from the list
        """
        for file in self.download_list:
            print(f"Downloading {file}")
            try:
                urllib.request.urlretrieve(file, Path(self.name + "/" + os.path.basename(file)))
                print(f"Downloaded {file}")
            except Exception as e:
                print(f"Failed to download {file}: {e}")


windows_downloader: FileDownloader = FileDownloader("Windows", windows_list)
linux_downloader: FileDownloader = FileDownloader("Linux", linux_list)
mac_downloader: FileDownloader = FileDownloader("Mac", mac_list)


def get_current_os() -> FileDownloader:
    """
    This function will check the platform and return the correct executable
    """
    if os.name == "nt":
        return windows_downloader
    elif os.name == "posix":
        if platform.system() == "Linux":
            return linux_downloader
        elif platform.system() == "Darwin":
            return mac_downloader
    raise Exception("Unsupported platform")


def main() -> None:
    if download_all:
        all_downloaders = [windows_downloader, linux_downloader, mac_downloader]
        for downloader in all_downloaders:
            print(f"Downloading for {downloader.name}")
            downloader.download_files()
    else:
        downloader: FileDownloader = get_current_os()
        print(f"Downloading for {downloader.name}")
        downloader.download_files()


if __name__ == "__main__":
    main()
