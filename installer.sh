#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[1;35m'
NC='\033[0m'

# Function to print bold text
bold() { echo -e "\033[1m$1\033[0m"; }

# Progress bar function (30 chars wide, clean)
progress_bar() {
    local duration=$1
    local text=$2
    local command=$3
    local width=30
    printf "\n%s\n" "$(bold "$text")"
    
    # Progress up to 90%
    for i in $(seq 0 90); do
        local filled=$((i * width / 100))
        printf "\r\033[K[%-*s] %3d%%" $width "$(printf "%0.s█" $(seq 1 $filled))" $i
        sleep $duration
    done
    
    # Execute the command silently
    eval "$command" &> /dev/null
    
    # Complete to 100%
    printf "\r\033[K[%-*s] ${GREEN}DONE${NC}\n" $width "$(printf "%0.s█" $(seq 1 $width))"
}

# Clear terminal
clear

# Welcome message
echo -e "${CYAN}"
bold "Welcome to ${MAGENTA}z0h1x${CYAN} Visual Studio (Code Server) Installer"
echo -e "${YELLOW}Version: 1.0.7 Official Release"
echo -e "${NC}\n"
bold "INSTALLING!\n"

# Remove existing .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    rm "$HOME/.bashrc"
fi

# Check and install components only if needed
if [ ! -d "$HOME/storage" ]; then
    progress_bar 0.02 "Setting up storage permissions..." "termux-setup-storage"
fi

if ! command -v proot-distro &> /dev/null; then
    progress_bar 0.02 "Installing proot-distro..." "pkg install -y proot-distro"
fi

# Check if Ubuntu is already installed
if ! proot-distro list 2>/dev/null | grep -q "ubuntu.*installed"; then
    progress_bar 0.02 "Installing Ubuntu distro..." "proot-distro install ubuntu"
fi

# Check if code-server is already installed
if [ ! -d "$(proot-distro login ubuntu -- bash -c 'echo $HOME')/code-server-4.103.2-linux-arm64" ]; then
    progress_bar 0.02 "Setting up Ubuntu environment..." "proot-distro login ubuntu -- bash -c 'apt update -y && apt upgrade -y && apt install -y wget'"
    progress_bar 0.02 "Downloading Code-Server..." "proot-distro login ubuntu -- wget -q https://github.com/coder/code-server/releases/download/v4.103.2/code-server-4.103.2-linux-arm64.tar.gz"
    progress_bar 0.02 "Extracting Code-Server..." "proot-distro login ubuntu -- tar -xf ./code-server-4.103.2-linux-arm64.tar.gz"
fi

# Create new .bashrc with the control panel content
cat > "$HOME/.bashrc" << 'EOL'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to center text
center_text() {
    termwidth=$(tput cols)
    while IFS= read -r line; do
        printf "%*s%s%*s\n" $(((termwidth-${#line})/2)) "" "$line" $(((termwidth-${#line})/2)) ""
    done
}

# ASCII Banner
banner=$(cat << "EOF"
███████╗░█████╗░██╗░░██╗░░███╗░░██╗░░██╗
╚════██║██╔══██╗██║░░██║░████║░░╚██╗██╔╝
░░███╔═╝██║░░██║███████║██╔██║░░░╚███╔╝░
██╔══╝░░██║░░██║██╔══██║╚═╝██║░░░██╔██╗░
███████╗╚█████╔╝██║░░██║███████╗██╔╝╚██╗
╚══════╝░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝
EOF
)

clear
echo -e "${CYAN}"
echo "$banner" | center_text
echo -e "${NC}"

# Menu loop
while true; do
    choice=$(dialog --clear --stdout \
        --title "z0h1x Control Panel" \
        --menu "Choose an option:" 15 60 6 \
        1 "Start Code-Server (Clean)" \
        2 "Show Debug Logs (Verbose)" \
        3 "Stop Code-Server" \
        4 "Exit")

    case $choice in
        1)
            clear
            echo -e "${CYAN}"
            echo "$banner" | center_text
            echo -e "${NC}"
            echo -e "${YELLOW}Starting Visual Studio Code...${NC}"

            # Run silently in background
            proot-distro login ubuntu -- bash -c '
cd code-server-4.103.2-linux-arm64/bin
export PASSWORD="zohir530"
nohup ./code-server > /dev/null 2>&1 &
'
            echo -e "${GREEN}Termux Visual Studio Code running!${NC}"
            read -p "Press Enter to return to menu..."
            ;;
        2)
            clear
            echo -e "${CYAN}"
            echo "$banner" | center_text
            echo -e "${NC}"
            echo -e "${BLUE}--- Debug Mode: Press Ctrl+C to stop logs and return ---${NC}"

            # Run with logs
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
pkill -f "code-server" && echo "Code-Server stopped." || echo "No Code-Server running."
'
            read -p "Press Enter to return to menu..."
            ;;
        4)
            clear
            echo -e "${GREEN}Exiting z0h1x Control Panel.${NC}"
            exit 0
            ;;
    esac
done
EOL

# Final message
bold "\n✅ Installation complete! You can now run your Control Panel script."
echo -e "${GREEN}Enjoy Visual Studio Code on Termux!${NC}\n"
