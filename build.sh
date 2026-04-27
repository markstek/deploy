#!/bin/bash

# ================= COLORS =================
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
NC="\033[0m"

clear

echo -e "${CYAN}"
echo "=============================="
echo "   NEXUS CONTROL PANEL"
echo "=============================="
echo -e "${NC}"

# ================= PYTHON DETECT =================
if command -v python3 >/dev/null 2>&1; then
    PYTHON=python3
elif command -v python >/dev/null 2>&1; then
    PYTHON=python
else
    echo -e "${RED}[!] Python not found${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Python detected: $PYTHON${NC}"

# ================= CONFIG =================
REPO="https://github.com/markstek/main.git"
FOLDER="bot"
MAIN="main.py"

# ================= MENU =================
echo ""
echo -e "${YELLOW}Select Operation:${NC}"
echo "1) FULL DEPLOY (install + update + run)"
echo "2) RUN BOT ONLY"
echo "3) CLEAN BOT FOLDER"
echo "4) EXIT"
echo ""

read -p ">> Enter choice: " choice

# ================= FULL DEPLOY =================
full_setup() {
    echo -e "${CYAN}[+] SYSTEM INITIALIZATION STARTED${NC}"

    # OS DETECT
    if command -v pkg >/dev/null 2>&1; then
        echo -e "${GREEN}[+] Termux environment detected${NC}"
        pkg update -y && pkg upgrade -y
        pkg install -y python git rust clang make openssl libffi

    elif command -v apt >/dev/null 2>&1; then
        echo -e "${GREEN}[+] Linux environment detected${NC}"
        sudo apt update -y
        sudo apt install -y python3 python3-pip git build-essential

    elif command -v brew >/dev/null 2>&1; then
        echo -e "${GREEN}[+] macOS environment detected${NC}"
        brew install python git rust
    fi

    # CLONE OR UPDATE
    if [ -d "$FOLDER" ]; then
        echo -e "${GREEN}[+] Updating repository...${NC}"
        cd "$FOLDER" || exit
        git pull
    else
        echo -e "${GREEN}[+] Cloning repository...${NC}"
        git clone "$REPO" "$FOLDER"
        cd "$FOLDER" || exit
    fi

    # PIP UPDATE
    echo -e "${CYAN}[+] Upgrading pip system...${NC}"
    $PYTHON -m pip install --upgrade pip setuptools wheel

    # REQUIREMENTS
    if [ -f "requirements.txt" ]; then
        echo -e "${CYAN}[+] Installing dependencies...${NC}"
        $PYTHON -m pip install -r requirements.txt
    fi

    # RUN
    echo -e "${GREEN}[+] Launching bot system...${NC}"
    $PYTHON "$MAIN"
}

# ================= RUN ONLY =================
run_bot() {
    if [ -d "$FOLDER" ]; then
        cd "$FOLDER" || exit
        echo -e "${GREEN}[+] Starting bot...${NC}"
        $PYTHON "$MAIN"
    else
        echo -e "${RED}[!] Bot not found. Run FULL DEPLOY first.${NC}"
    fi
}

# ================= CLEAN =================
clean_bot() {
    if [ -d "$FOLDER" ]; then
        cd "$FOLDER" || exit
        echo -e "${YELLOW}[+] Cleaning bot directory...${NC}"

        find . -type f ! -name "$MAIN" -delete
        find . -type d ! -path "." -exec rm -rf {} + 2>/dev/null

        echo -e "${GREEN}[+] Clean completed${NC}"
    else
        echo -e "${RED}[!] Folder not found${NC}"
    fi
}

# ================= ROUTER =================
case $choice in
    1) full_setup ;;
    2) run_bot ;;
    3) clean_bot ;;
    4) echo -e "${CYAN}Exiting Nexus...${NC}" ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
