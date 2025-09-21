#!/usr/bin/env python3
"""
CachyOS-Specific Package Optimizations

Enhanced package lists and configurations specifically optimized for CachyOS.
"""

from typing import Dict, List

# CachyOS-specific package categories with performance optimizations
CACHYOS_PACKAGE_CATEGORIES = {
    "performance": {
        "name": "Performance Optimization",
        "description": "CachyOS performance and optimization packages",
        "packages": [
            "cachyos-kernel-manager",
            "ananicy-cpp",
            "preload", 
            "irqbalance",
            "thermald",
            "cpupower",
            "powertop",
            "auto-cpufreq",
            "zram-generator",
            "systemd-swap"
        ]
    },
    "cachyos_tools": {
        "name": "CachyOS Tools",
        "description": "CachyOS-specific utilities and tools",
        "packages": [
            "cachyos-hello",
            "cachyos-fish-config", 
            "cachyos-zsh-config",
            "cachyos-settings",
            "rate-mirrors",
            "paru",
            "yay"
        ]
    },
    "gaming_enhanced": {
        "name": "Enhanced Gaming Support",
        "description": "Gaming packages optimized for CachyOS performance",
        "packages": [
            "steam",
            "lutris", 
            "heroic-games-launcher-bin",
            "bottles",
            "wine-staging",
            "wine-gecko",
            "wine-mono",
            "winetricks",
            "dxvk-bin",
            "vkd3d",
            "lib32-mesa",
            "lib32-vulkan-radeon", 
            "lib32-vulkan-intel",
            "lib32-nvidia-utils",
            "gamemode",
            "gamemoderun",
            "mangohud"
        ]
    },
    "media_codecs_enhanced": {
        "name": "Enhanced Media Support", 
        "description": "Comprehensive media codecs and tools for CachyOS",
        "packages": [
            "ffmpeg",
            "ffmpeg-amd-full",
            "gstreamer",
            "gst-plugins-base",
            "gst-plugins-good",
            "gst-plugins-bad",
            "gst-plugins-ugly", 
            "gst-libav",
            "libavcodec-full",
            "x264",
            "x265",
            "libvpx",
            "opus",
            "lame",
            "flac",
            "wavpack"
        ]
    },
    "development_enhanced": {
        "name": "Enhanced Development Tools",
        "description": "Development packages with CachyOS optimizations",
        "packages": [
            "git",
            "base-devel",
            "python",
            "python-pip",
            "nodejs",
            "npm",
            "rust",
            "go", 
            "gcc",
            "clang",
            "llvm",
            "cmake",
            "meson",
            "ninja",
            "docker",
            "podman",
            "code",
            "sublime-text-4"
        ]
    },
    "system_enhanced": {
        "name": "Enhanced System Utilities",
        "description": "System tools optimized for CachyOS",
        "packages": [
            "curl",
            "wget",
            "aria2",
            "unzip",
            "p7zip",
            "unrar",
            "htop",
            "btop",
            "neofetch",
            "fastfetch",
            "flatpak",
            "reflector",
            "pacman-contrib",
            "pkgfile",
            "fzf",
            "bat",
            "exa",
            "ripgrep",
            "fd",
            "zoxide"
        ]
    }
}

# CachyOS-specific Flatpak recommendations
CACHYOS_FLATPAKS = {
    "essential": [
        "org.freedesktop.Platform.ffmpeg-full",
        "org.freedesktop.Platform.openh264", 
        "com.github.tchx84.Flatseal",
        "org.freedesktop.Platform.VulkanLayer.MangoHud",
        "org.freedesktop.Platform.VulkanLayer.gamescope"
    ],
    "gaming": [
        "com.heroicgameslauncher.hgl",
        "net.lutris.Lutris",
        "com.usebottles.bottles",
        "org.prismlauncher.PrismLauncher",
        "com.mojang.Minecraft"
    ],
    "media": [
        "org.videolan.VLC",
        "io.mpv.Mpv", 
        "org.audacityteam.Audacity",
        "org.kde.kdenlive",
        "com.obsproject.Studio"
    ],
    "development": [
        "com.visualstudio.code",
        "org.jetbrains.PyCharm-Community",
        "io.github.shiftey.Desktop",
        "com.getpostman.Postman",
        "rest.insomnia.Insomnia"
    ]
}

# CachyOS-specific pacman configuration recommendations  
CACHYOS_PACMAN_CONFIG = {
    "ParallelDownloads": "5",
    "Color": "auto",
    "CheckSpace": "true",
    "VerbosePkgLists": "true",
    "DisableDownloadTimeout": "false",
    "ILoveCandy": "true"  # Enable pacman's progress bar
}

# CachyOS repository configuration
CACHYOS_REPOS = {
    "cachyos": {
        "server": "https://mirror.cachyos.org/repo/$arch/$repo",
        "key": "F3B607488DB35A47",
        "packages": [
            "linux-cachyos",
            "linux-cachyos-headers", 
            "cachyos-kernel-manager",
            "ananicy-cpp"
        ]
    },
    "chaotic-aur": {
        "server": "https://cdn-mirror.chaotic.cx/$repo/$arch",
        "key": "3056513887B78AEB", 
        "packages": [
            "paru-bin",
            "visual-studio-code-bin",
            "spotify",
            "discord"
        ]
    }
}

# Performance optimization settings for CachyOS
CACHYOS_OPTIMIZATIONS = {
    "kernel_parameters": [
        "mitigations=off",           # Disable CPU vulnerability mitigations for performance
        "preempt=full",              # Use full preemption for desktop responsiveness  
        "transparent_hugepage=madvise" # Optimize memory management
    ],
    "sysctl_tweaks": {
        "vm.swappiness": "10",       # Reduce swap usage
        "vm.vfs_cache_pressure": "50", # Balance filesystem cache
        "net.core.default_qdisc": "cake", # Use CAKE qdisc for network
        "net.ipv4.tcp_congestion_control": "bbr" # Use BBR congestion control
    },
    "systemd_services": {
        "enable": [
            "ananicy-cpp",
            "irqbalance", 
            "thermald",
            "fstrim.timer"
        ],
        "disable": [
            "NetworkManager-wait-online",  # Speed up boot
            "systemd-networkd-wait-online"
        ]
    },
    "environment_variables": {
        "MAKEFLAGS": "-j$(nproc)",           # Use all CPU cores for compilation
        "CFLAGS": "-march=native -mtune=native -O2", # Optimize for local CPU
        "CXXFLAGS": "-march=native -mtune=native -O2"
    }
}

def get_cachyos_package_recommendations(category: str = None) -> Dict[str, List[str]]:
    """Get CachyOS package recommendations by category"""
    if category and category in CACHYOS_PACKAGE_CATEGORIES:
        return {category: CACHYOS_PACKAGE_CATEGORIES[category]["packages"]}
    return {k: v["packages"] for k, v in CACHYOS_PACKAGE_CATEGORIES.items()}

def get_cachyos_flatpak_recommendations(category: str = None) -> List[str]:
    """Get CachyOS Flatpak recommendations"""
    if category and category in CACHYOS_FLATPAKS:
        return CACHYOS_FLATPAKS[category]
    
    # Return all recommendations
    all_flatpaks = []
    for flatpak_list in CACHYOS_FLATPAKS.values():
        all_flatpaks.extend(flatpak_list)
    return list(set(all_flatpaks))  # Remove duplicates

def generate_cachyos_setup_script() -> str:
    """Generate a comprehensive CachyOS setup script"""
    script = """#!/bin/bash
# CachyOS Performance Optimization Script
# Generated by Flatpack Manager

echo "🚀 Optimizing CachyOS system..."

# Update system first
sudo pacman -Sy

# Install performance packages
echo "Installing performance packages..."
sudo pacman -S --needed --noconfirm \\
    cachyos-kernel-manager ananicy-cpp preload irqbalance thermald \\
    cpupower powertop auto-cpufreq zram-generator

# Enable performance services
echo "Enabling performance services..."
sudo systemctl enable --now ananicy-cpp
sudo systemctl enable --now irqbalance  
sudo systemctl enable --now thermald
sudo systemctl enable --now fstrim.timer

# Configure pacman for parallel downloads
echo "Optimizing pacman configuration..."
if ! grep -q "ParallelDownloads" /etc/pacman.conf; then
    echo "ParallelDownloads = 5" | sudo tee -a /etc/pacman.conf
fi

if ! grep -q "^Color" /etc/pacman.conf; then
    sudo sed -i 's/#Color/Color/' /etc/pacman.conf
fi

if ! grep -q "ILoveCandy" /etc/pacman.conf; then
    echo "ILoveCandy" | sudo tee -a /etc/pacman.conf
fi

# Apply sysctl optimizations
echo "Applying kernel optimizations..."
sudo tee /etc/sysctl.d/99-cachyos-performance.conf << EOF
# CachyOS Performance Optimizations
vm.swappiness=10
vm.vfs_cache_pressure=50
net.core.default_qdisc=cake
net.ipv4.tcp_congestion_control=bbr
EOF

# Load sysctl settings
sudo sysctl --system

echo "✅ CachyOS optimizations applied!"
echo "Reboot recommended to apply all changes."
"""
    return script

def detect_cachyos_features() -> Dict[str, bool]:
    """Detect available CachyOS features"""
    import os
    import subprocess
    
    features = {
        "is_cachyos": False,
        "cachyos_repos_available": False,
        "cachyos_kernel": False,
        "ananicy_available": False,
        "chaotic_aur_enabled": False
    }
    
    # Check if running CachyOS
    try:
        if os.path.exists('/etc/cachyos-release'):
            features["is_cachyos"] = True
        elif os.path.exists('/etc/os-release'):
            with open('/etc/os-release', 'r') as f:
                content = f.read()
                if 'ID=cachyos' in content:
                    features["is_cachyos"] = True
    except:
        pass
    
    # Check for CachyOS kernel
    try:
        result = subprocess.run(['uname', '-r'], capture_output=True, text=True)
        if result.returncode == 0 and 'cachyos' in result.stdout.lower():
            features["cachyos_kernel"] = True
    except:
        pass
    
    # Check for ananicy
    try:
        result = subprocess.run(['systemctl', 'is-active', 'ananicy-cpp'], capture_output=True, text=True)
        features["ananicy_available"] = result.returncode == 0
    except:
        pass
    
    # Check for Chaotic AUR
    try:
        result = subprocess.run(['pacman', '-Sl', 'chaotic-aur'], capture_output=True, text=True)
        features["chaotic_aur_enabled"] = result.returncode == 0
    except:
        pass
    
    return features

if __name__ == "__main__":
    import json
    
    print("CachyOS Package Optimization Info")
    print("=" * 50)
    
    # Show detected features
    features = detect_cachyos_features()
    print("Detected CachyOS features:")
    for feature, available in features.items():
        status = "✅" if available else "❌"
        print(f"  {status} {feature}: {available}")
    
    print("\nAvailable package categories:")
    for category, info in CACHYOS_PACKAGE_CATEGORIES.items():
        print(f"  • {info['name']}: {len(info['packages'])} packages")
    
    print(f"\nRecommended Flatpaks: {len(get_cachyos_flatpak_recommendations())} total")
    
    # Generate setup script
    setup_script_path = "/tmp/cachyos_setup.sh"
    with open(setup_script_path, 'w') as f:
        f.write(generate_cachyos_setup_script())
    print(f"\nGenerated setup script: {setup_script_path}")