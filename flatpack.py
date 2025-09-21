#!/usr/bin/env python3
"""
Flatpack: A Flatpak update manager

A comprehensive tool for managing Flatpak application updates with features for:
- Listing installed applications
- Checking for available updates
- Updating specific applications or all applications
- Interactive and non-interactive modes
"""

import subprocess
import argparse
import sys
from typing import List, Dict, Optional
from datetime import datetime


def run_command(cmd: List[str], suppress_stderr: bool = False) -> subprocess.CompletedProcess:
    """Run a command and return the result"""
    try:
        if suppress_stderr:
            result = subprocess.run(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                check=False
            )
        else:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=False
            )
        return result
    except Exception as e:
        print(f"Error running command {' '.join(cmd)}: {e}")
        sys.exit(1)


def check_flatpak_available() -> bool:
    """Check if Flatpak is installed and available"""
    result = run_command(["flatpak", "--version"])
    return result.returncode == 0


def list_installed_apps() -> List[Dict[str, str]]:
    """List all installed Flatpak applications"""
    cmd = ["flatpak", "list", "--app", "--columns=application,name,version,branch"]
    result = run_command(cmd)
    
    if result.returncode != 0:
        print(f"Error listing installed apps: {result.stderr}")
        return []
    
    apps = []
    for line in result.stdout.strip().split('\n'):
        if line.strip():
            parts = line.split('\t')
            if len(parts) >= 3:
                apps.append({
                    'id': parts[0],
                    'name': parts[1], 
                    'version': parts[2],
                    'branch': parts[3] if len(parts) > 3 else 'stable'
                })
    
    return apps


def check_for_updates() -> List[str]:
    """Check which apps have updates available using --no-deploy flag"""
    print("Checking for updates (this may take a moment)...")
    
    # Use --no-deploy to check for updates without actually downloading/installing
    cmd = ["flatpak", "update", "--no-deploy", "--noninteractive"]
    result = run_command(cmd, suppress_stderr=True)
    
    # Parse output to find apps with updates
    updatable_apps = []
    for line in result.stdout.split('\n'):
        if line.startswith("Updating app/"):
            # Extract app ID from "Updating app/com.example.App/x86_64/stable"
            app_info = line.replace("Updating app/", "")
            app_id = app_info.split('/')[0]
            updatable_apps.append(app_id)
    
    return updatable_apps


def get_app_info(app_id: str) -> Optional[Dict[str, str]]:
    """Get detailed information about a specific app"""
    apps = list_installed_apps()
    for app in apps:
        if app['id'] == app_id:
            return app
    return None


def update_apps(app_ids: Optional[List[str]] = None, interactive: bool = False) -> bool:
    """Update specified apps or all apps if none specified"""
    cmd = ["flatpak", "update"]
    
    if not interactive:
        cmd.append("--noninteractive")
    
    if app_ids:
        # Validate that specified apps are actually installed
        installed_apps = [app['id'] for app in list_installed_apps()]
        invalid_apps = [app_id for app_id in app_ids if app_id not in installed_apps]
        
        if invalid_apps:
            print(f"Warning: The following apps are not installed: {', '.join(invalid_apps)}")
            app_ids = [app_id for app_id in app_ids if app_id in installed_apps]
            
            if not app_ids:
                print("No valid apps to update.")
                return False
        
        cmd.extend(app_ids)
    
    print(f"Running: {' '.join(cmd)}")
    result = run_command(cmd)
    
    if result.returncode == 0:
        print("\nUpdate completed successfully!")
        if result.stdout:
            print(result.stdout)
        return True
    else:
        print(f"Update failed with exit code {result.returncode}")
        if result.stderr:
            print(f"Error: {result.stderr}")
        if result.stdout:
            print(f"Output: {result.stdout}")
        return False


def update_specific_apps(updatable_apps: List[str], interactive: bool = False) -> bool:
    """Update only the apps that have updates available"""
    if not updatable_apps:
        print("No apps need updating.")
        return True
    
    if interactive:
        print(f"\nThe following {len(updatable_apps)} app(s) have updates available:")
        for i, app_id in enumerate(updatable_apps, 1):
            app_info = get_app_info(app_id)
            name = app_info['name'] if app_info else app_id
            print(f"  {i}. {app_id} ({name})")
        
        response = input(f"\nUpdate all {len(updatable_apps)} app(s)? [Y/n]: ")
        if response.lower().startswith('n'):
            print("Update cancelled.")
            return False
    
    return update_apps(updatable_apps, interactive)


def main():
    parser = argparse.ArgumentParser(
        description="Flatpack: A comprehensive Flatpak update manager",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --list                    List all installed apps
  %(prog)s --check                   Check for available updates
  %(prog)s --update                  Update all apps (non-interactive)
  %(prog)s --update --interactive    Update all apps (interactive)
  %(prog)s --update --apps com.example.App
                                     Update specific app
  %(prog)s --smart-update            Update only apps that need updates
        """
    )
    
    parser.add_argument(
        "--list", "-l",
        action="store_true",
        help="List installed applications with details"
    )
    
    parser.add_argument(
        "--check", "-c",
        action="store_true",
        help="Check for available updates without installing"
    )
    
    parser.add_argument(
        "--update", "-u",
        action="store_true",
        help="Update applications"
    )
    
    parser.add_argument(
        "--smart-update", "-s",
        action="store_true",
        help="Update only apps that have updates available"
    )
    
    parser.add_argument(
        "--apps",
        nargs="+",
        metavar="APP_ID",
        help="Specific app IDs to update (space-separated)"
    )
    
    parser.add_argument(
        "--interactive", "-i",
        action="store_true",
        help="Run in interactive mode (show prompts and confirmations)"
    )
    
    parser.add_argument(
        "--version", "-v",
        action="version",
        version="Flatpack 1.0.0"
    )
    
    args = parser.parse_args()
    
    # Check if Flatpak is available
    if not check_flatpak_available():
        print("Error: Flatpak is not installed or not available in PATH")
        sys.exit(1)
    
    if args.list:
        apps = list_installed_apps()
        if apps:
            print(f"\nInstalled Flatpak Applications ({len(apps)} total):")
            print("=" * 80)
            for app in apps:
                print(f"ID:      {app['id']}")
                print(f"Name:    {app['name']}")
                print(f"Version: {app['version']}")
                print(f"Branch:  {app['branch']}")
                print("-" * 40)
        else:
            print("No Flatpak applications found.")
    
    elif args.check:
        updatable_apps = check_for_updates()
        if updatable_apps:
            print(f"\n✓ Updates available for {len(updatable_apps)} app(s):")
            print("=" * 50)
            for app_id in updatable_apps:
                app_info = get_app_info(app_id)
                if app_info:
                    print(f"  {app_id} ({app_info['name']})")
                    print(f"    Current version: {app_info['version']}")
                else:
                    print(f"  {app_id}")
                print()
            print(f"Run 'flatpack --smart-update' to update these apps.")
        else:
            print("\n✓ All apps are up to date!")
    
    elif args.smart_update:
        updatable_apps = check_for_updates()
        if updatable_apps:
            print(f"\nSmart update: Found {len(updatable_apps)} app(s) with updates available.")
            update_specific_apps(updatable_apps, args.interactive)
        else:
            print("\n✓ All apps are already up to date!")
    
    elif args.update:
        if args.apps:
            print(f"Updating specific apps: {', '.join(args.apps)}")
            success = update_apps(args.apps, args.interactive)
        else:
            print("Updating all apps...")
            success = update_apps(interactive=args.interactive)
        
        if not success:
            sys.exit(1)
    
    else:
        parser.print_help()
        print("\nFor a quick start, try: flatpack --check")


if __name__ == "__main__":
    main()