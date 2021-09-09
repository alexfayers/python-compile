#!/bin/bash

# script to get latest python version and compile it from source
# you can specify a specific version in 1st param, or leave blank to just get the latest Python 3 release

user_version="$1"

# Uncomment for interactive...
# read -p "Specific python version (or enter for latest) (e.g. 3.9 or 3.9.1): " user_version

# fetch the version links with regex magic
if [ ."$user_version". = ."". ]; then
    VERSION=$(curl -s https://www.python.org/downloads/source/ | grep -oP "Latest\sPython\s3\sRelease\s-\sPython\s\K(.*?)(?=</a>)" | head -n 1) # e.g: 3.9.1
    echo "[*] Finding latest version"
else
    VERSION=$(curl -s https://www.python.org/downloads/source/ | grep -oP "Python\s\K($user_version.*?)(?=\s)" | head -n 1) # e.g: 3.9.1
    echo "[*] Finding user specified version"
fi

MAIN_VERSION=$(echo $VERSION | grep -oP "\K\d*?\.\d*?(?=\.\d*?)") # e.g: 3.9

echo "[+] Will use Python version $MAIN_VERSION ($VERSION)!"

# need bash 4+ for this
read -n 1 -r -p "[?] Are you sure you want to compile and install this version of Python? [y/N] " response
echo

response=${response,,}
if ! [[ "$response" =~ ^(yes|y)$ ]]; then
    echo "[-] User cancelled, exiting..."
    exit 0
fi

# Update and install requirements
echo "[*] Apt updating..."
sudo apt -qq update

echo "[*] Installing/updating requirements..."
sudo apt install -yqq build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev

echo "[*] Downloading Python $VERSION source into a temp directory..."
TMP_DIR=$(mktemp -d)

cd "$TMP_DIR"

# download with only progress bar (looks quite nice)
wget -q --show-progress "https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tgz"

echo "[*] Untarring download..."

tar -xzf "Python-$VERSION.tgz"
cd "Python-$VERSION"

echo "[*] Configuring Python build (ensuring pip is installed too)..."
./configure --enable-optimizations --with-ensurepip=install # 1> /dev/null

cores=$(nproc)

echo "[*] Making Python $VERSION (using $cores cores)..."
make -j $cores # 1> /dev/null
echo "[*] Alt-installing Python $VERSION..."
sudo make altinstall # 1> /dev/null

sudo rm -r $TMP_DIR

# might be a better way of getting this path?
INSTALL_LOCATION="/usr/local/bin/python$MAIN_VERSION"

# update pip
echo "[*] Updating pip ($INSTALL_LOCATION -m pip install --upgrade pip)..."
$INSTALL_LOCATION -m pip install --upgrade pip 1> /dev/null

echo "[+] Python (and pip) $VERSION install complete ($INSTALL_LOCATION)!"
