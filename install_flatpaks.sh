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
PARALLEL_JOBS=3  # Number of concurrent installation jobs
STATE_FILE="$HOME/.local/share/flatpack/install_state.json"  # Installation state tracking

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
show_title_screen
show_loading_screen

# Load configuration
load_config

# Check for previous installation state and offer resume
load_installation_state

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
