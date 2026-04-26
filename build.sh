#!/bin/bash

echo "=============================="
echo " AUTO DEPLOY STARTING"
echo "=============================="

# ================= OS DETECT =================
if command -v pkg >/dev/null 2>&1; then
    echo "[+] Termux detected"

    pkg update -y && pkg upgrade -y

    # REQUIRED FOR cryptography (IMPORTANT FIX)
    pkg install -y tur-repo
    pkg install -y gcc-11
    pkg install -y git python rust binutils-is-llvm

    # set compiler flags (CRYPTO FIX)
    export CXXFLAGS="-Wno-register"
    export CFLAGS="-Wno-register"

elif command -v apt >/dev/null 2>&1; then
    echo "[+] Linux detected"
    sudo apt update -y
    sudo apt install -y python3 python3-pip git build-essential libssl-dev libffi-dev rustc

elif command -v brew >/dev/null 2>&1; then
    echo "[+] macOS detected"
    brew install python git rust
fi

# ================= CONFIG =================
REPO="https://github.com/markstek/main.git"
FOLDER="bot"
MAIN="main.py"

# ================= CLONE OR UPDATE =================
if [ -d "$FOLDER" ]; then
    echo "[+] Updating repo..."
    cd "$FOLDER" || exit
    git pull
else
    echo "[+] Cloning repo..."
    git clone "$REPO" "$FOLDER"
    cd "$FOLDER" || exit
fi

# ================= PIP FIX =================
echo "[+] Upgrading pip..."
python3 -m pip install --upgrade pip setuptools wheel

# ================= INSTALL REQUIREMENTS =================
if [ -f "requirements.txt" ]; then
    echo "[+] Installing Python modules..."
    python3 -m pip install -r requirements.txt
fi

# ================= CRYPTO SPECIAL FIX =================
echo "[+] Fixing cryptography install (Termux safe mode)..."
python3 -m pip install cryptography

# ================= RUN =================
echo "[+] Running bot..."
python3 "$MAIN"
