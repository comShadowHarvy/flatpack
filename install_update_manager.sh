#!/bin/bash

# Flatpack Update Manager Installer
# This script installs the Flatpack Update Manager to make it available system-wide

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="flatpack"
PYTHON_SCRIPT="flatpack.py"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    print_status "Checking requirements..."
    
    # Check if Python 3 is available
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed."
        exit 1
    fi
    
    # Check if Flatpak is available
    if ! command -v flatpak &> /dev/null; then
        print_error "Flatpak is required but not installed."
        exit 1
    fi
    
    # Check if the Python script exists
    if [[ ! -f "$SCRIPT_DIR/$PYTHON_SCRIPT" ]]; then
        print_error "Python script $PYTHON_SCRIPT not found in $SCRIPT_DIR"
        exit 1
    fi
    
    print_success "Requirements check passed"
}

install_update_manager() {
    print_status "Installing Flatpack Update Manager..."
    
    # Check if we need sudo
    if [[ ! -w "$INSTALL_DIR" ]]; then
        if command -v sudo &> /dev/null; then
            print_warning "Administrator privileges required for installation to $INSTALL_DIR"
            SUDO="sudo"
        else
            print_error "Cannot write to $INSTALL_DIR and sudo is not available"
            print_status "Try running as root or installing to a different location"
            exit 1
        fi
    else
        SUDO=""
    fi
    
    # Copy the Python script
    $SUDO cp "$SCRIPT_DIR/$PYTHON_SCRIPT" "$INSTALL_DIR/$SCRIPT_NAME"
    
    # Make it executable
    $SUDO chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    
    print_success "Flatpack Update Manager installed to $INSTALL_DIR/$SCRIPT_NAME"
}

show_usage_info() {
    print_status "Installation complete! You can now use the update manager:"
    echo
    echo -e "  ${GREEN}flatpack --check${NC}         # Check for available updates"
    echo -e "  ${GREEN}flatpack --smart-update${NC}  # Update only apps that need updates"
    echo -e "  ${GREEN}flatpack --list${NC}          # List installed applications" 
    echo -e "  ${GREEN}flatpack --help${NC}          # Show all available options"
    echo
    print_status "For detailed documentation, see the README.md file"
}

uninstall_update_manager() {
    print_status "Uninstalling Flatpack Update Manager..."
    
    if [[ -f "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
        # Check if we need sudo
        if [[ ! -w "$INSTALL_DIR" ]]; then
            if command -v sudo &> /dev/null; then
                SUDO="sudo"
            else
                print_error "Cannot write to $INSTALL_DIR and sudo is not available"
                exit 1
            fi
        else
            SUDO=""
        fi
        
        $SUDO rm "$INSTALL_DIR/$SCRIPT_NAME"
        print_success "Flatpack Update Manager uninstalled from $INSTALL_DIR/$SCRIPT_NAME"
    else
        print_warning "Flatpack Update Manager not found in $INSTALL_DIR"
    fi
}

main() {
    echo "Flatpack Update Manager Installer"
    echo "=================================="
    echo
    
    case "${1:-install}" in
        "install")
            check_requirements
            install_update_manager
            show_usage_info
            ;;
        "uninstall")
            uninstall_update_manager
            ;;
        "help"|"--help"|"-h")
            echo "Usage: $0 [install|uninstall|help]"
            echo
            echo "Commands:"
            echo "  install    - Install the update manager (default)"
            echo "  uninstall  - Remove the update manager"
            echo "  help       - Show this help message"
            echo
            ;;
        *)
            print_error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

main "$@"