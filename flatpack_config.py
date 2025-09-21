#!/usr/bin/env python3
"""
Flatpack Configuration Management System

Handles user preferences, custom package lists, and system-specific optimizations.
"""

import json
import os
from pathlib import Path
from typing import Dict, List, Any, Optional
import subprocess

class FlatpackConfig:
    def __init__(self):
        self.config_dir = Path.home() / '.config' / 'flatpack'
        self.config_file = self.config_dir / 'config.json'
        self.custom_packages_file = self.config_dir / 'custom_packages.json'
        self.config = self.load_config()
        
        # Ensure config directory exists
        self.config_dir.mkdir(parents=True, exist_ok=True)
    
    def get_default_config(self) -> Dict[str, Any]:
        """Get default configuration with CachyOS optimizations"""
        distro = self.detect_cachyos()
        
        return {
            "version": "2.1",
            "distro_info": {
                "detected": distro,
                "is_cachyos": distro == "cachyos",
                "pacman_flags": self.get_optimal_pacman_flags(distro)
            },
            "preferences": {
                "auto_confirm": False,
                "parallel_downloads": True,
                "max_parallel_jobs": 4,
                "update_timeout": 300,
                "interactive_timeouts": 10,
                "show_progress": True,
                "colored_output": True,
                "log_level": "info"
            },
            "update_behavior": {
                "smart_update_default": True,
                "backup_before_update": False,
                "cleanup_after_update": True,
                "check_disk_space": True,
                "min_free_space_gb": 2
            },
            "notifications": {
                "update_available": True,
                "update_complete": True,
                "error_notifications": True,
                "desktop_notifications": True
            },
            "performance": {
                "use_mirrors": True,
                "parallel_operations": True,
                "cache_cleanup_days": 7,
                "optimize_for_ssd": True
            },
            "custom_repositories": [],
            "excluded_packages": [],
            "priority_packages": []
        }
    
    def detect_cachyos(self) -> str:
        """Detect if running on CachyOS or other Arch-based distros"""
        try:
            # Check /etc/os-release
            if os.path.exists('/etc/os-release'):
                with open('/etc/os-release', 'r') as f:
                    content = f.read()
                    if 'ID=cachyos' in content:
                        return "cachyos"
                    elif 'ID_LIKE=arch' in content or 'ID=arch' in content:
                        return "arch"
            
            # Check for CachyOS-specific files
            if os.path.exists('/etc/cachyos-release'):
                return "cachyos"
            elif os.path.exists('/etc/arch-release'):
                return "arch"
                
        except Exception:
            pass
            
        return "unknown"
    
    def get_optimal_pacman_flags(self, distro: str) -> Dict[str, str]:
        """Get optimal pacman flags for the detected system"""
        if distro == "cachyos":
            return {
                "install": "--needed --noconfirm",
                "update": "--noconfirm",
                "parallel_downloads": "5",
                "use_color": "auto"
            }
        elif distro == "arch":
            return {
                "install": "--needed --noconfirm", 
                "update": "--noconfirm",
                "parallel_downloads": "3",
                "use_color": "auto"
            }
        else:
            return {
                "install": "--needed",
                "update": "",
                "parallel_downloads": "1",
                "use_color": "never"
            }
    
    def load_config(self) -> Dict[str, Any]:
        """Load configuration from file or create default"""
        if self.config_file.exists():
            try:
                with open(self.config_file, 'r') as f:
                    config = json.load(f)
                    
                # Merge with defaults for new keys
                default_config = self.get_default_config()
                return self.merge_configs(default_config, config)
                    
            except (json.JSONDecodeError, KeyError) as e:
                print(f"Warning: Invalid config file, using defaults: {e}")
                return self.get_default_config()
        else:
            return self.get_default_config()
    
    def merge_configs(self, default: Dict, user: Dict) -> Dict:
        """Recursively merge user config with defaults"""
        result = default.copy()
        for key, value in user.items():
            if key in result and isinstance(result[key], dict) and isinstance(value, dict):
                result[key] = self.merge_configs(result[key], value)
            else:
                result[key] = value
        return result
    
    def save_config(self) -> bool:
        """Save current configuration to file"""
        try:
            with open(self.config_file, 'w') as f:
                json.dump(self.config, f, indent=2)
            return True
        except Exception as e:
            print(f"Error saving config: {e}")
            return False
    
    def get(self, key_path: str, default: Any = None) -> Any:
        """Get configuration value using dot notation (e.g., 'preferences.auto_confirm')"""
        keys = key_path.split('.')
        value = self.config
        
        for key in keys:
            if isinstance(value, dict) and key in value:
                value = value[key]
            else:
                return default
        
        return value
    
    def set(self, key_path: str, value: Any) -> bool:
        """Set configuration value using dot notation"""
        keys = key_path.split('.')
        config_ref = self.config
        
        # Navigate to parent of target key
        for key in keys[:-1]:
            if key not in config_ref:
                config_ref[key] = {}
            config_ref = config_ref[key]
        
        # Set the value
        config_ref[keys[-1]] = value
        return self.save_config()
    
    def add_custom_package_list(self, name: str, packages: List[str], description: str = "") -> bool:
        """Add a custom package list"""
        custom_packages = self.load_custom_packages()
        custom_packages[name] = {
            "description": description,
            "packages": packages,
            "created": str(datetime.now()),
            "enabled": True
        }
        return self.save_custom_packages(custom_packages)
    
    def load_custom_packages(self) -> Dict[str, Any]:
        """Load custom package lists"""
        if self.custom_packages_file.exists():
            try:
                with open(self.custom_packages_file, 'r') as f:
                    return json.load(f)
            except json.JSONDecodeError:
                pass
        return {}
    
    def save_custom_packages(self, packages: Dict[str, Any]) -> bool:
        """Save custom package lists"""
        try:
            with open(self.custom_packages_file, 'w') as f:
                json.dump(packages, f, indent=2)
            return True
        except Exception as e:
            print(f"Error saving custom packages: {e}")
            return False
    
    def get_cachyos_optimizations(self) -> Dict[str, Any]:
        """Get CachyOS-specific optimizations"""
        if not self.get('distro_info.is_cachyos', False):
            return {}
            
        return {
            "enable_chaotic_aur": True,
            "use_cachyos_kernels": True,
            "performance_packages": [
                "cachyos-kernel-manager",
                "ananicy-cpp", 
                "preload",
                "irqbalance",
                "thermald"
            ],
            "optimization_flags": {
                "march": "native",
                "mtune": "native", 
                "lto": "full"
            },
            "recommended_flatpaks": [
                "org.freedesktop.Platform.ffmpeg-full",
                "org.freedesktop.Platform.openh264",
                "com.github.tchx84.Flatseal"
            ]
        }
    
    def apply_system_optimizations(self) -> bool:
        """Apply system-specific optimizations"""
        if not self.get('distro_info.is_cachyos', False):
            return True
            
        optimizations = self.get_cachyos_optimizations()
        
        # Configure pacman for parallel downloads
        try:
            pacman_conf = "/etc/pacman.conf"
            if os.path.exists(pacman_conf):
                with open(pacman_conf, 'r') as f:
                    content = f.read()
                
                if "ParallelDownloads" not in content:
                    print("CachyOS optimization: Enabling parallel downloads in pacman")
                    # This would require sudo, so just recommend it
                    print("Recommendation: Add 'ParallelDownloads = 5' to /etc/pacman.conf")
                    
        except Exception as e:
            print(f"Warning: Could not optimize pacman config: {e}")
            
        return True
    
    def show_config_summary(self):
        """Display current configuration summary"""
        print("📋 Flatpack Configuration Summary")
        print("=" * 50)
        
        distro_info = self.get('distro_info', {})
        print(f"System: {distro_info.get('detected', 'unknown')}")
        if distro_info.get('is_cachyos'):
            print("🚀 CachyOS optimizations: ENABLED")
        
        print(f"Auto-confirm operations: {self.get('preferences.auto_confirm', False)}")
        print(f"Parallel operations: {self.get('preferences.parallel_downloads', False)}")
        print(f"Smart updates default: {self.get('update_behavior.smart_update_default', True)}")
        print(f"Desktop notifications: {self.get('notifications.desktop_notifications', True)}")
        
        custom_packages = self.load_custom_packages()
        if custom_packages:
            print(f"Custom package lists: {len(custom_packages)}")
            
        print()

# Convenience functions for other modules
def get_config() -> FlatpackConfig:
    """Get global config instance"""
    return FlatpackConfig()

def get_setting(key: str, default: Any = None) -> Any:
    """Quick access to configuration settings"""
    return get_config().get(key, default)

if __name__ == "__main__":
    from datetime import datetime
    import argparse
    
    parser = argparse.ArgumentParser(description="Flatpack Configuration Management")
    parser.add_argument("--show", action="store_true", help="Show current configuration")
    parser.add_argument("--init", action="store_true", help="Initialize default configuration")
    parser.add_argument("--set", nargs=2, metavar=('KEY', 'VALUE'), help="Set configuration value")
    
    args = parser.parse_args()
    
    config = FlatpackConfig()
    
    if args.show:
        config.show_config_summary()
    elif args.init:
        config.save_config()
        print("Configuration initialized with defaults")
    elif args.set:
        key, value = args.set
        # Try to parse value as JSON for complex types
        try:
            parsed_value = json.loads(value)
        except json.JSONDecodeError:
            parsed_value = value
            
        if config.set(key, parsed_value):
            print(f"Set {key} = {parsed_value}")
        else:
            print("Failed to save configuration")
    else:
        config.show_config_summary()