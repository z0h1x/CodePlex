#!/bin/bash

# Paths
HOME_DIR="/data/data/com.termux/files/home"
BIN_DIR="/data/data/com.termux/files/usr/bin"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[1;35m'
NC='\033[0m'

bold() { echo -e "\033[1m$1\033[0m"; }

# Progress bar 
progress_bar() {
    local duration=$1 text=$2 command=$3 width=30
    printf "\n%s\n" "$(bold "$text")"
    for i in $(seq 0 90); do
        local filled=$((i * width / 100))
        printf "\r\033[K[%-*s] %3d%%" $width "$(printf "%0.s█" $(seq 1 $filled))" $i
        sleep $duration
    done
    eval "$command" &> /dev/null
    printf "\r\033[K[%-*s] ${GREEN}DONE${NC}\n" $width "$(printf "%0.s█" $(seq 1 $width))"
}

# Welcome
clear
echo -e "${CYAN}"
bold "Welcome to ${MAGENTA}z0h1x${CYAN} Visual Studio (Code Server) Installer"
echo -e "${YELLOW}Version: 4.104.3 Official Release${NC}\n"
bold "INSTALLING!\n"

# Installation 
if ! command -v proot-distro &>/dev/null; then
    progress_bar 0.02 "Installing proot-distro..." "pkg install -y proot-distro"
fi
if ! command -v dialog &>/dev/null; then
    progress_bar 0.02 "Installing dialog..." "pkg install -y dialog"
fi

# Install Ubuntu
if ! proot-distro list 2>/dev/null | grep -q "ubuntu.*installed"; then
    progress_bar 0.02 "Installing Ubuntu distro..." "proot-distro install ubuntu"
fi

# Code Server Installation
progress_bar 0.02 "Updating Ubuntu..." "proot-distro login ubuntu -- apt update -y && proot-distro login ubuntu -- apt upgrade -y && proot-distro login ubuntu -- apt install -y wget"
progress_bar 0.02 "Downloading Code-Server..." "proot-distro login ubuntu -- wget -q https://github.com/coder/code-server/releases/download/v4.104.3/code-server-4.104.3-linux-arm64.tar.gz"
progress_bar 0.02 "Extracting Code-Server..." "proot-distro login ubuntu -- tar -xf ./code-server-4.104.3-linux-arm64.tar.gz"
progress_bar 0.02 "Exiting Ubuntu..." "proot-distro login ubuntu -- exit"

# Create menu script in Termux (~/zohir)
MENU_FILE="$HOME_DIR/zohir"
cat > "$MENU_FILE" << 'EOL'
#!/bin/bash
# z0h1x VSCode Control Panel

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

center_text() {
    termwidth=$(tput cols)
    while IFS= read -r line; do
        printf "%*s%s%*s\n" $(((termwidth-${#line})/2)) "" "$line" $(((termwidth-${#line})/2)) ""
    done
}

banner=$(cat << "EOF"
███████╗░█████╗░██╗░░██╗░░███╗░░██╗░░██╗
╚════██║██╔══██╗██║░░██║░████║░░╚██╗██╔╝
░░███╔═╝██║░░██║███████║██╔██║░░░╚███╔╝░
██╔══╝░░██║░░██║██╔══██║╚═╝██║░░░██╔██╗░
███████╗╚█████╔╝██║░░██║███████╗██╔╝╚██╗
╚══════╝░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝
EOF
)

while true; do
    clear
    echo -e "${CYAN}"; echo "$banner" | center_text; echo -e "${NC}"
    choice=$(dialog --clear --stdout \
        --title "z0h1x Control Panel" \
        --menu "Choose an option:" 15 60 6 \
        1 "Start Code-Server ( Vs Code )" \
        2 "Show Debug Logs ( Verbose )" \
        3 "Stop Code-Server" \
        4 "Exit")

    case $choice in
        1)
            clear
            echo -e "${YELLOW}Starting Visual Studio Code...${NC}"
            proot-distro login ubuntu -- bash -c '
cd code-server-4.103.2-linux-arm64/bin
export PASSWORD="zohir530"
nohup ./code-server > /dev/null 2>&1 &
'
            echo -e "${GREEN}Code-Server running Please Wait 10 second then join http://localhost:8080/ !${NC}"
            read -p "Press Enter to return..."
            ;;
        2)
            clear
            echo -e "${BLUE}--- Debug Mode (Ctrl+C to stop) ---${NC}"
            proot-distro login ubuntu -- bash -c '
cd code-server-4.103.2-linux-arm64/bin
export PASSWORD="zohir530"
./code-server
'
            ;;
        3)
            clear
            echo -e "${RED}Stopping Code-Server...${NC}"
            proot-distro login ubuntu -- bash -c '
pkill -f "code-server" && echo "Stopped." || echo "No process found."
'
            read -p "Press Enter to return..."
            ;;
        4)
            clear
            echo -e "${GREEN}Exiting Control Panel.${NC}"
            exit 0
            ;;
    esac
done
EOL

chmod +x "$MENU_FILE"

LAUNCHER="$BIN_DIR/vscode"
cat > "$LAUNCHER" << EOL
#!/bin/bash
bash "$MENU_FILE"
EOL
chmod +x "$LAUNCHER"
bold "\n✅ Installation complete!"
echo -e "${GREEN}Type 'vscode' to launch your Control Panel menu.${NC}\n"
