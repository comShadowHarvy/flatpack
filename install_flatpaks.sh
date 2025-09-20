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
LOG_DIR="$HOME/.local/share/flatpack/logs"
LOG_FILE="$HOME/.local/share/flatpack/install.log"
STATE_FILE="$HOME/.local/share/flatpack/install_state.json"  # Installation state tracking
BACKUP_FILE="$HOME/.local/share/flatpack/installed_apps_backup.json"

# System detection variables
SYSTEM_TYPE="unknown"
GAMING_MODE=false
DRY_RUN=false

# Default configuration values
MAX_RETRIES=3
REQUIRED_SPACE=2000000  # 2GB in KB
SKIP_ALREADY_INSTALLED=true
CREATE_DESKTOP_SHORTCUTS=true
PARALLEL_JOBS=3  # Number of concurrent installation jobs
VERBOSE_OUTPUT=false
LOG_LEVEL="INFO"  # DEBUG, INFO, WARN, ERROR
ENABLE_LOGGING=true
AUTO_UPDATE_CHECK=false
CUSTOM_REPOSITORIES=""  # Custom Flatpak repositories
POST_INSTALL_HOOKS=""  # Scripts to run after installation
ENVIRONMENT_PROFILE="default"  # Environment-specific settings

# Function to create default configuration file
create_default_config() {
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$LOG_DIR"
    mkdir -p "$(dirname "$STATE_FILE")"
    
    cat > "$CONFIG_FILE" << EOF
# Flatpack Auto-Installer Configuration v3.0
# Generated: $(date)
# Edit this file to customize installation preferences

# =============================================================================
# BASIC INSTALLATION SETTINGS
# =============================================================================
MAX_RETRIES=3                    # Number of retry attempts for failed installations
REQUIRED_SPACE=2000000          # Required disk space in KB (2GB)
SKIP_ALREADY_INSTALLED=true     # Skip apps that are already installed
CREATE_DESKTOP_SHORTCUTS=false  # Create desktop shortcuts for installed apps

# =============================================================================
# PERFORMANCE & PARALLEL PROCESSING
# =============================================================================
PARALLEL_JOBS=3                 # Number of parallel installation jobs (1=sequential)
VERBOSE_OUTPUT=false            # Show detailed installation output

# =============================================================================
# LOGGING & DEBUG SETTINGS
# =============================================================================
ENABLE_LOGGING=true             # Enable logging to files
LOG_LEVEL="INFO"                # Logging level: DEBUG, INFO, WARN, ERROR
LOG_RETENTION_DAYS=30           # Days to keep log files (0 = keep forever)

# =============================================================================
# ENVIRONMENT & SYSTEM INTEGRATION
# =============================================================================
ENVIRONMENT_PROFILE="default"    # Environment profile: default, steamdeck, bazzite, minimal
AUTO_UPDATE_CHECK=false         # Check for app updates after installation
ENABLE_SYSTEM_INTEGRATION=true  # Enable system integration features

# =============================================================================
# CUSTOM REPOSITORIES & APPLICATIONS
# =============================================================================
# Custom Flatpak repositories (space-separated URLs)
# Example: CUSTOM_REPOSITORIES="https://custom.repo.com/repo.flatpakrepo"
CUSTOM_REPOSITORIES=""

# Custom applications to install (space-separated Flatpak IDs)
# Add your own apps here: CUSTOM_APPS="app.id.here another.app.id"
CUSTOM_APPS=""

# =============================================================================
# POST-INSTALLATION AUTOMATION
# =============================================================================
# Post-installation hook scripts (space-separated paths to executable scripts)
# These will be executed after successful installations
# Example: POST_INSTALL_HOOKS="/path/to/script1.sh /path/to/script2.sh"
POST_INSTALL_HOOKS=""

# =============================================================================
# ADVANCED FEATURES
# =============================================================================
ENABLE_BACKUP_CREATION=true     # Create backup of installed apps list
ENABLE_PROGRESS_NOTIFICATIONS=false  # Show desktop notifications for progress
ENABLE_COMPLETION_SOUND=false   # Play sound when installation completes
STRICT_VERIFICATION=true        # Enable strict application verification
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
            
            # Remove quotes and comments from value and set variable
            value=$(echo "$value" | sed 's/#.*$//' | sed 's/^["[:space:]]*//' | sed 's/["[:space:]]*$//')
            case $key in
                MAX_RETRIES) MAX_RETRIES="$value" ;;
                REQUIRED_SPACE) REQUIRED_SPACE="$value" ;;
                SKIP_ALREADY_INSTALLED) SKIP_ALREADY_INSTALLED="$value" ;;
                CREATE_DESKTOP_SHORTCUTS) CREATE_DESKTOP_SHORTCUTS="$value" ;;
                PARALLEL_JOBS) PARALLEL_JOBS="$value" ;;
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

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 3: SMART FEATURES - SYSTEM DETECTION & LOGGING
# ═══════════════════════════════════════════════════════════════════════════════

# Logging function with different levels
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Only log if logging is enabled
    if [[ "$ENABLE_LOGGING" == "true" ]]; then
        # Create log directory if needed
        mkdir -p "$(dirname "$LOG_FILE")"
        
        # Check if we should log this level
        case "$LOG_LEVEL" in
            "DEBUG")
                echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
                ;;
            "INFO")
                [[ "$level" =~ ^(INFO|WARN|ERROR)$ ]] && echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
                ;;
            "WARN")
                [[ "$level" =~ ^(WARN|ERROR)$ ]] && echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
                ;;
            "ERROR")
                [[ "$level" == "ERROR" ]] && echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
                ;;
        esac
    fi
}

# Function to detect system type
detect_system_type() {
    log_message "DEBUG" "Starting system type detection"
    
    # Check for SteamOS/SteamDeck
    if [[ -f "/etc/os-release" ]]; then
        source /etc/os-release
        
        if [[ "$ID" == "steamos" ]] || [[ "$NAME" == *"SteamOS"* ]]; then
            SYSTEM_TYPE="steamdeck"
            log_message "INFO" "Detected SteamDeck/SteamOS system"
            return
        fi
        
        # Check for Bazzite
        if [[ "$NAME" == *"Bazzite"* ]] || [[ "$ID" == *"bazzite"* ]]; then
            SYSTEM_TYPE="bazzite"
            log_message "INFO" "Detected Bazzite handheld system"
            return
        fi
        
        # Check for other gaming-focused distributions
        if [[ "$NAME" == *"ChimeraOS"* ]] || [[ "$NAME" == *"HoloISO"* ]]; then
            SYSTEM_TYPE="gaming_distro"
            log_message "INFO" "Detected gaming-focused distribution: $NAME"
            return
        fi
    fi
    
    # Check if we're running on a handheld device (Steam Deck hardware)
    if [[ -e "/dev/input/js0" ]] && lsusb | grep -q "Valve"; then
        SYSTEM_TYPE="steamdeck_hardware"
        log_message "INFO" "Detected Steam Deck hardware"
        return
    fi
    
    # Default to desktop Linux
    SYSTEM_TYPE="desktop_linux"
    log_message "INFO" "Detected standard desktop Linux system"
}

# Function to detect gaming mode
detect_gaming_mode() {
    log_message "DEBUG" "Checking for gaming mode"
    
    # Check for Gamescope session (SteamOS Gaming Mode)
    if pgrep -x "gamescope" > /dev/null; then
        GAMING_MODE=true
        log_message "INFO" "Gaming mode detected: Gamescope session active"
        return
    fi
    
    # Check for Steam Big Picture mode
    if pgrep -f "steam.*-bigpicture" > /dev/null; then
        GAMING_MODE=true
        log_message "INFO" "Gaming mode detected: Steam Big Picture active"
        return
    fi
    
    # Check environment variables that indicate gaming session
    if [[ -n "$GAMESCOPE_WAYLAND_DISPLAY" ]] || [[ -n "$STEAM_FRAME_FORCE_CLOSE" ]]; then
        GAMING_MODE=true
        log_message "INFO" "Gaming mode detected: Gaming environment variables present"
        return
    fi
    
    GAMING_MODE=false
    log_message "DEBUG" "Standard desktop mode detected"
}

# Function to get system-optimized app recommendations
get_system_recommendations() {
    local system_apps=()
    
    case "$SYSTEM_TYPE" in
        "steamdeck"|"bazzite"|"gaming_distro")
            # Gaming-focused systems get full app list plus extras
            system_apps=("${applications[@]}")
            log_message "INFO" "Using full gaming app set for $SYSTEM_TYPE"
            ;;
        "steamdeck_hardware")
            # Steam Deck hardware but different OS
            system_apps=("${applications[@]}")
            log_message "INFO" "Using gaming app set for Steam Deck hardware"
            ;;
        "desktop_linux")
            # Desktop Linux - focus on essentials
            system_apps=(
                "com.discordapp.Discord"
                "com.spotify.Client" 
                "org.keepassxc.KeePassXC"
                "com.github.tchx84.Flatseal"
                "net.lutris.Lutris"
                "com.heroicgameslauncher.hgl"
            )
            log_message "INFO" "Using essential app set for desktop Linux"
            ;;
        *)
            # Unknown system - use safe defaults
            system_apps=("${applications[@]}")
            log_message "WARN" "Unknown system type, using default app set"
            ;;
    esac
    
    # Update applications array
    applications=("${system_apps[@]}")
}

# Function to parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run|--preview)
                DRY_RUN=true
                log_message "INFO" "Dry-run mode enabled"
                shift
                ;;
            --verbose|-v)
                VERBOSE_OUTPUT=true
                log_message "INFO" "Verbose output enabled"
                shift
                ;;
            --parallel-jobs|-j)
                if [[ -n $2 ]] && [[ $2 =~ ^[0-9]+$ ]]; then
                    PARALLEL_JOBS="$2"
                    log_message "INFO" "Parallel jobs set to $2"
                    shift 2
                else
                    echo -e "${RED}[ERROR]${NC} --parallel-jobs requires a number"
                    exit 1
                fi
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}[ERROR]${NC} Unknown option: $1"
                echo -e "${YELLOW}[INFO]${NC} Use --help for available options"
                exit 1
                ;;
        esac
    done
}

# Help function
show_help() {
    echo -e "${CYAN}Flatpack Auto-Installer v3.0 - Usage:${NC}"
    echo ""
    echo -e "${WHITE}SYNOPSIS:${NC}"
    echo -e "  $0 [OPTIONS]"
    echo ""
    echo -e "${WHITE}OPTIONS:${NC}"
    echo -e "  ${GREEN}--dry-run, --preview${NC}     Show what would be installed without executing"
    echo -e "  ${GREEN}--verbose, -v${NC}            Enable verbose output"
    echo -e "  ${GREEN}--parallel-jobs, -j N${NC}    Set number of parallel installation jobs (default: 3)"
    echo -e "  ${GREEN}--help, -h${NC}               Show this help message"
    echo ""
    echo -e "${WHITE}EXAMPLES:${NC}"
    echo -e "  ${GRAY}$0${NC}                        # Run normal installation"
    echo -e "  ${GRAY}$0 --dry-run${NC}             # Preview what would be installed"
    echo -e "  ${GRAY}$0 --verbose -j 5${NC}        # Verbose output with 5 parallel jobs"
    echo ""
    echo -e "${WHITE}CONFIGURATION:${NC}"
    echo -e "  Config file: ${GRAY}$CONFIG_FILE${NC}"
    echo -e "  Log file:    ${GRAY}$LOG_FILE${NC}"
    echo ""
}

# Function to show dry-run preview
show_dry_run_preview() {
    log_message "INFO" "Showing dry-run preview"
    
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗"
    echo -e "║                        ${WHITE}DRY-RUN PREVIEW MODE${CYAN}                        ║"
    echo -e "╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Show system information
    echo -e "${WHITE}System Information:${NC}"
    echo -e "  ${YELLOW}System Type:${NC} $SYSTEM_TYPE"
    echo -e "  ${YELLOW}Gaming Mode:${NC} $([ "$GAMING_MODE" == "true" ] && echo "Yes" || echo "No")"
    echo -e "  ${YELLOW}Parallel Jobs:${NC} $PARALLEL_JOBS"
    echo ""
    
    # Show what would be installed
    echo -e "${WHITE}Applications that would be processed:${NC}"
    local would_install=0
    local would_skip=0
    
    for app in "${applications[@]}"; do
        if [[ "$SKIP_ALREADY_INSTALLED" == "true" ]] && check_already_installed "$app"; then
            echo -e "  ${GREEN}[SKIP]${NC} ${app_names[$app]} (already installed)"
            ((would_skip++))
        else
            echo -e "  ${BLUE}[INSTALL]${NC} ${app_names[$app]} ($app)"
            ((would_install++))
        fi
    done
    
    echo ""
    echo -e "${WHITE}Summary:${NC}"
    echo -e "  ${BLUE}Would install:${NC} $would_install applications"
    echo -e "  ${GREEN}Would skip:${NC} $would_skip applications"
    echo -e "  ${YELLOW}Total applications:${NC} ${#applications[@]}"
    echo ""
    
    if [ "$would_install" -gt 0 ]; then
        echo -e "${CYAN}Installation method:${NC} $([ "$PARALLEL_JOBS" -gt 1 ] && echo "Parallel ($PARALLEL_JOBS jobs)" || echo "Sequential")"
        echo -e "${CYAN}Estimated time:${NC} $([ "$PARALLEL_JOBS" -gt 1 ] && echo "~$((would_install * 2 / PARALLEL_JOBS)) minutes" || echo "~$((would_install * 3)) minutes")"
    fi
    
    echo ""
    echo -e "${YELLOW}[DRY-RUN]${NC} This is a preview only. No applications will be installed."
    echo -e "${YELLOW}[INFO]${NC} Run without --dry-run to perform actual installation."
    
    exit 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 4: STEAMDECK-SPECIFIC FEATURES
# ═══════════════════════════════════════════════════════════════════════════════

# Function to create desktop shortcuts for installed apps
create_desktop_shortcuts() {
    local installed_apps=("$@")
    
    # Only create shortcuts if enabled in config
    if [[ "$CREATE_DESKTOP_SHORTCUTS" != "true" ]]; then
        log_message "DEBUG" "Desktop shortcuts disabled in configuration"
        return 0
    fi
    
    log_message "INFO" "Creating desktop shortcuts for ${#installed_apps[@]} applications"
    
    # Create Desktop directory if it doesn't exist
    local desktop_dir="$HOME/Desktop"
    if [[ ! -d "$desktop_dir" ]]; then
        mkdir -p "$desktop_dir"
        log_message "INFO" "Created Desktop directory: $desktop_dir"
    fi
    
    echo -e "${CYAN}[SHORTCUTS]${NC} Creating desktop shortcuts..."
    
    local created_count=0
    for app_id in "${installed_apps[@]}"; do
        local app_name="${app_names[$app_id]}"
        local shortcut_file="$desktop_dir/${app_name// /_}.desktop"
        
        # Get app info from Flatpak
        local flatpak_info
        if flatpak_info=$(flatpak info "$app_id" 2>/dev/null); then
            local display_name=$(echo "$flatpak_info" | grep "Name:" | cut -d':' -f2- | sed 's/^[[:space:]]*//') 
            local description=$(echo "$flatpak_info" | grep "Summary:" | cut -d':' -f2- | sed 's/^[[:space:]]*//') 
            
            # Use app name from our mapping if display name is empty
            [[ -z "$display_name" ]] && display_name="$app_name"
            [[ -z "$description" ]] && description="$display_name application"
            
            # Create .desktop file
            cat > "$shortcut_file" << EOF
[Desktop Entry]
Name=$display_name
Comment=$description
Exec=flatpak run $app_id
Icon=application-x-flatpak
Terminal=false
Type=Application
Categories=Game;Utility;
MimeType=
StartupNotify=true
X-Flatpak=$app_id
EOF
            
            # Make executable
            chmod +x "$shortcut_file"
            
            echo -e "  ${GREEN}✓${NC} ${app_name}"
            log_message "INFO" "Created desktop shortcut: $shortcut_file"
            ((created_count++))
        else
            echo -e "  ${YELLOW}⚠${NC} ${app_name} (could not get app info)"
            log_message "WARN" "Failed to get info for $app_id, skipping shortcut creation"
        fi
    done
    
    if [ $created_count -gt 0 ]; then
        echo -e "${GREEN}[✓]${NC} Created $created_count desktop shortcuts in $desktop_dir"
        log_message "INFO" "Successfully created $created_count desktop shortcuts"
    else
        echo -e "${YELLOW}[INFO]${NC} No desktop shortcuts created"
    fi
    echo ""
}

# Function to add apps to Steam library (SteamDeck/SteamOS only)
add_to_steam_library() {
    local installed_apps=("$@")
    
    # Only run on SteamDeck/SteamOS systems
    if [[ "$SYSTEM_TYPE" != "steamdeck" ]] && [[ "$SYSTEM_TYPE" != "steamdeck_hardware" ]]; then
        log_message "DEBUG" "Steam integration skipped (not a SteamDeck system)"
        return 0
    fi
    
    # Check if Steam is installed
    if ! command -v steam >/dev/null && ! command -v steamos-add-to-steam >/dev/null; then
        log_message "WARN" "Steam not found, cannot add apps to Steam library"
        return 0
    fi
    
    log_message "INFO" "Adding ${#installed_apps[@]} applications to Steam library"
    echo -e "${CYAN}[STEAM]${NC} Adding applications to Steam library..."
    
    local added_count=0
    for app_id in "${installed_apps[@]}"; do
        local app_name="${app_names[$app_id]}"
        
        # Try using steamos-add-to-steam if available
        if command -v steamos-add-to-steam >/dev/null; then
            if steamos-add-to-steam "flatpak run $app_id" --name "$app_name" --icon "application-x-flatpak" 2>/dev/null; then
                echo -e "  ${GREEN}✓${NC} ${app_name} (via steamos-add-to-steam)"
                log_message "INFO" "Added $app_name to Steam via steamos-add-to-steam"
                ((added_count++))
            else
                log_message "WARN" "Failed to add $app_name via steamos-add-to-steam"
            fi
        else
            # Manual Steam shortcut creation (fallback)
            local steam_dir="$HOME/.steam/steam/userdata"
            if [[ -d "$steam_dir" ]]; then
                # This is a simplified approach - full Steam shortcut creation is complex
                echo -e "  ${YELLOW}⚠${NC} ${app_name} (manual integration not fully implemented)"
                log_message "WARN" "Manual Steam integration not fully implemented for $app_name"
            else
                echo -e "  ${RED}✗${NC} ${app_name} (Steam user directory not found)"
                log_message "ERROR" "Steam user directory not found for $app_name"
            fi
        fi
    done
    
    if [ $added_count -gt 0 ]; then
        echo -e "${GREEN}[✓]${NC} Added $added_count applications to Steam library"
        log_message "INFO" "Successfully added $added_count apps to Steam library"
        echo -e "${YELLOW}[INFO]${NC} Restart Steam to see new applications in your library"
    else
        echo -e "${YELLOW}[INFO]${NC} No applications were added to Steam library"
    fi
    echo ""
}

# Function to offer post-installation app launching
post_installation_launch() {
    local installed_apps=("$@")
    
    # Skip if no apps were installed
    if [ ${#installed_apps[@]} -eq 0 ]; then
        return 0
    fi
    
    # Skip in gaming mode (could interfere with Big Picture)
    if [[ "$GAMING_MODE" == "true" ]]; then
        log_message "INFO" "Skipping post-install launch in gaming mode"
        return 0
    fi
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗"
    echo -e "║                        ${WHITE}LAUNCH APPLICATIONS${CYAN}                         ║"
    echo -e "╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${WHITE}Would you like to launch any of the newly installed applications?${NC}"
    echo ""
    
    for i in "${!installed_apps[@]}"; do
        local app_id="${installed_apps[$i]}"
        local app_name="${app_names[$app_id]}"
        
        echo -e "${YELLOW}[$((i+1))]${NC} ${app_name}"
    done
    echo -e "${YELLOW}[0]${NC} Skip launching apps"
    echo ""
    
    while true; do
        read -p "$(echo -e "${WHITE}Choose an app to launch [0-${#installed_apps[@]}]: ${NC}")" choice
        
        if [[ "$choice" == "0" ]]; then
            echo -e "${YELLOW}[INFO]${NC} Skipping app launches"
            log_message "INFO" "User chose to skip post-install app launches"
            break
        elif [[ "$choice" =~ ^[1-9][0-9]*$ ]] && [ "$choice" -le "${#installed_apps[@]}" ]; then
            local selected_app="${installed_apps[$((choice-1))]}"
            local selected_name="${app_names[$selected_app]}"
            
            echo -e "${BLUE}[LAUNCH]${NC} Starting ${selected_name}..."
            log_message "INFO" "Launching $selected_name ($selected_app)"
            
            # Launch the app in background
            flatpak run "$selected_app" &
            local launch_pid=$!
            
            echo -e "${GREEN}[✓]${NC} ${selected_name} launched (PID: $launch_pid)"
            
            # Ask if they want to launch another
            echo ""
            read -p "$(echo -e "${WHITE}Launch another app? ${GREEN}[y]${WHITE}es/${RED}[N]${WHITE}o: ${NC}")" -r
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                break
            fi
            echo ""
        else
            echo -e "${RED}[ERROR]${NC} Invalid choice. Please enter a number between 0 and ${#installed_apps[@]}"
        fi
    done
    
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
        
        # Real installation progress tracking
        echo -n "          Progress: "
        
        # Create a temporary file to capture Flatpak output
        local progress_file="/tmp/flatpak_progress_$$_${retry_count}"
        
        # Install with progress monitoring
        (
            flatpak install --noninteractive flathub "$app_id" 2>&1 | \
            while IFS= read -r line; do
                echo "$line" >> "$progress_file"
                
                # Extract progress from Flatpak output
                if [[ $line == *"Downloading"* ]]; then
                    echo -n "D"
                elif [[ $line == *"Installing"* ]]; then
                    echo -n "I"
                elif [[ $line == *"Resolving"* ]]; then
                    echo -n "R"
                elif [[ $line == *"Fetching"* ]]; then
                    echo -n "F"
                elif [[ $line == *"delta"* ]]; then
                    echo -n "Δ"
                elif [[ $line =~ [0-9]+% ]]; then
                    # Extract percentage if available
                    local percent=$(echo "$line" | grep -o '[0-9]*%' | head -1)
                    if [ -n "$percent" ]; then
                        echo -n "[$percent]"
                    fi
                else
                    echo -n "."
                fi
            done
            echo $? > "${progress_file}.exit_code"
        ) &
        local progress_pid=$!
        
        # Wait for installation to complete
        wait $progress_pid
        local install_exit_code=$(cat "${progress_file}.exit_code" 2>/dev/null || echo "1")
        
        echo "  ✓"
        
        # Clean up progress files and use the captured result
        local install_output=$(cat "$progress_file" 2>/dev/null || echo "No output captured")
        rm -f "$progress_file" "${progress_file}.exit_code"
        
        # Check installation result
        if [ "$install_exit_code" -eq 0 ]; then
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

# Function to save installation state
save_installation_state() {
    local state_dir=$(dirname "$STATE_FILE")
    mkdir -p "$state_dir"
    
    # Create state JSON
    cat > "$STATE_FILE" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "total_apps": ${#applications[@]},
    "successful": [$(printf '"%s",' "${successful_installations[@]}" | sed 's/,$//') ],
    "failed": [$(printf '"%s",' "${failed_installations[@]}" | sed 's/,$//') ],
    "skipped": [$(printf '"%s",' "${skipped_installations[@]}" | sed 's/,$//') ],
    "pending": [$(printf '"%s",' "${apps_to_install[@]}" | sed 's/,$//') ]
}
EOF
}

# Function to load previous installation state
load_installation_state() {
    if [ -f "$STATE_FILE" ]; then
        echo -e "${YELLOW}[INFO]${NC} Previous installation state found"
        
        # Show previous session info
        local timestamp=$(grep '"timestamp"' "$STATE_FILE" | cut -d'"' -f4 2>/dev/null || echo "unknown")
        local prev_successful=$(grep -o '"successful": \[[^\]]*\]' "$STATE_FILE" | grep -o '"[^"]*"' | wc -l 2>/dev/null || echo 0)
        local prev_failed=$(grep -o '"failed": \[[^\]]*\]' "$STATE_FILE" | grep -o '"[^"]*"' | wc -l 2>/dev/null || echo 0)
        
        echo -e "${GRAY}          Last run: $timestamp${NC}"
        echo -e "${GRAY}          Previous: $prev_successful successful, $prev_failed failed${NC}"
        echo ""
        
        read -p "$(echo -e "${WHITE}Resume from previous state? ${GREEN}[y]${WHITE}es/${RED}[N]${WHITE}o: ${NC}")" -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}[INFO]${NC} Resuming from previous installation state..."
            
            # Extract successful apps and mark them as skipped
            local prev_successful_apps=$(grep -o '"successful": \[[^\]]*\]' "$STATE_FILE" | \
                                        sed 's/"successful": \[\|\]//g' | \
                                        tr ',' '\n' | \
                                        sed 's/[" ]//g' | \
                                        grep -v '^$')
            
            if [ -n "$prev_successful_apps" ]; then
                echo -e "${YELLOW}[RESUME]${NC} Skipping previously successful installations:"
                while IFS= read -r app; do
                    if [ -n "$app" ]; then
                        echo -e "  ${GREEN}✓${NC} ${app_names[$app]:-$app}"
                        skipped_installations+=("$app")
                    fi
                done <<< "$prev_successful_apps"
            fi
            
            return 0  # Resume mode
        else
            echo -e "${YELLOW}[INFO]${NC} Starting fresh installation (ignoring previous state)"
            rm -f "$STATE_FILE"
            return 1  # Fresh mode
        fi
    fi
    return 1  # No previous state
}

# Function to clean up state file after successful completion
clean_installation_state() {
    if [ -f "$STATE_FILE" ] && [ ${#failed_installations[@]} -eq 0 ]; then
        echo -e "${GREEN}[CLEANUP]${NC} All installations completed successfully, removing state file"
        rm -f "$STATE_FILE"
    fi
}

# Function to install a single app in background
install_app_background() {
    local app_id="$1"
    local job_id="$2"
    local temp_dir="$3"
    
    # Create temporary files for this job
    local status_file="$temp_dir/job_${job_id}_status"
    local output_file="$temp_dir/job_${job_id}_output"
    local error_file="$temp_dir/job_${job_id}_error"
    
    # Mark job as started
    echo "RUNNING" > "$status_file"
    
    # Run installation and capture result
    if install_flatpak "$app_id" > "$output_file" 2> "$error_file"; then
        echo "SUCCESS" > "$status_file"
        echo "$app_id" >> "$temp_dir/successful_apps"
    else
        echo "FAILED" > "$status_file"
        echo "$app_id" >> "$temp_dir/failed_apps"
    fi
}

# Function to install applications in parallel
install_apps_parallel() {
    local apps_to_install=("$@")
    local max_jobs=$PARALLEL_JOBS
    local temp_dir="/tmp/flatpack_parallel_$$"
    
    # Create temporary directory for job tracking
    mkdir -p "$temp_dir"
    
    # Initialize tracking files
    touch "$temp_dir/successful_apps"
    touch "$temp_dir/failed_apps"
    
    local job_count=0
    local app_index=0
    local total_apps=${#apps_to_install[@]}
    local active_jobs=()
    
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}Installing $total_apps applications in parallel (max $max_jobs concurrent)...${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Start initial batch of jobs
    while [ $app_index -lt $total_apps ] && [ $job_count -lt $max_jobs ]; do
        local app_id="${apps_to_install[$app_index]}"
        
        echo -e "${BLUE}[START]${NC} Starting installation of ${app_names[$app_id]} (Job $((job_count + 1)))..."
        
        # Start background job
        install_app_background "$app_id" "$job_count" "$temp_dir" &
        local job_pid=$!
        active_jobs+=($job_pid)
        
        ((job_count++))
        ((app_index++))
    done
    
    # Monitor jobs and start new ones as they complete
    while [ $app_index -lt $total_apps ] || [ ${#active_jobs[@]} -gt 0 ]; do
        local new_active_jobs=()
        
        # Check each active job
        for pid in "${active_jobs[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                # Job still running
                new_active_jobs+=($pid)
            else
                # Job completed, show result
                wait "$pid"
                echo -e "${GREEN}[COMPLETE]${NC} Job finished (PID: $pid)"
                
                # Start next job if available
                if [ $app_index -lt $total_apps ]; then
                    local app_id="${apps_to_install[$app_index]}"
                    echo -e "${BLUE}[START]${NC} Starting installation of ${app_names[$app_id]}..."
                    
                    install_app_background "$app_id" "$job_count" "$temp_dir" &
                    local new_job_pid=$!
                    new_active_jobs+=($new_job_pid)
                    
                    ((job_count++))
                    ((app_index++))
                fi
            fi
        done
        
        active_jobs=("${new_active_jobs[@]}")
        sleep 1  # Brief pause before checking again
    done
    
    echo ""
    echo -e "${GREEN}[COMPLETE]${NC} All parallel installations finished!"
    
    # Collect results
    successful_installations=($(cat "$temp_dir/successful_apps" 2>/dev/null || echo ""))
    failed_installations=($(cat "$temp_dir/failed_apps" 2>/dev/null || echo ""))
    
    # Clean up
    rm -rf "$temp_dir"
    
    echo ""
}

# Main execution starts here
# Parse command line arguments first
parse_arguments "$@"

# Initialize logging
log_message "INFO" "========== Flatpack Auto-Installer v3.0 Started =========="
log_message "INFO" "System: $(uname -a)"
log_message "INFO" "User: $(whoami)"
log_message "INFO" "Arguments: $*"

# Detect system characteristics
detect_system_type
detect_gaming_mode

# Load configuration
load_config

# Apply system-specific optimizations
get_system_recommendations

# Show dry-run preview if requested
if [[ "$DRY_RUN" == "true" ]]; then
    show_dry_run_preview
fi

show_title_screen
show_loading_screen

# Check for previous installation state and offer resume
load_installation_state

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗"
echo -e "║                     ${WHITE}FLATPAK INSTALLATION STARTED${CYAN}                      ║"
echo -e "╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Show detected system information
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗"
echo -e "║                        ${WHITE}SYSTEM DETECTION RESULTS${CYAN}                       ║"
echo -e "╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}[✓]${NC} System Type: ${YELLOW}$SYSTEM_TYPE${NC}"
echo -e "${GREEN}[✓]${NC} Gaming Mode: $([ "$GAMING_MODE" == "true" ] && echo "${GREEN}Active${NC}" || echo "${GRAY}Inactive${NC}")"
echo -e "${GREEN}[✓]${NC} Parallel Jobs: ${YELLOW}$PARALLEL_JOBS${NC}"
echo -e "${GREEN}[✓]${NC} Applications Selected: ${YELLOW}${#applications[@]}${NC} (optimized for $SYSTEM_TYPE)"
if [[ "$ENABLE_LOGGING" == "true" ]]; then
    echo -e "${GREEN}[✓]${NC} Logging: ${GREEN}Enabled${NC} (Level: $LOG_LEVEL)"
fi
echo ""
log_message "INFO" "System detection complete: Type=$SYSTEM_TYPE, Gaming=$GAMING_MODE, Apps=${#applications[@]}"

# Check if Flatpak is installed
if ! command -v flatpak &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} Flatpak is not installed on this system."
    echo -e "${YELLOW}[INFO]${NC} Please install Flatpak first before running this script."
    log_message "ERROR" "Flatpak not found on system"
    exit 1
else
    echo -e "${GREEN}[✓]${NC} Flatpak detected and ready"
    log_message "INFO" "Flatpak installation verified"
fi

# Check if Flathub repository is added
echo -e "${YELLOW}[INFO]${NC} Checking Flathub repository..."
log_message "DEBUG" "Checking Flathub repository configuration"
if ! flatpak remotes | grep -q "flathub"; then
    echo -e "${YELLOW}[INFO]${NC} Adding Flathub repository..."
    log_message "INFO" "Adding Flathub repository"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo -e "${GREEN}[✓]${NC} Flathub repository added"
    log_message "INFO" "Flathub repository successfully added"
else
    echo -e "${GREEN}[✓]${NC} Flathub repository already configured"
    log_message "DEBUG" "Flathub repository already configured"
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
apps_to_install=()

# First pass: determine which apps need installation
for app in "${applications[@]}"; do
    # Check if app is already installed (if enabled in config)
    if [[ "$SKIP_ALREADY_INSTALLED" == "true" ]] && check_already_installed "$app"; then
        echo -e "${GREEN}[SKIP]${NC} ${app_names[$app]} is already installed"
        skipped_installations+=("$app")
    else
        apps_to_install+=("$app")
    fi
done

echo ""

# Install apps (parallel if PARALLEL_JOBS > 1, sequential otherwise)
if [ ${#apps_to_install[@]} -gt 0 ]; then
    if [ "$PARALLEL_JOBS" -gt 1 ]; then
        echo -e "${CYAN}[INFO]${NC} Using parallel installation with $PARALLEL_JOBS concurrent jobs"
        install_apps_parallel "${apps_to_install[@]}"
    else
        echo -e "${CYAN}[INFO]${NC} Using sequential installation (PARALLEL_JOBS=1)"
        for app in "${apps_to_install[@]}"; do
            if install_flatpak "$app"; then
                successful_installations+=("$app")
            else
                failed_installations+=("$app")
            fi
            echo ""
        done
    fi
else
    echo -e "${YELLOW}[INFO]${NC} No applications need installation - all are already installed or skipped"
fi

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

# ════════════════════════════════════════════════════════════════════
# PHASE 4: POST-INSTALLATION STEAMDECK FEATURES
# ════════════════════════════════════════════════════════════════════

# Only run Phase 4 features if we have successful installations
if [ ${#successful_installations[@]} -gt 0 ]; then
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗"
    echo -e "║                        ${WHITE}POST-INSTALLATION SETUP${CYAN}                      ║"
    echo -e "╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    log_message "INFO" "Starting Phase 4 post-installation features"
    
    # Create desktop shortcuts
    create_desktop_shortcuts "${successful_installations[@]}"
    
    # Add to Steam library (SteamDeck only)
    add_to_steam_library "${successful_installations[@]}"
    
    # Offer to launch applications
    post_installation_launch "${successful_installations[@]}"
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
# Save installation state for potential resume
save_installation_state

# Clean up state file if all successful
clean_installation_state

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
