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
