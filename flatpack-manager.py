#!/usr/bin/env python3
"""
Flatpack Manager - Unified Interface

A comprehensive unified interface for the complete Flatpack ecosystem:
- Native package management
- Flatpak application installation
- Update management
- System optimization

This is the single entry point that orchestrates all Flatpack tools.
"""

import subprocess
import sys
import os
import argparse
import json
from pathlib import Path
from typing import List, Dict, Optional
import shutil

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

class FlatpackManager:
    def __init__(self):
        self.script_dir = Path(__file__).parent
        self.tools = self.check_tool_availability()
        
    def run_command(self, cmd: List[str], capture_output: bool = False) -> subprocess.CompletedProcess:
        """Run a command and return the result"""
        try:
            result = subprocess.run(
                cmd,
                capture_output=capture_output,
                text=True,
                check=False,
                cwd=self.script_dir
            )
            return result
        except Exception as e:
            print(f"{Colors.RED}[ERROR]{Colors.NC} Failed to run command {' '.join(cmd)}: {e}")
            return subprocess.CompletedProcess(cmd, 1, "", str(e))
    
    def check_tool_availability(self) -> Dict[str, bool]:
        """Check which Flatpack tools are available"""
        tools = {}
        
        # Check for each tool
        tool_files = {
            'installer': 'install_flatpaks.sh',
            'updater': 'flatpack.py',  
            'pkgmgr': 'package_manager_integration.py',
            'update_installer': 'install_update_manager.sh'
        }
        
        for tool, filename in tool_files.items():
            tool_path = self.script_dir / filename
            tools[tool] = tool_path.exists() and tool_path.is_file()
            
        return tools
    
    def show_banner(self):
        """Display the Flatpack Manager banner"""
        print(f"{Colors.CYAN}╔══════════════════════════════════════════════════════════════════════╗")
        print(f"║                       {Colors.WHITE}FLATPACK MANAGER v2.0{Colors.CYAN}                        ║") 
        print(f"╠══════════════════════════════════════════════════════════════════════╣")
        print(f"║                 {Colors.WHITE}Unified Linux Application Management{Colors.CYAN}              ║")
        print(f"╚══════════════════════════════════════════════════════════════════════╝{Colors.NC}")
        print()
    
    def show_status(self):
        """Show system and tool status"""
        print(f"{Colors.WHITE}System Status:{Colors.NC}")
        print(f"  Operating System: {Colors.YELLOW}Linux{Colors.NC}")
        print(f"  Flatpak Available: {Colors.GREEN if shutil.which('flatpak') else Colors.RED}{'Yes' if shutil.which('flatpak') else 'No'}{Colors.NC}")
        print(f"  Python Available: {Colors.GREEN}Yes{Colors.NC} ({sys.version.split()[0]})")
        print()
        
        print(f"{Colors.WHITE}Available Tools:{Colors.NC}")
        for tool, available in self.tools.items():
            status_color = Colors.GREEN if available else Colors.RED
            status_text = "Available" if available else "Missing"
            tool_name = {
                'installer': 'Flatpak Installer',
                'updater': 'Update Manager', 
                'pkgmgr': 'Package Manager Integration',
                'update_installer': 'Update Manager Installer'
            }.get(tool, tool)
            
            print(f"  {tool_name}: {status_color}{status_text}{Colors.NC}")
        print()
    
    def setup_complete_system(self):
        """Run complete system setup workflow"""
        self.show_banner()
        print(f"{Colors.MAGENTA}[SETUP]{Colors.NC} Running complete system setup workflow...")
        print()
        
        success = True
        
        # Step 1: Install native packages
        if self.tools['pkgmgr']:
            print(f"{Colors.BLUE}[STEP 1/3]{Colors.NC} Installing native packages...")
            result = self.run_command(['python3', 'package_manager_integration.py', '--install-all'])
            if result.returncode != 0:
                print(f"{Colors.RED}[FAILED]{Colors.NC} Native package installation failed")
                success = False
            else:
                print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} Native packages installed")
            print()
        else:
            print(f"{Colors.YELLOW}[SKIP]{Colors.NC} Package manager integration not available")
        
        # Step 2: Install Flatpak apps
        if self.tools['installer']:
            print(f"{Colors.BLUE}[STEP 2/3]{Colors.NC} Installing Flatpak applications...")
            result = self.run_command(['bash', 'install_flatpaks.sh'])
            if result.returncode != 0:
                print(f"{Colors.RED}[FAILED]{Colors.NC} Flatpak installation failed")
                success = False
            else:
                print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} Flatpak applications installed")
            print()
        else:
            print(f"{Colors.YELLOW}[SKIP]{Colors.NC} Flatpak installer not available")
        
        # Step 3: Install update manager system-wide
        if self.tools['update_installer']:
            print(f"{Colors.BLUE}[STEP 3/3]{Colors.NC} Installing update manager system-wide...")
            result = self.run_command(['sudo', 'bash', 'install_update_manager.sh'])
            if result.returncode != 0:
                print(f"{Colors.YELLOW}[OPTIONAL]{Colors.NC} Update manager system installation failed (not critical)")
            else:
                print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} Update manager installed system-wide")
            print()
        
        if success:
            print(f"{Colors.GREEN}[COMPLETE]{Colors.NC} Complete system setup finished successfully!")
            print()
            print(f"{Colors.CYAN}Next steps:{Colors.NC}")
            print(f"  • Run '{Colors.WHITE}flatpack --check{Colors.NC}' to check for app updates")
            print(f"  • Run '{Colors.WHITE}flatpack --smart-update{Colors.NC}' to update apps efficiently")
            print(f"  • Use '{Colors.WHITE}flatpack-manager --help{Colors.NC}' for more options")
        else:
            print(f"{Colors.RED}[FAILED]{Colors.NC} Some parts of setup failed. Check output above.")
            return False
        
        return True
    
    def update_system(self):
        """Update both native packages and Flatpak apps"""
        self.show_banner()
        print(f"{Colors.MAGENTA}[UPDATE]{Colors.NC} Updating complete system...")
        print()
        
        success = True
        
        # Update native packages
        if self.tools['pkgmgr']:
            print(f"{Colors.BLUE}[NATIVE]{Colors.NC} Updating native package database...")
            result = self.run_command(['python3', 'package_manager_integration.py', '--update'])
            if result.returncode == 0:
                print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} Native package database updated")
            else:
                print(f"{Colors.YELLOW}[WARNING]{Colors.NC} Native package update failed")
                success = False
            print()
        
        # Update Flatpak apps
        if self.tools['updater']:
            print(f"{Colors.BLUE}[FLATPAK]{Colors.NC} Updating Flatpak applications...")
            result = self.run_command(['python3', 'flatpack.py', '--smart-update'])
            if result.returncode == 0:
                print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} Flatpak applications updated")
            else:
                print(f"{Colors.RED}[FAILED]{Colors.NC} Flatpak update failed")
                success = False
            print()
        else:
            print(f"{Colors.YELLOW}[SKIP]{Colors.NC} Flatpak update manager not available")
        
        if success:
            print(f"{Colors.GREEN}[COMPLETE]{Colors.NC} System update completed successfully!")
        else:
            print(f"{Colors.RED}[FAILED]{Colors.NC} Some updates failed. Check output above.")
        
        return success
    
    def run_tool(self, tool: str, args: List[str] = None):
        """Run a specific Flatpack tool with arguments"""
        if args is None:
            args = []
            
        tool_commands = {
            'installer': ['bash', 'install_flatpaks.sh'] + args,
            'updater': ['python3', 'flatpack.py'] + args,
            'pkgmgr': ['python3', 'package_manager_integration.py'] + args,
        }
        
        if tool not in tool_commands:
            print(f"{Colors.RED}[ERROR]{Colors.NC} Unknown tool: {tool}")
            return False
            
        if not self.tools[tool]:
            print(f"{Colors.RED}[ERROR]{Colors.NC} Tool not available: {tool}")
            return False
        
        result = self.run_command(tool_commands[tool])
        return result.returncode == 0
    
    def show_interactive_menu(self):
        """Show interactive menu for tool selection"""
        self.show_banner()
        
        print(f"{Colors.WHITE}What would you like to do?{Colors.NC}")
        print()
        print(f"{Colors.YELLOW}[1]{Colors.NC} Complete System Setup (recommended for new systems)")
        print(f"{Colors.YELLOW}[2]{Colors.NC} Update Everything (native packages + Flatpak apps)")
        print(f"{Colors.YELLOW}[3]{Colors.NC} Install Native Packages Only")
        print(f"{Colors.YELLOW}[4]{Colors.NC} Install Flatpak Apps Only")  
        print(f"{Colors.YELLOW}[5]{Colors.NC} Update Flatpak Apps Only")
        print(f"{Colors.YELLOW}[6]{Colors.NC} Check System Status")
        print(f"{Colors.YELLOW}[7]{Colors.NC} Show Tool Information")
        print(f"{Colors.YELLOW}[0]{Colors.NC} Exit")
        print()
        
        try:
            choice = input(f"{Colors.WHITE}Enter your choice [0-7]: {Colors.NC}")
            return choice.strip()
        except (KeyboardInterrupt, EOFError):
            print(f"\n{Colors.YELLOW}[EXIT]{Colors.NC} Goodbye!")
            return "0"
    
    def handle_interactive_choice(self, choice: str):
        """Handle interactive menu choice"""
        if choice == "1":
            return self.setup_complete_system()
        elif choice == "2":
            return self.update_system()
        elif choice == "3":
            if self.tools['pkgmgr']:
                return self.run_tool('pkgmgr', ['--install-all'])
            else:
                print(f"{Colors.RED}[ERROR]{Colors.NC} Package manager integration not available")
                return False
        elif choice == "4":
            if self.tools['installer']:
                return self.run_tool('installer')
            else:
                print(f"{Colors.RED}[ERROR]{Colors.NC} Flatpak installer not available")
                return False
        elif choice == "5":
            if self.tools['updater']:
                return self.run_tool('updater', ['--smart-update'])
            else:
                print(f"{Colors.RED}[ERROR]{Colors.NC} Update manager not available")
                return False
        elif choice == "6":
            self.show_status()
            return True
        elif choice == "7":
            self.show_tool_info()
            return True
        elif choice == "0":
            print(f"{Colors.YELLOW}[EXIT]{Colors.NC} Goodbye!")
            return True
        else:
            print(f"{Colors.RED}[ERROR]{Colors.NC} Invalid choice: {choice}")
            return False
    
    def show_tool_info(self):
        """Show detailed information about available tools"""
        print(f"{Colors.WHITE}Flatpack Tool Information:{Colors.NC}")
        print()
        
        tools_info = {
            'installer': {
                'name': 'Flatpak Installer (install_flatpaks.sh)',
                'description': 'Installs curated Flatpak applications with gaming focus',
                'features': ['Parallel installations', 'Auto-timeouts', 'SteamDeck optimization', 'Resume capability']
            },
            'updater': {
                'name': 'Update Manager (flatpack.py)',
                'description': 'Smart Flatpak application update management',
                'features': ['Smart update detection', 'Selective updates', 'No false positives', 'Batch operations']
            },
            'pkgmgr': {
                'name': 'Package Manager Integration',
                'description': 'Native package management across distributions',
                'features': ['Multi-distro support', 'Category-based installs', 'Duplicate detection', 'Gaming packages']
            }
        }
        
        for tool, available in self.tools.items():
            if tool in tools_info:
                info = tools_info[tool]
                status_color = Colors.GREEN if available else Colors.RED
                status_text = "Available" if available else "Missing"
                
                print(f"{Colors.CYAN}• {info['name']}{Colors.NC}")
                print(f"  Status: {status_color}{status_text}{Colors.NC}")
                print(f"  Description: {info['description']}")
                print(f"  Features: {', '.join(info['features'])}")
                print()

def main():
    parser = argparse.ArgumentParser(
        description="Flatpack Manager - Unified Linux Application Management",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                           Launch interactive mode
  %(prog)s --setup                   Run complete system setup
  %(prog)s --update                  Update everything  
  %(prog)s --status                  Show system status
  %(prog)s --install-native          Install native packages only
  %(prog)s --install-flatpak         Install Flatpak apps only
  %(prog)s --update-flatpak          Update Flatpak apps only
        """
    )
    
    parser.add_argument(
        '--setup',
        action='store_true',
        help='Run complete system setup (native packages + Flatpak apps)'
    )
    
    parser.add_argument(
        '--update',
        action='store_true', 
        help='Update everything (native packages + Flatpak apps)'
    )
    
    parser.add_argument(
        '--status',
        action='store_true',
        help='Show system and tool status'
    )
    
    parser.add_argument(
        '--install-native',
        action='store_true',
        help='Install native packages only'
    )
    
    parser.add_argument(
        '--install-flatpak',
        action='store_true',
        help='Install Flatpak applications only'
    )
    
    parser.add_argument(
        '--update-flatpak', 
        action='store_true',
        help='Update Flatpak applications only'
    )
    
    parser.add_argument(
        '--interactive', '-i',
        action='store_true',
        help='Force interactive mode (default when no args)'
    )
    
    parser.add_argument(
        '--version', '-v',
        action='version',
        version='Flatpack Manager 2.0.0'
    )
    
    args = parser.parse_args()
    
    # Initialize manager
    manager = FlatpackManager()
    
    # Handle command line arguments
    if args.setup:
        success = manager.setup_complete_system()
        sys.exit(0 if success else 1)
    elif args.update:
        success = manager.update_system() 
        sys.exit(0 if success else 1)
    elif args.status:
        manager.show_banner()
        manager.show_status()
    elif args.install_native:
        success = manager.run_tool('pkgmgr', ['--install-all'])
        sys.exit(0 if success else 1)
    elif args.install_flatpak:
        success = manager.run_tool('installer')
        sys.exit(0 if success else 1)
    elif args.update_flatpak:
        success = manager.run_tool('updater', ['--smart-update'])
        sys.exit(0 if success else 1)
    else:
        # Interactive mode (default)
        while True:
            choice = manager.show_interactive_menu()
            if choice == "0":
                break
                
            manager.handle_interactive_choice(choice)
            
            if choice != "0":
                input(f"\n{Colors.GRAY}Press Enter to continue...{Colors.NC}")

if __name__ == "__main__":
    main()