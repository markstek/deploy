#!/bin/bash

echo "=============================="
echo " AUTO DEPLOY STARTING"
echo "=============================="

# Detect OS
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

# CONFIG
REPO="https://github.com/markstek/main"
FOLDER="bot"
MAIN="main.py"

# CLONE OR UPDATE
if [ -d "$FOLDER" ]; then
    echo "[+] Updating repo..."
    cd $FOLDER && git pull
else
    echo "[+] Cloning repo..."
    git clone $REPO $FOLDER
    cd $FOLDER
fi

# INSTALL REQUIREMENTS
if [ -f "requirements.txt" ]; then
    echo "[+] Installing Python modules..."
    pip3 install -r requirements.txt
fi

# RUN SCRIPT
echo "[+] Running bot..."
python3 $MAIN
