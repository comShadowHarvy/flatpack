#!/usr/bin/env python3
"""
Package Manager Integration for Flatpack

This script provides unified package management by detecting the system's 
package manager and installing essential packages that complement Flatpak apps.
"""

import subprocess
import sys
import os
from typing import List, Dict, Optional, Tuple
import json
from pathlib import Path

# Colors for output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    MAGENTA = '\033[0;35m'
    CYAN = '\033[0;36m'
    WHITE = '\033[1;37m'
    GRAY = '\033[0;37m'
    NC = '\033[0m'  # No Color

# Package definitions organized by purpose
PACKAGE_CATEGORIES = {
    "gaming": {
        "name": "Gaming Support",
        "description": "Essential gaming libraries and tools",
        "packages": {
            "arch": ["steam", "lutris", "wine", "winetricks", "lib32-mesa", "lib32-vulkan-radeon", "lib32-vulkan-intel"],
            "ubuntu": ["steam-installer", "lutris", "wine", "winetricks", "mesa-utils", "vulkan-utils"],
            "fedora": ["steam", "lutris", "wine", "winetricks", "mesa-dri-drivers", "vulkan-loader"],
            "opensuse": ["steam", "lutris", "wine", "winetricks", "Mesa-dri", "libvulkan1"],
            "alpine": ["steam", "wine"],
        }
    },
    "media": {
        "name": "Media Codecs",
        "description": "Audio/video codecs and media support",
        "packages": {
            "arch": ["ffmpeg", "gstreamer", "gst-plugins-good", "gst-plugins-bad", "gst-plugins-ugly", "gst-libav"],
            "ubuntu": ["ubuntu-restricted-extras", "ffmpeg", "gstreamer1.0-plugins-good", "gstreamer1.0-plugins-bad", "gstreamer1.0-plugins-ugly"],
            "fedora": ["ffmpeg", "gstreamer1-plugins-good", "gstreamer1-plugins-bad-free", "gstreamer1-plugins-ugly"],
            "opensuse": ["ffmpeg", "gstreamer-plugins-good", "gstreamer-plugins-bad", "gstreamer-plugins-ugly"],
            "alpine": ["ffmpeg", "gstreamer"],
        }
    },
    "development": {
        "name": "Development Tools",
        "description": "Essential development packages",
        "packages": {
            "arch": ["git", "base-devel", "python", "nodejs", "npm", "code"],
            "ubuntu": ["git", "build-essential", "python3", "python3-pip", "nodejs", "npm", "curl", "wget"],
            "fedora": ["git", "gcc", "gcc-c++", "make", "python3", "python3-pip", "nodejs", "npm"],
            "opensuse": ["git", "gcc", "gcc-c++", "make", "python3", "python3-pip", "nodejs", "npm"],
            "alpine": ["git", "build-base", "python3", "py3-pip", "nodejs", "npm"],
        }
    },
    "system": {
        "name": "System Tools",
        "description": "Essential system utilities and libraries",
        "packages": {
            "arch": ["curl", "wget", "unzip", "p7zip", "htop", "neofetch", "flatpak"],
            "ubuntu": ["curl", "wget", "unzip", "p7zip-full", "htop", "neofetch", "flatpak"],
            "fedora": ["curl", "wget", "unzip", "p7zip", "htop", "neofetch", "flatpak"],
            "opensuse": ["curl", "wget", "unzip", "p7zip", "htop", "neofetch", "flatpak"],
            "alpine": ["curl", "wget", "unzip", "p7zip", "htop", "neofetch", "flatpak"],
        }
    }
}

class PackageManagerIntegration:
    def __init__(self):
        self.distro = self.detect_distribution()
        self.package_manager = self.detect_package_manager()
        self.sudo_available = self.check_sudo()
        
    def run_command(self, cmd: List[str], capture_output: bool = True) -> subprocess.CompletedProcess:
        """Run a command and return the result"""
        try:
            result = subprocess.run(
                cmd,
                capture_output=capture_output,
                text=True,
                check=False
            )
            return result
        except Exception as e:
            print(f"{Colors.RED}[ERROR]{Colors.NC} Failed to run command {' '.join(cmd)}: {e}")
            return subprocess.CompletedProcess(cmd, 1, "", str(e))
    
    def detect_distribution(self) -> str:
        """Detect the Linux distribution"""
        # Try /etc/os-release first
        if os.path.exists('/etc/os-release'):
            try:
                with open('/etc/os-release', 'r') as f:
                    content = f.read()
                    
                # Check for specific distributions
                if 'ID=arch' in content or 'ID_LIKE=arch' in content:
                    return 'arch'
                elif 'ID=ubuntu' in content or 'ID_LIKE=debian' in content:
                    return 'ubuntu'
                elif 'ID=fedora' in content or 'ID_LIKE=fedora' in content:
                    return 'fedora'
                elif 'ID=opensuse' in content or 'ID_LIKE=suse' in content:
                    return 'opensuse'
                elif 'ID=alpine' in content:
                    return 'alpine'
            except:
                pass
        
        # Fallback detection
        if os.path.exists('/etc/arch-release'):
            return 'arch'
        elif os.path.exists('/etc/ubuntu-release') or os.path.exists('/etc/debian_version'):
            return 'ubuntu'
        elif os.path.exists('/etc/fedora-release') or os.path.exists('/etc/redhat-release'):
            return 'fedora'
        elif os.path.exists('/etc/SuSE-release'):
            return 'opensuse'
        elif os.path.exists('/etc/alpine-release'):
            return 'alpine'
        
        return 'unknown'
    
    def detect_package_manager(self) -> Dict[str, str]:
        """Detect available package manager and return command info"""
        managers = {
            'pacman': {'install': 'pacman -S', 'update': 'pacman -Sy', 'search': 'pacman -Ss'},
            'apt': {'install': 'apt install', 'update': 'apt update', 'search': 'apt search'},
            'dnf': {'install': 'dnf install', 'update': 'dnf check-update', 'search': 'dnf search'},
            'zypper': {'install': 'zypper install', 'update': 'zypper refresh', 'search': 'zypper search'},
            'apk': {'install': 'apk add', 'update': 'apk update', 'search': 'apk search'},
        }
        
        # Check which package manager is available
        for manager, commands in managers.items():
            if subprocess.run(['which', manager], capture_output=True).returncode == 0:
                return {'name': manager, **commands}
        
        return {'name': 'unknown'}
    
    def check_sudo(self) -> bool:
        """Check if sudo is available"""
        return subprocess.run(['which', 'sudo'], capture_output=True).returncode == 0
    
    def is_package_installed(self, package: str) -> bool:
        """Check if a package is already installed"""
        if self.package_manager['name'] == 'pacman':
            result = self.run_command(['pacman', '-Qi', package])
            return result.returncode == 0
        elif self.package_manager['name'] == 'apt':
            result = self.run_command(['dpkg', '-l', package])
            return result.returncode == 0 and 'ii' in result.stdout
        elif self.package_manager['name'] == 'dnf':
            result = self.run_command(['rpm', '-q', package])
            return result.returncode == 0
        elif self.package_manager['name'] == 'zypper':
            result = self.run_command(['rpm', '-q', package])
            return result.returncode == 0
        elif self.package_manager['name'] == 'apk':
            result = self.run_command(['apk', 'info', '-e', package])
            return result.returncode == 0
        
        return False
    
    def install_packages(self, packages: List[str], category: str = "packages") -> bool:
        """Install a list of packages"""
        if not packages:
            return True
            
        if self.package_manager['name'] == 'unknown':
            print(f"{Colors.RED}[ERROR]{Colors.NC} No supported package manager found")
            return False
        
        # Filter out already installed packages
        to_install = []
        for package in packages:
            if not self.is_package_installed(package):
                to_install.append(package)
            else:
                print(f"{Colors.GREEN}[SKIP]{Colors.NC} {package} (already installed)")
        
        if not to_install:
            print(f"{Colors.GREEN}[INFO]{Colors.NC} All {category} packages are already installed")
            return True
        
        print(f"{Colors.BLUE}[INSTALL]{Colors.NC} Installing {len(to_install)} {category} packages...")
        for pkg in to_install:
            print(f"  • {pkg}")
        
        # Construct install command
        install_cmd = self.package_manager['install'].split()
        
        # Add sudo if available and not root
        if self.sudo_available and os.geteuid() != 0:
            install_cmd.insert(0, 'sudo')
        
        # Add packages
        install_cmd.extend(to_install)
        
        # Add non-interactive flags where appropriate
        if self.package_manager['name'] == 'apt':
            install_cmd.extend(['-y'])
        elif self.package_manager['name'] == 'dnf':
            install_cmd.extend(['-y'])
        elif self.package_manager['name'] == 'zypper':
            install_cmd.extend(['-y'])
        elif self.package_manager['name'] == 'pacman':
            install_cmd.extend(['--noconfirm'])
        
        print(f"{Colors.YELLOW}[CMD]{Colors.NC} Running: {' '.join(install_cmd)}")
        
        # Execute installation
        result = self.run_command(install_cmd, capture_output=False)
        
        if result.returncode == 0:
            print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {category} packages installed successfully")
            return True
        else:
            print(f"{Colors.RED}[FAILED]{Colors.NC} Failed to install {category} packages")
            return False
    
    def update_package_database(self) -> bool:
        """Update package database/cache"""
        if self.package_manager['name'] == 'unknown':
            return False
        
        print(f"{Colors.BLUE}[UPDATE]{Colors.NC} Updating package database...")
        
        update_cmd = self.package_manager['update'].split()
        
        # Add sudo if available and not root
        if self.sudo_available and os.geteuid() != 0:
            update_cmd.insert(0, 'sudo')
        
        result = self.run_command(update_cmd, capture_output=False)
        
        if result.returncode == 0:
            print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} Package database updated")
            return True
        else:
            print(f"{Colors.YELLOW}[WARNING]{Colors.NC} Package database update failed (continuing anyway)")
            return False
    
    def install_category(self, category: str) -> bool:
        """Install packages for a specific category"""
        if category not in PACKAGE_CATEGORIES:
            print(f"{Colors.RED}[ERROR]{Colors.NC} Unknown category: {category}")
            return False
        
        cat_info = PACKAGE_CATEGORIES[category]
        packages = cat_info["packages"].get(self.distro, [])
        
        if not packages:
            print(f"{Colors.YELLOW}[SKIP]{Colors.NC} No {cat_info['name']} packages defined for {self.distro}")
            return True
        
        print(f"{Colors.CYAN}[CATEGORY]{Colors.NC} Installing {cat_info['name']}: {cat_info['description']}")
        return self.install_packages(packages, cat_info['name'])
    
    def show_system_info(self):
        """Display system information"""
        print(f"{Colors.CYAN}╔══════════════════════════════════════════════════════════════════════╗")
        print(f"║                    {Colors.WHITE}PACKAGE MANAGER INTEGRATION{Colors.CYAN}                     ║")
        print(f"╚══════════════════════════════════════════════════════════════════════╝{Colors.NC}")
        print()
        print(f"{Colors.WHITE}System Information:{Colors.NC}")
        print(f"  Distribution: {Colors.YELLOW}{self.distro}{Colors.NC}")
        print(f"  Package Manager: {Colors.YELLOW}{self.package_manager['name']}{Colors.NC}")
        print(f"  Sudo Available: {Colors.GREEN if self.sudo_available else Colors.RED}{'Yes' if self.sudo_available else 'No'}{Colors.NC}")
        print(f"  Running as Root: {Colors.GREEN if os.geteuid() == 0 else Colors.YELLOW}{'Yes' if os.geteuid() == 0 else 'No'}{Colors.NC}")
        print()
    
    def show_categories(self):
        """Display available package categories"""
        print(f"{Colors.WHITE}Available Package Categories:{Colors.NC}")
        print()
        for key, info in PACKAGE_CATEGORIES.items():
            packages = info["packages"].get(self.distro, [])
            print(f"{Colors.MAGENTA}[{key.upper()}]{Colors.NC} {info['name']}")
            print(f"  Description: {info['description']}")
            print(f"  Packages ({len(packages)}): {', '.join(packages[:5])}{'...' if len(packages) > 5 else ''}")
            print()

def main():
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Package Manager Integration for Flatpack",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --info                     Show system information
  %(prog)s --list                     List available package categories  
  %(prog)s --install gaming           Install gaming support packages
  %(prog)s --install media system     Install media codecs and system tools
  %(prog)s --install-all              Install all package categories
  %(prog)s --update                   Update package database only
        """
    )
    
    parser.add_argument(
        '--info', '-i',
        action='store_true',
        help='Show system and package manager information'
    )
    
    parser.add_argument(
        '--list', '-l',
        action='store_true',
        help='List available package categories'
    )
    
    parser.add_argument(
        '--install',
        nargs='+',
        metavar='CATEGORY',
        help='Install packages for specified categories (gaming, media, development, system)'
    )
    
    parser.add_argument(
        '--install-all', '-a',
        action='store_true',
        help='Install all available package categories'
    )
    
    parser.add_argument(
        '--update', '-u',
        action='store_true',
        help='Update package database/cache only'
    )
    
    parser.add_argument(
        '--no-update',
        action='store_true',
        help='Skip package database update before installation'
    )
    
    parser.add_argument(
        '--version', '-v',
        action='version',
        version='Package Manager Integration 1.0.0'
    )
    
    args = parser.parse_args()
    
    # Initialize integration
    pmi = PackageManagerIntegration()
    
    if args.info:
        pmi.show_system_info()
        return
    
    if args.list:
        pmi.show_system_info()
        pmi.show_categories()
        return
    
    if args.update:
        pmi.update_package_database()
        return
    
    if args.install or args.install_all:
        pmi.show_system_info()
        
        # Update package database unless explicitly skipped
        if not args.no_update:
            pmi.update_package_database()
            print()
        
        success = True
        
        if args.install_all:
            # Install all categories
            for category in PACKAGE_CATEGORIES.keys():
                if not pmi.install_category(category):
                    success = False
                print()
        elif args.install:
            # Install specific categories
            for category in args.install:
                if not pmi.install_category(category):
                    success = False
                print()
        
        if success:
            print(f"{Colors.GREEN}[COMPLETE]{Colors.NC} Package installation completed successfully!")
            print(f"{Colors.YELLOW}[INFO]{Colors.NC} You may want to reboot or re-login for some changes to take effect.")
        else:
            print(f"{Colors.RED}[FAILED]{Colors.NC} Some package installations failed")
            sys.exit(1)
        
        return
    
    # No arguments provided
    parser.print_help()
    print(f"\n{Colors.BLUE}For a quick start, try:{Colors.NC}")
    print(f"  {sys.argv[0]} --info          # Show system information")
    print(f"  {sys.argv[0]} --list          # List available packages")
    print(f"  {sys.argv[0]} --install gaming # Install gaming packages")

if __name__ == "__main__":
    main()