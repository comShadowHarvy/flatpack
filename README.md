# 🚀 Flatpack Auto-Installer v3.3

<div align="center">

![Flatpack Logo](https://img.shields.io/badge/Flatpack-Auto--Installer-blue?style=for-the-badge&logo=linux)
![Version](https://img.shields.io/badge/version-3.3-green?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-yellow?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-Linux-red?style=for-the-badge&logo=linux)

**🎮 SteamDeck & Bazzite Optimized Flatpak Installer**

*Automated, secure, and intelligent Flatpak application installer designed specifically for handheld gaming systems*

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Configuration](#-configuration) • [Troubleshooting](#-troubleshooting)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Usage](#-usage)
- [Configuration](#-configuration)
- [Applications Included](#-applications-included)
- [Advanced Features](#-advanced-features)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)
- [Author](#-author)

## 🎯 Overview

**Flatpack Auto-Installer** is a sophisticated bash script designed to automate the installation of essential Flatpak applications on Linux systems, with special optimization for **SteamDeck** and **Bazzite** handheld gaming platforms.

Created by **ShadowHarvy** (Ex-Hacker & Security Enthusiast), this tool focuses on:
- 🔒 **Security-first approach** with sandboxed applications
- 🎮 **Gaming-optimized** application selection
- 🚀 **Intelligent installation** with retry logic and parallel processing
- 📊 **State management** with resume capability
- ⚙️ **Highly configurable** with extensive customization options

## ✨ Features

### 🎮 Core Features
- **11 Curated Applications** - Hand-picked for gaming and productivity
- **SteamDeck/Bazzite Optimized** - Tailored for handheld gaming systems  
- **One-Command Installation** - Simple execution with intelligent automation
- **Security Focused** - Only uses official Flathub repository

### 🚀 Advanced Features
- **Parallel Installation** - Concurrent app installations for faster completion
- **State Persistence** - Resume interrupted installations
- **Smart Skip Logic** - Automatically skip already installed applications
- **Retry Mechanism** - Configurable retry attempts for failed installations
- **Progress Tracking** - Real-time installation progress with visual indicators
- **Storage Validation** - Pre-flight disk space checking
- **Configuration System** - Extensive customization via config files

### 🧠 Smart Features (NEW in v3.3)
- **System Detection** - Auto-detects SteamDeck, Bazzite, or desktop Linux
- **Gaming Mode Detection** - Adapts interface for Gamescope/Big Picture
- **Dry-Run Mode** - Preview installations without executing
- **Command-Line Arguments** - Full CLI support with --dry-run, --verbose, --help
- **Comprehensive Logging** - Multi-level logging with DEBUG/INFO/WARN/ERROR

### 🎮 SteamDeck Features (NEW in v3.3)
- **Steam Library Integration** - Auto-adds Flatpaks to Steam (SteamDeck only)
- **Desktop Shortcuts** - Creates .desktop files with proper metadata
- **Post-Install Launching** - Interactive menu to test apps immediately
- **System-Aware Operation** - Features activate based on detected system type

### 🛠️ Technical Features
- **Error Recovery** - Intelligent handling of installation failures
- **Detailed Logging** - Comprehensive installation tracking
- **Clean Installation** - Automatic cleanup of temporary files
- **Exit Codes** - Proper exit status for scripting integration
- **Color-Coded Output** - Enhanced readability with ANSI color support

## ⚡ Quick Start

```bash
# Clone and run in one command
curl -sSL https://raw.githubusercontent.com/comShadowHarvy/flatpack/main/install_flatpaks.sh | bash
```

Or for more control:

```bash
# Clone repository
git clone https://github.com/comShadowHarvy/flatpack.git
cd flatpack

# Make executable and run
chmod +x install_flatpaks.sh
./install_flatpaks.sh
```

## 📥 Installation

### Prerequisites

- **Linux System** (SteamDeck, Bazzite, or any modern Linux distribution)
- **Flatpak** installed and configured
- **Internet connection** for downloading applications
- **2GB+ free disk space** (recommended)

### Method 1: Direct Download & Execute
```bash
# Download and execute directly
wget https://raw.githubusercontent.com/comShadowHarvy/flatpack/main/install_flatpaks.sh
chmod +x install_flatpaks.sh
./install_flatpaks.sh
```

### Method 2: Git Clone
```bash
# Clone repository
git clone https://github.com/comShadowHarvy/flatpack.git
cd flatpack
chmod +x install_flatpaks.sh
./install_flatpaks.sh
```

### Method 3: One-Liner (Recommended for SteamDeck)
```bash
# Execute directly from GitHub
bash <(curl -s https://raw.githubusercontent.com/comShadowHarvy/flatpack/main/install_flatpaks.sh)
```

## 🎯 Usage

### Basic Usage
```bash
# Run with default settings
./install_flatpaks.sh
```

### Advanced Usage
```bash
# Preview what would be installed (NEW!)
./install_flatpaks.sh --dry-run

# Run with verbose output
./install_flatpaks.sh --verbose

# Run with custom parallel jobs
./install_flatpaks.sh --parallel-jobs 5

# Show help and all options
./install_flatpaks.sh --help

# Combine options
./install_flatpaks.sh --dry-run --verbose --parallel-jobs 3
```

### Interactive Features

The script provides several interactive prompts:

1. **Welcome Screen** - Overview and confirmation to proceed
2. **Storage Check** - Warning if disk space is low with option to continue
3. **Resume Option** - Offer to resume from previous failed installations
4. **Installation Progress** - Real-time progress indicators

## ⚙️ Configuration

### Configuration File Location
```
~/.config/flatpack/config.conf
```

### Default Configuration
```bash
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
CUSTOM_APPS=""                  # Add your own Flatpak application IDs here
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `MAX_RETRIES` | Integer | 3 | Number of retry attempts for failed installations |
| `REQUIRED_SPACE` | Integer | 2000000 | Required disk space in KB (2GB default) |
| `SKIP_ALREADY_INSTALLED` | Boolean | true | Skip applications that are already installed |
| `CREATE_DESKTOP_SHORTCUTS` | Boolean | false | Create desktop shortcuts after installation |
| `PARALLEL_JOBS` | Integer | 1 | Number of concurrent installation jobs |
| `VERBOSE_OUTPUT` | Boolean | false | Show detailed installation output |
| `CUSTOM_APPS` | String | "" | Space-separated list of additional Flatpak IDs to install |

### Environment Variables

You can also override settings using environment variables:
```bash
# Override parallel jobs
PARALLEL_JOBS=5 ./install_flatpaks.sh

# Enable verbose output
VERBOSE_OUTPUT=true ./install_flatpaks.sh

# Skip already installed apps
SKIP_ALREADY_INSTALLED=false ./install_flatpaks.sh
```

## 📱 Applications Included

### 🎮 Gaming Applications
| Application | Flatpak ID | Description |
|-------------|------------|-------------|
| **Lutris** | `net.lutris.Lutris` | Wine game manager - Run Windows games on Linux |
| **Heroic Games Launcher** | `com.heroicgameslauncher.hgl` | Epic Games Store & GOG launcher |
| **Minecraft PE Launcher** | `io.mrarm.mcpelauncher` | Minecraft Pocket Edition launcher |
| **Sober (Roblox)** | `org.vinegarhq.Sober` | Unofficial Roblox client |
| **Vinegar (Roblox Studio)** | `org.vinegarhq.Vinegar` | Unofficial Roblox Studio client |
| **Bazaar** | `io.github.kolunmi.Bazaar` | Game launcher and manager |

### 🎵 Media & Communication
| Application | Flatpak ID | Description |
|-------------|------------|-------------|
| **Discord** | `com.discordapp.Discord` | Gaming communication & voice chat |
| **Spotify** | `com.spotify.Client` | Music streaming service |
| **Emby Theater** | `media.emby.EmbyTheater` | Media center client |

### 🔧 Utilities & Security
| Application | Flatpak ID | Description |
|-------------|------------|-------------|
| **KeePassXC** | `org.keepassxc.KeePassXC` | Secure password manager |
| **Flatseal** | `com.github.tchx84.Flatseal` | Flatpak permissions manager (essential!) |

## 🚀 Advanced Features

### State Management

The script maintains installation state for resumption capability:

```bash
# State file location
~/.local/share/flatpack/install_state.json
```

**Features:**
- Automatic state saving after each installation batch
- Resume from failed installations
- Skip previously successful installations
- Automatic cleanup when all installations complete

### Parallel Processing

Enable parallel installations for faster completion:

```bash
# Install up to 3 applications concurrently
PARALLEL_JOBS=3 ./install_flatpaks.sh
```

**Benefits:**
- Significantly faster installation times
- Better resource utilization
- Intelligent job management
- Real-time progress tracking

### Progress Tracking

The script provides detailed progress information:
- Real-time installation status
- Progress indicators (D=Download, I=Install, R=Resolve, F=Fetch, Δ=Delta)
- Percentage completion when available
- Estimated completion times

### Error Handling

Comprehensive error recovery system:
- Configurable retry attempts
- Detailed error reporting
- Graceful failure handling
- Resume capability for interrupted installations

## 🐛 Troubleshooting

### Common Issues

#### Issue: "Flatpak not found"
```bash
# Install Flatpak first
# Ubuntu/Debian:
sudo apt install flatpak

# Fedora:
sudo dnf install flatpak

# Arch/CachyOS:
sudo pacman -S flatpak
```

#### Issue: "Permission denied"
```bash
# Make script executable
chmod +x install_flatpaks.sh
```

#### Issue: "Insufficient disk space"
```bash
# Check available space
df -h

# Clean up if needed
flatpak uninstall --unused
flatpak repair
```

#### Issue: "Installation failed repeatedly"
```bash
# Try manual installation to identify issue
flatpak install flathub <application-id>

# Update Flatpak
sudo flatpak update

# Refresh repositories
flatpak remote-modify --enable flathub
```

### Debug Mode

Enable verbose output for debugging:
```bash
VERBOSE_OUTPUT=true ./install_flatpaks.sh
```

### Reset Configuration

To reset to default configuration:
```bash
# Remove config file to regenerate defaults
rm ~/.config/flatpack/config.conf
./install_flatpaks.sh
```

### Clear Installation State

To start fresh (ignore previous state):
```bash
# Remove state file
rm ~/.local/share/flatpack/install_state.json
./install_flatpaks.sh
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Reporting Issues
- Use GitHub Issues for bug reports
- Include system information (OS, Flatpak version)
- Provide error messages and logs
- Describe steps to reproduce

### Feature Requests
- Check existing issues first
- Provide detailed description of the feature
- Explain the use case and benefits
- Consider implementation complexity

### Code Contributions
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Application Suggestions
- Suggest new applications via GitHub Issues
- Include Flatpak ID and description
- Explain why it fits the gaming/handheld focus
- Consider security and stability

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 ShadowHarvy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 👨‍💻 Author

**ShadowHarvy**  
*Ex-Hacker & Security Enthusiast*

- 🌐 **Focus**: Security-first automation tools
- 🎮 **Specialty**: Gaming system optimization
- 🔧 **Philosophy**: Intelligent automation with user control
- 🔒 **Approach**: Security and reliability above all

---

## 🌟 Support the Project

If you find this project helpful:

- ⭐ **Star the repository** on GitHub
- 🐛 **Report issues** and suggest improvements
- 🔄 **Share with others** who might benefit
- 💡 **Contribute** new features or bug fixes

---

<div align="center">

**Made with ❤️ for the Linux Gaming Community**

*Optimized for SteamDeck & Bazzite • Inspired by CachyOS & ZSH*

[⬆️ Back to top](#-flatpack-auto-installer-v30)

</div>

---

# 🔄 Flatpack Update Manager (flatpack.py)

## Overview

The **Flatpack Update Manager** is a comprehensive Python script designed to simplify and optimize Flatpak application updates. While the main installer script focuses on initial setup, this update manager provides ongoing maintenance capabilities.

## ✨ Key Features

### 🎯 Smart Update Detection
- **Fast Update Checking**: Uses `--no-deploy` flag to detect updates without downloading
- **Selective Updates**: Only update apps that actually have updates available
- **No False Positives**: Accurate detection prevents unnecessary operations

### 🚀 Update Management
- **Smart Update Mode**: Update only apps that need updating (recommended)
- **Selective Updates**: Update specific applications by ID
- **Bulk Updates**: Update all applications at once
- **Interactive & Non-Interactive**: Choose your preferred update experience

### 🛡️ Safety Features
- **Input Validation**: Validates app IDs before attempting updates
- **Error Handling**: Graceful handling of failed updates
- **Status Reporting**: Clear feedback on update success/failure
- **Dry Run Capability**: Check what updates are available without installing

## 🎮 Usage

### Basic Commands

```bash
# Make the script executable
chmod +x flatpack.py

# Check what apps are installed
./flatpack.py --list

# Check for available updates (recommended first step)
./flatpack.py --check

# Smart update - only update apps that need updates (RECOMMENDED)
./flatpack.py --smart-update
```

### Advanced Commands

```bash
# Update specific applications
./flatpack.py --update --apps com.discord.Discord com.github.tchx84.Flatseal

# Update all apps (may be slow if many apps are already up to date)
./flatpack.py --update

# Interactive mode with prompts
./flatpack.py --smart-update --interactive

# Get detailed help
./flatpack.py --help
```

## 🔧 Command Reference

| Command | Short | Description |
|---------|-------|-------------|
| `--list` | `-l` | List all installed Flatpak applications with details |
| `--check` | `-c` | Check for available updates without installing |
| `--smart-update` | `-s` | Update only apps that have updates available (recommended) |
| `--update` | `-u` | Update applications (all or specified) |
| `--apps APP_ID [...]` | | Specify which apps to update (space-separated) |
| `--interactive` | `-i` | Run in interactive mode with confirmations |
| `--version` | `-v` | Show version information |
| `--help` | `-h` | Show help message and examples |

## 🎯 Recommended Workflow

1. **Check Status**: `./flatpack.py --check`
   - See which apps have updates available
   - Get overview of current installation state

2. **Smart Update**: `./flatpack.py --smart-update`
   - Update only apps that need updating
   - Saves time and bandwidth
   - Most efficient update method

3. **Verify**: `./flatpack.py --check`
   - Confirm all apps are now up to date

## 🔍 Example Scenarios

### Scenario 1: Regular Maintenance
```bash
# Weekly update routine
./flatpack.py --check         # See what needs updating
./flatpack.py --smart-update  # Update only what's needed
```

### Scenario 2: Specific App Updates
```bash
# Update just Discord and Steam
./flatpack.py --update --apps com.discordapp.Discord com.valvesoftware.Steam
```

### Scenario 3: System Administration
```bash
# List all installed apps for inventory
./flatpack.py --list > installed_flatpaks.txt

# Check for updates in a script
./flatpack.py --check && ./flatpack.py --smart-update
```

## 🛠️ Technical Details

### Update Detection Method
The script uses `flatpak update --no-deploy --noninteractive` to detect available updates without downloading or installing anything. This provides:
- Fast detection (no downloads)
- Accurate results (real Flatpak output)
- No system changes during check

### Error Handling
- Validates app IDs against installed applications
- Provides clear error messages for invalid inputs
- Handles network failures gracefully
- Returns appropriate exit codes for scripting

### Performance
- Smart update mode only processes apps that need updates
- Parallel processing where supported by Flatpak
- Minimal resource usage during checks

## 🚀 Integration with Main Installer

The update manager complements the main installation script:
1. Use `install_flatpaks.sh` for initial setup
2. Use `flatpack.py` for ongoing maintenance
3. Both tools work together seamlessly

---

*Flatpack Update Manager - Keeping your Flatpak applications current with intelligence and efficiency.*

---

# 📦 Package Manager Integration (flatpack-pkgmgr)

## Overview

The **Package Manager Integration** provides unified native package management to complement Flatpak applications. It automatically detects your system's package manager and installs essential packages that enhance the overall application ecosystem.

## ✨ Key Features

### 🎯 Multi-Distribution Support
- **Arch Linux**: pacman support with AUR-friendly packages
- **Ubuntu/Debian**: apt support with PPA compatibility  
- **Fedora/RHEL**: dnf support with RPM Fusion packages
- **openSUSE**: zypper support with essential repositories
- **Alpine Linux**: apk support for container environments

### 📦 Package Categories
- **🎮 Gaming Support**: Steam, Lutris, Wine, Vulkan drivers
- **🎵 Media Codecs**: FFmpeg, GStreamer plugins, restricted extras
- **💻 Development Tools**: Git, build tools, Python, Node.js
- **⚙️ System Tools**: Essential utilities and libraries

### 🧠 Smart Features
- **Automatic Detection**: Detects distribution and package manager
- **Duplicate Prevention**: Skips already installed packages
- **Sudo Handling**: Automatically handles permissions
- **Error Recovery**: Graceful handling of installation failures

## 🎮 Usage

### Basic Commands

```bash
# Show system information
./flatpack-pkgmgr --info

# List available package categories
./flatpack-pkgmgr --list

# Install specific categories
./flatpack-pkgmgr --install gaming
./flatpack-pkgmgr --install media system

# Install everything
./flatpack-pkgmgr --install-all
```

### Recommended Integration Workflow

```bash
# Complete system setup workflow
1. ./flatpack-pkgmgr --install-all     # Install native packages
2. ./install_flatpaks.sh                # Install Flatpak apps
3. ./flatpack --smart-update            # Keep apps updated
```

## 🔧 Command Reference

| Command | Short | Description |
|---------|-------|-----------|
| `--info` | `-i` | Show system and package manager information |
| `--list` | `-l` | List available package categories |
| `--install CATEGORY` | | Install packages for specified categories |
| `--install-all` | `-a` | Install all available package categories |
| `--update` | `-u` | Update package database/cache only |
| `--help` | `-h` | Show help message and examples |

## 🎯 Use Case Examples

### Gaming Setup
```bash
./flatpack-pkgmgr --install gaming media system
```

### Development Setup
```bash
./flatpack-pkgmgr --install development system
```

### Complete Desktop Setup
```bash
./flatpack-pkgmgr --install-all
```

## 📊 Distribution Support

| Distribution | Package Manager | Status |
|-------------|----------------|---------|
| Arch Linux | pacman | ✅ Full Support |
| Ubuntu/Debian | apt | ✅ Full Support |
| Fedora/RHEL | dnf | ✅ Full Support |
| openSUSE | zypper | ✅ Full Support |
| Alpine Linux | apk | ⚠️ Limited Support |

---

*Package Manager Integration - Unified native package management for the complete Linux experience.*

---

# 🚀 Flatpack Manager - Unified Interface

## Overview

The **Flatpack Manager** is the ultimate unified interface for the complete Flatpack ecosystem. It provides a single entry point that orchestrates all Flatpack tools, making Linux application management simple and efficient.

## ✨ Key Features

### 🎯 Single Interface
- **One Command**: Complete system setup in a single command
- **Interactive Mode**: User-friendly menu system for guided operations
- **CLI Support**: Full command-line interface for automation
- **Tool Orchestration**: Automatically coordinates all Flatpack components

### 🔄 Complete Workflows
- **System Setup**: End-to-end configuration (native packages + Flatpak apps)
- **Update Management**: Unified updates for all package types
- **Status Monitoring**: Real-time system and tool availability
- **Smart Execution**: Optimal order and dependency handling

## 🎮 Usage

### Quick Start (Recommended)
```bash
# Complete system setup in one command
./flatpack-manager --setup

# This will:
# ✅ Install native packages (gaming, media, dev tools, system utilities)
# ✅ Install curated Flatpak applications
# ✅ Setup system-wide update management
```

### Interactive Mode
```bash
# Launch interactive menu
./flatpack-manager

# Choose from:
# [1] Complete System Setup
# [2] Update Everything  
# [3] Install Native Packages Only
# [4] Install Flatpak Apps Only
# [5] Update Flatpak Apps Only
# [6] Check System Status
```

### Daily Maintenance
```bash
# Keep everything updated
./flatpack-manager --update

# Check system status
./flatpack-manager --status
```

## 🔧 Command Reference

| Command | Description | Components Used |
|---------|-------------|----------------|
| `--setup` | Complete system setup | All tools in optimal order |
| `--update` | Update everything | Native DB + Flatpak smart updates |
| `--status` | System status | Tool availability check |
| `--install-native` | Native packages only | Package manager integration |
| `--install-flatpak` | Flatpak apps only | Flatpak installer |
| `--update-flatpak` | Flatpak updates only | Smart update manager |

## 🎆 Benefits

### 🚀 **Ultimate Simplification**
- **Single Command Setup**: `./flatpack-manager --setup` does everything
- **No Learning Curve**: Interactive menus guide you through options
- **Consistent Interface**: Same commands work across all distributions

### 🧠 **Intelligent Orchestration**
- **Optimal Execution Order**: Native packages → Flatpak apps → Update setup
- **Dependency Handling**: Ensures prerequisites are met automatically
- **Error Recovery**: Continues with other components if one fails

### 🕰️ **Time Saving**
- **Complete Workflows**: Hours of manual setup reduced to minutes
- **Smart Updates**: Only updates what actually needs updating
- **Status Awareness**: Instantly see what's available and working

## 🎥 Real-World Examples

### New Gaming System
```bash
./flatpack-manager --setup
# Result: Complete gaming-optimized system with Steam, Lutris, 
# Discord, media codecs, Vulkan drivers, and curated apps!
```

### Daily Maintenance
```bash
./flatpack-manager --update  
# Result: All native packages and Flatpak apps updated efficiently
```

### Selective Operations
```bash
./flatpack-manager --install-native    # Just install system libraries
./flatpack-manager --update-flatpak     # Just update Flatpak apps
```

## 🌐 Integration Workflow

The manager coordinates the entire Flatpack ecosystem:

1. **Package Manager Integration** → Native system packages
2. **Flatpack Installer** → Curated Flatpak applications  
3. **Update Manager** → Ongoing maintenance
4. **System Integration** → Global availability

**The Flatpack Manager is the crown jewel of the ecosystem** - transforming complex Linux application management into simple, one-command operations.

---

*Flatpack Manager - One interface to manage them all.*
