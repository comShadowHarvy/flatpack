# Flatpack v2.1: Advanced Linux Application Management Ecosystem

<div align="center">

![Flatpack Logo](https://img.shields.io/badge/Flatpack-v2.1-blue?style=for-the-badge&logo=linux)
![Version](https://img.shields.io/badge/version-2.1-green?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-yellow?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-Linux-red?style=for-the-badge&logo=linux)

**🚀 Production-Ready Linux Application Management System**

*Comprehensive package management with CachyOS optimizations, system health monitoring, and intelligent automation*

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Configuration](#-configuration) • [CachyOS](#-cachyos-optimizations)

</div>

---

## 🎯 Overview

**Flatpack v2.1** is a comprehensive Linux application management ecosystem that transforms package management from simple updates into an intelligent, monitored, and optimized system. With special optimizations for **CachyOS** and Arch-based systems, it provides enterprise-grade features for both personal and production use.

### 🌟 Key Highlights

- 🔧 **Configuration Management** - Centralized settings with CachyOS auto-detection
- 📊 **System Health Monitoring** - Real-time resource and performance tracking
- 📝 **Advanced Logging** - Complete operation history with rollback capabilities  
- ⚡ **Parallel Operations** - Concurrent package operations for faster execution
- 🔌 **Plugin System** - Extensible architecture for custom functionality
- 🚀 **CachyOS Optimizations** - Performance packages and system tweaks
- 🛡️ **Safety Features** - Health checks and backup systems

---

## ✨ Features

### 🔧 Core Components

| Component | Description | Usage |
|-----------|-------------|-------|
| **Unified Manager** | Central orchestration system | `./flatpack-manager` |
| **Configuration System** | User preferences & system detection | `./flatpack-config --show` |
| **Health Monitor** | System resource monitoring | `./flatpack-health --check` |
| **Logging System** | Operation history & backup points | `./flatpack-logger --stats` |
| **Plugin Manager** | Custom extensions support | `./flatpack-plugins --list` |
| **Package Integration** | Native package management | `./flatpack-pkgmgr` |
| **CachyOS Optimizer** | Performance enhancements | `./flatpack-cachyos` |

### 🚀 Advanced Features

#### **Configuration Management**
- ✅ Automatic CachyOS/Arch detection  
- ✅ User preference management with dot notation access
- ✅ Custom package lists and categories
- ✅ System-specific optimization settings

#### **System Health Monitoring**
- ✅ Real-time resource monitoring (CPU, memory, disk, temperature)
- ✅ Network connectivity and repository accessibility checks
- ✅ Safety checks prevent operations during system stress
- ✅ Performance impact analysis during operations

#### **Advanced Logging & History**
- ✅ Complete operation history with success/failure tracking
- ✅ Backup points for rollback capability
- ✅ Rolling logs with automatic rotation
- ✅ Operation statistics and performance metrics

#### **Parallel Operations**
- ✅ Concurrent package operations for faster execution
- ✅ Intelligent dependency management
- ✅ Resource-aware worker thread allocation
- ✅ Batch processing for optimal performance

#### **Plugin/Extension System**
- ✅ Python and script-based plugins
- ✅ Hook-based architecture for custom functionality
- ✅ Automatic plugin discovery and loading
- ✅ Configuration management for plugins

### 🎯 CachyOS-Specific Benefits

For **CachyOS** users, Flatpack v2.1 provides significant advantages:

#### **Performance Optimization**
- 🚀 Automatic CachyOS detection and optimization
- ⚡ Enhanced pacman configuration with parallel downloads  
- 🎮 Gaming performance packages (gamemode, mangohud, etc.)
- 🔧 System performance monitoring and tuning

#### **Enhanced Package Categories**
- **Performance**: `cachyos-kernel-manager`, `ananicy-cpp`, `preload`, `irqbalance`
- **Gaming**: Enhanced wine support, `dxvk-bin`, `vkd3d`, `gamemode`
- **Media**: `ffmpeg-amd-full`, comprehensive codec support
- **Development**: Optimized compilers and modern development tools

---

## 📥 Installation

### Prerequisites

- **Linux System** (CachyOS, Arch, or any modern distribution)
- **Python 3.7+** for advanced features
- **Flatpak** installed and configured  
- **Internet connection** for downloads

### Quick Installation

```bash
# Clone repository
git clone https://github.com/comShadowHarvy/flatpack.git
cd flatpack

# Make tools executable
chmod +x *.py install_flatpaks.sh

# Initialize configuration (detects CachyOS automatically)
./flatpack-config --init

# Run system health check
./flatpack-health --check

# Complete system setup
./flatpack-manager setup
```

---

## 🎯 Usage

### Basic Commands

```bash
# Unified manager (recommended entry point)
./flatpack-manager                    # Interactive menu
./flatpack-manager setup             # Complete system setup  
./flatpack-manager update            # Update all packages
./flatpack-manager status            # Show system status

# Configuration management  
./flatpack-config --show            # Show current configuration
./flatpack-config --init            # Initialize with defaults
./flatpack-config --set "key" "value"  # Set configuration value

# System health monitoring
./flatpack-health --check           # Quick health check
./flatpack-health --report          # Full health report
./flatpack-health --monitor 60      # Monitor for 60 seconds

# Operation logging and history
./flatpack-logger --stats           # Show operation statistics
./flatpack-logger --history 30      # Show 30-day history
./flatpack-logger --backup "name"   # Create backup point

# Plugin management
./flatpack-plugins --discover       # Discover available plugins
./flatpack-plugins --load           # Load all plugins
./flatpack-plugins --list           # List loaded plugins
```

### Advanced Usage

```bash
# CachyOS optimizations
./flatpack-cachyos                  # Show CachyOS features
python3 cachyos_packages.py         # Generate optimization script

# Parallel operations (testing)
python3 flatpack_parallel.py --test-flatpak --workers 3

# Native package management
./flatpack-pkgmgr --install-all     # Install all categories
./flatpack-pkgmgr --update          # Update native packages
./flatpack-pkgmgr --list-categories # Show package categories

# Legacy Flatpak management
./flatpack.py --check               # Check for updates
./flatpack.py --smart-update        # Update only packages with updates
./flatpack.py --list                # List installed packages
```

---

## ⚙️ Configuration

### Configuration File Location
```
~/.config/flatpack/config.json
```

### Key Configuration Settings

```json
{
  "version": "2.1",
  "distro_info": {
    "detected": "cachyos",
    "is_cachyos": true
  },
  "preferences": {
    "auto_confirm": false,
    "parallel_downloads": true,
    "max_parallel_jobs": 4,
    "interactive_timeouts": 10,
    "log_level": "info"
  },
  "update_behavior": {
    "smart_update_default": true,
    "check_disk_space": true,
    "min_free_space_gb": 2
  },
  "performance": {
    "parallel_operations": true,
    "optimize_for_ssd": true
  }
}
```

### Custom Package Lists

Add your own package categories:

```bash
# Add custom package list
./flatpack-config --set "custom_packages.gaming" '["steam", "lutris"]'

# Enable/disable features
./flatpack-config --set "preferences.parallel_downloads" true
./flatpack-config --set "notifications.desktop_notifications" false
```

---

## 🚀 CachyOS Optimizations

### Automatic Detection

Flatpack automatically detects CachyOS systems and applies optimizations:

```bash
# Check CachyOS detection
./flatpack-config --show

# View CachyOS-specific features  
./flatpack-cachyos
```

### Performance Packages

**CachyOS users get access to:**
- **Kernel Management**: `cachyos-kernel-manager`
- **Process Prioritization**: `ananicy-cpp` 
- **Gaming Performance**: `gamemode`, `mangohud`, `dxvk-bin`
- **System Optimization**: `preload`, `irqbalance`, `thermald`
- **Development Tools**: Optimized compilers and build tools

### System Optimizations

**Automatic optimizations include:**
- Parallel pacman downloads (5 concurrent)
- Enhanced pacman configuration with color and progress
- Kernel parameter tuning for performance
- System service optimization
- SSD-specific optimizations

---

## 📊 Monitoring & Diagnostics

### System Health

```bash
# Quick health check
./flatpack-health --check
# Output: ✅ System health: OK - Safe to proceed

# Comprehensive health report
./flatpack-health --report
```

### Operation History

```bash
# View recent operations
./flatpack-logger --stats

# Create backup before major operations
./flatpack-logger --backup "before-upgrade"

# View detailed history
./flatpack-logger --history 7  # Last 7 days
```

### Performance Analytics

```bash
# View system performance during operations
./flatpack-health --monitor 300  # Monitor for 5 minutes

# Check parallel operation efficiency
python3 flatpack_parallel.py --test-flatpak --workers 4
```

---

## 🔌 Plugin System

### Creating Custom Plugins

#### Script Plugin Example
```bash
#!/bin/bash
# PLUGIN: name: My Custom Plugin
# PLUGIN: version: 1.0.0  
# PLUGIN: description: Custom system tweaks
# PLUGIN: author: Your Name

echo "🔌 Custom plugin executing: ${1:-run}"

case "${1:-run}" in
    "install")
        echo "Running post-install hooks..."
        # Your custom logic here
        ;;
    "update") 
        echo "Running post-update hooks..."
        # Your custom logic here
        ;;
esac
```

#### Python Plugin Example
```python
from flatpack_plugins import HookPlugin, PluginInfo

class Plugin(HookPlugin):
    def get_info(self) -> PluginInfo:
        return PluginInfo(
            name="my_plugin",
            version="1.0.0",
            description="My custom Python plugin",
            author="Your Name",
            plugin_type="python", 
            entry_point="main.py"
        )
    
    def initialize(self) -> bool:
        print("My plugin initialized!")
        return True
    
    def get_supported_hooks(self) -> list:
        return ["pre_install", "post_install"]
    
    def execute_hook(self, hook_name: str, context: dict) -> dict:
        print(f"My plugin executing hook: {hook_name}")
        # Your custom logic here
        return context
```

### Plugin Management

```bash
# Create sample plugins
./flatpack-plugins --create-samples

# Discover and load plugins  
./flatpack-plugins --discover
./flatpack-plugins --load

# Execute plugins
./flatpack-plugins --execute "plugin_name" "action"
./flatpack-plugins --hook "pre_install"
```

---

## 📁 File Structure

```
flatpack/
├── 🔧 Core Tools
│   ├── flatpack-manager.py      # Unified management interface
│   ├── flatpack.py              # Legacy Flatpak update manager
│   ├── install_flatpaks.sh      # Flatpak installer script
│   └── package_manager_integration.py  # Native package management
│
├── 🚀 v2.1 Enhancements  
│   ├── flatpack_config.py       # Configuration management
│   ├── flatpack_health.py       # System health monitoring
│   ├── flatpack_logger.py       # Logging and history
│   ├── flatpack_parallel.py     # Parallel operations
│   ├── flatpack_plugins.py      # Plugin system
│   └── cachyos_packages.py      # CachyOS optimizations
│
├── 🔗 Convenient Symlinks
│   ├── flatpack-manager         # → flatpack-manager.py
│   ├── flatpack-config          # → flatpack_config.py  
│   ├── flatpack-health          # → flatpack_health.py
│   ├── flatpack-logger          # → flatpack_logger.py
│   ├── flatpack-plugins         # → flatpack_plugins.py
│   ├── flatpack-pkgmgr          # → package_manager_integration.py
│   └── flatpack-cachyos          # → cachyos_packages.py
│
└── 📚 Documentation
    ├── README.md                 # This file
    ├── FLATPACK_V2.1_IMPROVEMENTS.md  # Detailed improvements
    ├── UNIFIED_MANAGER.md        # Unified manager documentation  
    ├── PACKAGE_MANAGER_INTEGRATION.md # Native package integration
    └── PROJECT_COMPLETION_SUMMARY.md  # Project overview
```

---

## 🚀 Getting Started with v2.1

### 1. First-Time Setup
```bash
# Clone and setup
git clone https://github.com/comShadowHarvy/flatpack.git
cd flatpack
chmod +x *.py *.sh

# Initialize (auto-detects CachyOS)
./flatpack-config --init
./flatpack-health --check
```

### 2. Complete System Setup
```bash
# One-command setup (installs packages, configures system)
./flatpack-manager setup
```

### 3. Regular Usage  
```bash
# Check system status
./flatpack-manager status

# Update everything  
./flatpack-manager update

# View operation history
./flatpack-logger --stats
```

### 4. CachyOS Users
```bash
# View CachyOS optimizations
./flatpack-cachyos

# Apply performance tweaks  
./flatpack-manager setup  # (includes CachyOS optimizations)
```

---

## 🔍 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **Permission denied** | Run `chmod +x *.py *.sh` to make scripts executable |
| **Python import errors** | Ensure Python 3.7+ is installed |  
| **Health check fails** | Check network connectivity and disk space |
| **CachyOS not detected** | Verify `/etc/os-release` contains `ID=cachyos` |
| **Parallel operations fail** | Reduce worker count or check system resources |

### Diagnostic Commands

```bash
# Check system compatibility
./flatpack-health --report

# Verify configuration  
./flatpack-config --show

# Test parallel operations
python3 flatpack_parallel.py --test-flatpak --workers 2

# Check plugin system
./flatpack-plugins --discover

# View detailed logs
./flatpack-logger --history 1  # Last day
```

### Getting Help

```bash
# Show help for any tool
./flatpack-manager --help
./flatpack-config --help  
./flatpack-health --help
./flatpack-logger --help
```

---

## 🎉 Summary

**Flatpack v2.1** represents a major evolution from a simple Flatpak manager to a comprehensive Linux application management ecosystem:

✅ **Production-Ready**: Enterprise-grade logging, monitoring, and safety features  
✅ **CachyOS Optimized**: Automatic detection and performance enhancements  
✅ **Extensible**: Plugin system for custom functionality  
✅ **Intelligent**: Health monitoring and resource management  
✅ **User-Friendly**: Simple commands with powerful automation  

Whether you're managing a single CachyOS gaming system or deploying across multiple Linux environments, Flatpack v2.1 provides the tools and reliability you need.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

Created and maintained by **ShadowHarvy**

- 🔗 GitHub: [@comShadowHarvy](https://github.com/comShadowHarvy)
- 📧 Email: Contact via GitHub Issues

---

<div align="center">

**⭐ Star this repository if you find it useful!**

**🚀 Flatpack v2.1 - Comprehensive Linux Application Management**

</div>