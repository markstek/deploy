#!/bin/bash

echo "=============================="
echo " AUTO DEPLOY STARTING"
echo "=============================="

# ================= OS DETECT =================
if command -v pkg >/dev/null 2>&1; then
    echo "[+] Termux detected"
    pkg update -y
    pkg install -y python git
elif command -v apt >/dev/null 2>&1; then
    echo "[+] Linux detected"
    sudo apt update -y
    sudo apt install -y python3 python3-pip git
elif command -v brew >/dev/null 2>&1; then
    echo "[+] macOS detected"
    brew install python git
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

# ================= RUN =================
echo "[+] Running bot..."
python3 "$MAIN"
