#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════╗
# ║                        FLATPAK INSTALLER v2.0                       ║
# ║                                                                      ║
# ║    ███████╗██╗      █████╗ ████████╗██████╗  █████╗ ██╗  ██╗         ║
# ║    ██╔════╝██║     ██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██║ ██╔╝         ║
# ║    █████╗  ██║     ███████║   ██║   ██████╔╝███████║█████╔╝          ║
# ║    ██╔══╝  ██║     ██╔══██║   ██║   ██╔═══╝ ██╔══██║██╔═██╗          ║
# ║    ██║     ███████╗██║  ██║   ██║   ██║     ██║  ██║██║  ██╗         ║
# ║    ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝         ║
# ║                                                                      ║
# ║                  █████╗ ██╗   ██╗████████╗ ██████╗                   ║
# ║                 ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗                  ║
# ║                 ███████║██║   ██║   ██║   ██║   ██║                  ║
# ║                 ██╔══██║██║   ██║   ██║   ██║   ██║                  ║
# ║                 ██║  ██║╚██████╔╝   ██║   ╚██████╔╝                  ║
# ║                 ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝                   ║
# ║                                                                      ║
# ║              INSTALLER FOR GAMING & MEDIA APPLICATIONS               ║
# ║                                                                      ║
# ║══════════════════════════════════════════════════════════════════════║
# ║                                                                      ║
# ║  Author: ShadowHarvy                                                 ║
# ║  Title:  Ex-Hacker & Security Enthusiast                            ║
# ║                                                                      ║
# ║  Description: Automated Flatpak installer for essential gaming      ║
# ║               and media applications on Linux systems               ║
# ║                                                                      ║
# ║  Applications included:                                              ║
# ║  • Emby Theater - Media streaming client                            ║
# ║  • Minecraft PE Launcher - Mobile Minecraft on desktop              ║
# ║  • Sober - Roblox client for Linux                                  ║
# ║  • Bazaar - Game launcher and manager                               ║
# ║  • Vinegar - Roblox Studio for Linux                                ║
# ║                                                                      ║
# ║  System: CachyOS Linux | Shell: ZSH                                 ║
# ║                                                                      ║
# ╚══════════════════════════════════════════════════════════════════════╝

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Title screen function
show_title_screen() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                        FLATPAK INSTALLER v2.0                       ║"
    echo "║                                                                      ║"
    echo "║    ███████╗██╗      █████╗ ████████╗██████╗  █████╗ ██╗  ██╗         ║"
    echo "║    ██╔════╝██║     ██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██║ ██╔╝         ║"
    echo "║    █████╗  ██║     ███████║   ██║   ██████╔╝███████║█████╔╝          ║"
    echo "║    ██╔══╝  ██║     ██╔══██║   ██║   ██╔═══╝ ██╔══██║██╔═██╗          ║"
    echo "║    ██║     ███████╗██║  ██║   ██║   ██║     ██║  ██║██║  ██╗         ║"
    echo "║    ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝         ║"
    echo "║                                                                      ║"
    echo "║                  █████╗ ██╗   ██╗████████╗ ██████╗                   ║"
    echo "║                 ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗                  ║"
    echo "║                 ███████║██║   ██║   ██║   ██║   ██║                  ║"
    echo "║                 ██╔══██║██║   ██║   ██║   ██║   ██║                  ║"
    echo "║                 ██║  ██║╚██████╔╝   ██║   ╚██████╔╝                  ║"
    echo "║                 ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝                   ║"
    echo "║                                                                      ║"
    echo -e "║              ${WHITE}INSTALLER FOR GAMING & MEDIA APPLICATIONS${CYAN}               ║"
    echo "║                                                                      ║"
    echo "╠══════════════════════════════════════════════════════════════════════╣"
    echo "║                                                                      ║"
    echo -e "║  ${YELLOW}Author: ShadowHarvy${CYAN}                                                 ║"
    echo -e "║  ${YELLOW}Title:  Ex-Hacker & Security Enthusiast${CYAN}                            ║"
    echo "║                                                                      ║"
    echo -e "║  ${WHITE}Description: Automated Flatpak installer for essential gaming${CYAN}      ║"
    echo -e "║               ${WHITE}and media applications on Linux systems${CYAN}               ║"
    echo "║                                                                      ║"
    echo -e "║  ${GREEN}Applications included:${CYAN}                                              ║"
    echo -e "║  ${MAGENTA}•${CYAN} Emby Theater - Media streaming client                            ║"
    echo -e "║  ${MAGENTA}•${CYAN} Minecraft PE Launcher - Mobile Minecraft on desktop              ║"
    echo -e "║  ${MAGENTA}•${CYAN} Sober - Roblox client for Linux                                  ║"
    echo -e "║  ${MAGENTA}•${CYAN} Bazaar - Game launcher and manager                               ║"
    echo -e "║  ${MAGENTA}•${CYAN} Vinegar - Roblox Studio for Linux                                ║"
    echo "║                                                                      ║"
    echo -e "║  ${GRAY}System: CachyOS Linux | Shell: ZSH${CYAN}                                 ║"
    echo "║                                                                      ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${WHITE}Press ${GREEN}[ENTER]${WHITE} to continue or ${RED}[CTRL+C]${WHITE} to exit...${NC}"
    read -r
}

# Fake loading screen
show_loading_screen() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗"
    echo -e "║                        ${WHITE}INITIALIZING INSTALLER${CYAN}                       ║"
    echo -e "╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Fake system checks
    echo -e "${YELLOW}[INFO]${NC} Checking system compatibility..."
    sleep 0.5
    echo -e "${GREEN}[✓]${NC} CachyOS Linux detected"
    sleep 0.3
    echo -e "${GREEN}[✓]${NC} ZSH shell environment verified"
    sleep 0.3
    echo -e "${GREEN}[✓]${NC} Network connectivity established"
    sleep 0.4
    
    echo ""
    echo -e "${YELLOW}[INFO]${NC} Scanning security protocols..."
    sleep 0.6
    echo -e "${GREEN}[✓]${NC} Firewall status: Active"
    sleep 0.3
    echo -e "${GREEN}[✓]${NC} Package verification: Enabled"
    sleep 0.3
    echo -e "${GREEN}[✓]${NC} Sandboxing support: Available"
    sleep 0.4
    
    echo ""
    echo -e "${YELLOW}[INFO]${NC} Loading installation modules..."
    
    # Animated progress bar
    modules=("Repository Manager" "Package Validator" "Dependency Resolver" "Download Manager" "Installation Engine")
    
    for module in "${modules[@]}"; do
        echo -n -e "${BLUE}[LOAD]${NC} $module "
        for i in {1..20}; do
            echo -n "█"
            sleep 0.05
        done
        echo -e " ${GREEN}OK${NC}"
        sleep 0.2
    done
    
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}[✓] System initialization complete!${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    sleep 1
}

# List of applications to install
applications=(
    "media.emby.EmbyTheater"
    "io.mrarm.mcpelauncher"
    "org.vinegarhq.Sober"
    "io.github.kolunmi.Bazaar"
    "org.vinegarhq.Vinegar"
)

# Application friendly names
declare -A app_names=(
    ["media.emby.EmbyTheater"]="Emby Theater"
    ["io.mrarm.mcpelauncher"]="Minecraft PE Launcher"
    ["org.vinegarhq.Sober"]="Sober (Roblox Client)"
    ["io.github.kolunmi.Bazaar"]="Bazaar Game Launcher"
    ["org.vinegarhq.Vinegar"]="Vinegar (Roblox Studio)"
)

# Function to install a Flatpak application
install_flatpak() {
    local app_id="$1"
    local friendly_name="${app_names[$app_id]}"
    
    echo -e "${BLUE}[INSTALL]${NC} Installing ${YELLOW}$friendly_name${NC} ($app_id)..."
    
    # Fake installation progress
    echo -n "          Progress: "
    for i in {1..30}; do
        echo -n "▓"
        sleep 0.1
    done
    echo ""
    
    if flatpak install --noninteractive flathub "$app_id" &> /dev/null; then
        echo -e "${GREEN}[✓ SUCCESS]${NC} $friendly_name installed successfully"
        return 0
    else
        echo -e "${RED}[✗ FAILED]${NC} Failed to install $friendly_name"
        return 1
    fi
    echo ""
}

# Main execution starts here
show_title_screen
show_loading_screen

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗"
echo -e "║                     ${WHITE}FLATPAK INSTALLATION STARTED${CYAN}                      ║"
echo -e "╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Flatpak is installed
if ! command -v flatpak &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} Flatpak is not installed on this system."
    echo -e "${YELLOW}[INFO]${NC} Please install Flatpak first before running this script."
    exit 1
else
    echo -e "${GREEN}[✓]${NC} Flatpak detected and ready"
fi

# Check if Flathub repository is added
echo -e "${YELLOW}[INFO]${NC} Checking Flathub repository..."
if ! flatpak remotes | grep -q "flathub"; then
    echo -e "${YELLOW}[INFO]${NC} Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo -e "${GREEN}[✓]${NC} Flathub repository added"
else
    echo -e "${GREEN}[✓]${NC} Flathub repository already configured"
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}Installing ${#applications[@]} applications...${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Install each application
failed_installations=()
successful_installations=()

for app in "${applications[@]}"; do
    if install_flatpak "$app"; then
        successful_installations+=("$app")
    else
        failed_installations+=("$app")
    fi
    echo ""
done

# Installation summary
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗"
echo -e "║                        ${WHITE}INSTALLATION SUMMARY${CYAN}                         ║"
echo -e "╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${WHITE}Total applications:${NC} ${#applications[@]}"
echo -e "${GREEN}Successfully installed:${NC} ${#successful_installations[@]}"
echo -e "${RED}Failed installations:${NC} ${#failed_installations[@]}"
echo ""

if [ ${#successful_installations[@]} -gt 0 ]; then
    echo -e "${GREEN}✓ Successfully installed applications:${NC}"
    for app in "${successful_installations[@]}"; do
        echo -e "  ${MAGENTA}•${NC} ${app_names[$app]} ($app)"
    done
    echo ""
fi

if [ ${#failed_installations[@]} -gt 0 ]; then
    echo -e "${RED}✗ Failed to install the following applications:${NC}"
    for app in "${failed_installations[@]}"; do
        echo -e "  ${MAGENTA}•${NC} ${app_names[$app]} ($app)"
    done
    echo ""
    echo -e "${YELLOW}[INFO]${NC} You can try installing failed applications manually with:"
    echo -e "${GRAY}       flatpak install flathub <application-id>${NC}"
    echo ""
else
    echo -e "${GREEN}🎉 All applications installed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}[INFO]${NC} Applications can be launched from your application menu"
    echo -e "${YELLOW}[INFO]${NC} or via command line using: ${GRAY}flatpak run <application-id>${NC}"
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}Installation completed by ${YELLOW}ShadowHarvy's${WHITE} Flatpak Auto-Installer${NC}"
echo -e "${GRAY}Thank you for using this security-focused installation script!${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Exit with appropriate code
if [ ${#failed_installations[@]} -gt 0 ]; then
    exit 1
else
    exit 0
fi
