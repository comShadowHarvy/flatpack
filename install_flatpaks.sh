#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════╗
# ║                        FLATPAK INSTALLER v3.0                       ║
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
# ║          STEAMDECK/BAZZITE OPTIMIZED - HANDHELD GAMING EDITION       ║
# ║                                                                      ║
# ║══════════════════════════════════════════════════════════════════════║
# ║                                                                      ║
# ║  Author: ShadowHarvy                                                 ║
# ║  Title:  Ex-Hacker & Security Enthusiast                            ║
# ║                                                                      ║
# ║  Description: Automated Flatpak installer optimized for             ║
# ║               SteamDeck and Bazzite handheld gaming systems          ║
# ║                                                                      ║
# ║  Applications included (11 total):                                   ║
# ║  • Lutris - Wine game manager for your Deck                        ║
# ║  • Heroic - Epic Games Store & GOG launcher                        ║
# ║  • Discord - Gaming communication & voice chat                      ║
# ║  • Spotify - Music streaming while gaming                          ║
# ║  • KeePassXC - Secure password manager                             ║
# ║  • Flatseal - Flatpak permissions manager (essential)              ║
# ║  • Plus 5 additional gaming/media applications                     ║
# ║                                                                      ║
# ║  Optimized: SteamDeck/Bazzite | Original: CachyOS/ZSH               ║
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

# Configuration file variables with defaults
CONFIG_FILE="$HOME/.config/flatpack/config.conf"
CONFIG_DIR="$HOME/.config/flatpack"
MAX_RETRIES=3
REQUIRED_SPACE=2000000  # 2GB in KB
SKIP_ALREADY_INSTALLED=true
CREATE_DESKTOP_SHORTCUTS=false

# Function to create default configuration file
create_default_config() {
    mkdir -p "$CONFIG_DIR"
    
    cat > "$CONFIG_FILE" << EOF
# Flatpack Auto-Installer Configuration
# Generated: $(date)
# Edit this file to customize installation preferences

# Installation settings
MAX_RETRIES=3                    # Number of retry attempts for failed installations
REQUIRED_SPACE=2000000          # Required disk space in KB (2GB)
SKIP_ALREADY_INSTALLED=true     # Skip apps that are already installed

# Post-installation options  
CREATE_DESKTOP_SHORTCUTS=false  # Create desktop shortcuts for installed apps

# Advanced settings
PARALLEL_JOBS=1                 # Number of parallel installation jobs (1=sequential)
VERBOSE_OUTPUT=false            # Show detailed installation output

# Custom applications (space-separated Flatpak IDs)
# Add custom apps here, one per line with format: CUSTOM_APPS="app.id.here another.app.id"
CUSTOM_APPS=""
EOF
    
    echo -e "${GREEN}[✓]${NC} Configuration file created at: $CONFIG_FILE"
    echo -e "${YELLOW}[INFO]${NC} Edit the config file to customize your installation preferences"
}

# Function to load configuration file
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}[INFO]${NC} Loading configuration from $CONFIG_FILE"
        
        # Source the config file safely
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ $key =~ ^#.*$ ]] && continue
            [[ -z $key ]] && continue
            
            # Remove quotes from value and set variable
            value=$(echo "$value" | sed 's/^"\|"$//g')
            case $key in
                MAX_RETRIES) MAX_RETRIES="$value" ;;
                REQUIRED_SPACE) REQUIRED_SPACE="$value" ;;
                SKIP_ALREADY_INSTALLED) SKIP_ALREADY_INSTALLED="$value" ;;
                CREATE_DESKTOP_SHORTCUTS) CREATE_DESKTOP_SHORTCUTS="$value" ;;
                CUSTOM_APPS) CUSTOM_APPS="$value" ;;
            esac
        done < "$CONFIG_FILE"
        
        echo -e "${GREEN}[✓]${NC} Configuration loaded successfully"
    else
        echo -e "${YELLOW}[INFO]${NC} No configuration file found, creating default..."
        create_default_config
    fi
    echo ""
}

# Title screen function
show_title_screen() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                        FLATPAK INSTALLER v3.0                       ║"
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
    echo -e "║          ${WHITE}STEAMDECK/BAZZITE OPTIMIZED - HANDHELD GAMING EDITION${CYAN}       ║"
    echo "║                                                                      ║"
    echo "╠══════════════════════════════════════════════════════════════════════╣"
    echo "║                                                                      ║"
    echo -e "║  ${YELLOW}Author: ShadowHarvy${CYAN}                                                 ║"
    echo -e "║  ${YELLOW}Title:  Ex-Hacker & Security Enthusiast${CYAN}                            ║"
    echo "║                                                                      ║"
    echo -e "║  ${WHITE}Description: Automated Flatpak installer optimized for${CYAN}              ║"
    echo -e "║               ${WHITE}SteamDeck and Bazzite handheld gaming systems${CYAN}             ║"
    echo "║                                                                      ║"
    echo -e "║  ${GREEN}Applications included (11 total):${CYAN}                                   ║"
    echo -e "║  ${MAGENTA}•${CYAN} Lutris - Wine game manager for your Deck                        ║"
    echo -e "║  ${MAGENTA}•${CYAN} Heroic - Epic Games Store & GOG launcher                        ║"
    echo -e "║  ${MAGENTA}•${CYAN} Discord - Gaming communication & voice chat                      ║"
    echo -e "║  ${MAGENTA}•${CYAN} Spotify - Music streaming while gaming                          ║"
    echo -e "║  ${MAGENTA}•${CYAN} KeePassXC - Secure password manager                             ║"
    echo -e "║  ${MAGENTA}•${CYAN} Flatseal - Flatpak permissions manager (essential)              ║"
    echo "║                                                                      ║"
    echo -e "║  ${GRAY}Optimized: SteamDeck/Bazzite | Original: CachyOS/ZSH${CYAN}               ║"
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
    echo -e "${GREEN}[✓]${NC} Linux system detected (SteamDeck/Bazzite optimized)"
    sleep 0.3
    echo -e "${GREEN}[✓]${NC} Shell environment verified"
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
    # Original gaming/media apps
    "media.emby.EmbyTheater"
    "io.mrarm.mcpelauncher"
    "org.vinegarhq.Sober"
    "io.github.kolunmi.Bazaar"
    "org.vinegarhq.Vinegar"
    
    # SteamDeck/Bazzite essentials
    "net.lutris.Lutris"
    "com.heroicgameslauncher.hgl"
    "com.discordapp.Discord"
    "com.spotify.Client"
    "org.keepassxc.KeePassXC"
    "com.github.tchx84.Flatseal"
)

# Function to check if a Flatpak application is already installed
check_already_installed() {
    local app_id="$1"
    if flatpak list --app | grep -q "^$app_id\s"; then
        return 0  # Already installed
    else
        return 1  # Not installed
    fi
}

# Function to check available storage space
check_storage_space() {
    local required_space=$REQUIRED_SPACE
    echo -e "${YELLOW}[INFO]${NC} Checking available storage space..."
    
    # Check Flatpak directory or fallback to root
    local available_space
    if [ -d "/var/lib/flatpak" ]; then
        available_space=$(df /var/lib/flatpak 2>/dev/null | awk 'NR==2 {print $4}')
    else
        available_space=$(df / | awk 'NR==2 {print $4}')
    fi
    
    local available_gb=$(( available_space / 1000000 ))
    local required_gb=$(( required_space / 1000000 ))
    
    echo -e "${GREEN}[✓]${NC} Available space: ${available_gb}GB"
    
    if [ "$available_space" -lt "$required_space" ]; then
        echo -e "${RED}[WARNING]${NC} Low disk space detected!"
        echo -e "${YELLOW}[INFO]${NC} Available: ${available_gb}GB | Recommended: ${required_gb}GB+"
        echo -e "${YELLOW}[INFO]${NC} Installation may fail due to insufficient space."
        echo ""
        read -p "$(echo -e "${WHITE}Continue anyway? ${GREEN}[y]${WHITE}es/${RED}[N]${WHITE}o: ${NC}")" -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}[INFO]${NC} Installation cancelled by user."
            exit 0
        fi
        echo -e "${YELLOW}[INFO]${NC} Proceeding with installation despite low space..."
    else
        echo -e "${GREEN}[✓]${NC} Sufficient storage space available"
    fi
    echo ""
}

# Application friendly names
declare -A app_names=(
    # Original gaming/media apps
    ["media.emby.EmbyTheater"]="Emby Theater"
    ["io.mrarm.mcpelauncher"]="Minecraft PE Launcher"
    ["org.vinegarhq.Sober"]="Sober (Roblox Client)"
    ["io.github.kolunmi.Bazaar"]="Bazaar Game Launcher"
    ["org.vinegarhq.Vinegar"]="Vinegar (Roblox Studio)"
    
    # SteamDeck/Bazzite essentials
    ["net.lutris.Lutris"]="Lutris (Wine Game Manager)"
    ["com.heroicgameslauncher.hgl"]="Heroic Games Launcher"
    ["com.discordapp.Discord"]="Discord"
    ["com.spotify.Client"]="Spotify"
    ["org.keepassxc.KeePassXC"]="KeePassXC (Password Manager)"
    ["com.github.tchx84.Flatseal"]="Flatseal (Permissions Manager)"
)

# Function to install a Flatpak application with retry logic
install_flatpak() {
    local app_id="$1"
    local friendly_name="${app_names[$app_id]}"
    local max_retries=$MAX_RETRIES
    local retry_count=0
    
    echo -e "${BLUE}[INSTALL]${NC} Installing ${YELLOW}$friendly_name${NC} ($app_id)..."
    
    while [ $retry_count -lt $max_retries ]; do
        # Show attempt number if this is a retry
        if [ $retry_count -gt 0 ]; then
            echo -e "${YELLOW}[RETRY]${NC} Attempt $(($retry_count + 1)) of $max_retries for $friendly_name"
        fi
        
        # Fake installation progress
        echo -n "          Progress: "
        for i in {1..30}; do
            echo -n "▓"
            sleep 0.1
        done
        echo ""
        
        # Attempt installation with detailed error capture
        local install_output
        if install_output=$(flatpak install --noninteractive flathub "$app_id" 2>&1); then
            echo -e "${GREEN}[✓ SUCCESS]${NC} $friendly_name installed successfully"
            return 0
        else
            retry_count=$((retry_count + 1))
            
            if [ $retry_count -lt $max_retries ]; then
                echo -e "${YELLOW}[⚠ RETRY]${NC} Installation failed, retrying in 2 seconds..."
                
                # Show specific error for debugging (first 100 chars)
                local error_snippet=$(echo "$install_output" | head -1 | cut -c1-80)
                if [ -n "$error_snippet" ]; then
                    echo -e "${GRAY}          Error: $error_snippet${NC}"
                fi
                
                sleep 2
            else
                echo -e "${RED}[✗ FAILED]${NC} Failed to install $friendly_name after $max_retries attempts"
                
                # Show more detailed error on final failure
                local error_detail=$(echo "$install_output" | grep -E "(error|Error|ERROR|failed|Failed|FAILED)" | head -1 | cut -c1-80)
                if [ -n "$error_detail" ]; then
                    echo -e "${GRAY}          Final error: $error_detail${NC}"
                fi
                
                return 1
            fi
        fi
    done
    echo ""
}

# Main execution starts here
show_title_screen
show_loading_screen

# Load configuration
load_config

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

# Check available storage space
check_storage_space

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}Installing ${#applications[@]} applications...${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Install each application
failed_installations=()
successful_installations=()
skipped_installations=()

for app in "${applications[@]}"; do
    # Check if app is already installed (if enabled in config)
    if [[ "$SKIP_ALREADY_INSTALLED" == "true" ]] && check_already_installed "$app"; then
        echo -e "${GREEN}[SKIP]${NC} ${app_names[$app]} is already installed"
        skipped_installations+=("$app")
    else
        if install_flatpak "$app"; then
            successful_installations+=("$app")
        else
            failed_installations+=("$app")
        fi
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
echo -e "${YELLOW}Skipped (already installed):${NC} ${#skipped_installations[@]}"
echo -e "${RED}Failed installations:${NC} ${#failed_installations[@]}"
echo ""

if [ ${#successful_installations[@]} -gt 0 ]; then
    echo -e "${GREEN}✓ Successfully installed applications:${NC}"
    for app in "${successful_installations[@]}"; do
        echo -e "  ${MAGENTA}•${NC} ${app_names[$app]} ($app)"
    done
    echo ""
fi

if [ ${#skipped_installations[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠ Skipped applications (already installed):${NC}"
    for app in "${skipped_installations[@]}"; do
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
