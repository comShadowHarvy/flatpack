#!/usr/bin/env python3
"""
Flatpack Plugin/Extension System

Allows custom scripts and extensions to be integrated into the Flatpack ecosystem.
Provides a flexible framework for extending functionality without modifying core code.
"""

import os
import sys
import json
import importlib.util
import subprocess
from pathlib import Path
from typing import Dict, List, Any, Optional, Callable, Union
from dataclasses import dataclass
from abc import ABC, abstractmethod
import traceback

@dataclass
class PluginInfo:
    """Information about a plugin"""
    name: str
    version: str
    description: str
    author: str
    plugin_type: str  # script, python, hook
    entry_point: str  # main function or script path
    dependencies: List[str] = None
    config_schema: Dict[str, Any] = None
    enabled: bool = True
    
    def __post_init__(self):
        if self.dependencies is None:
            self.dependencies = []
        if self.config_schema is None:
            self.config_schema = {}

class PluginBase(ABC):
    """Base class for Python plugins"""
    
    def __init__(self, config: Dict[str, Any] = None):
        self.config = config or {}
        self.logger = None  # Will be injected by plugin manager
    
    @abstractmethod
    def get_info(self) -> PluginInfo:
        """Return plugin information"""
        pass
    
    @abstractmethod
    def initialize(self) -> bool:
        """Initialize the plugin. Return True if successful."""
        pass
    
    def cleanup(self) -> bool:
        """Cleanup plugin resources. Return True if successful."""
        return True
    
    def validate_config(self) -> bool:
        """Validate plugin configuration. Return True if valid."""
        return True

class HookPlugin(PluginBase):
    """Base class for hook-based plugins"""
    
    def get_supported_hooks(self) -> List[str]:
        """Return list of hooks this plugin supports"""
        return []
    
    def execute_hook(self, hook_name: str, context: Dict[str, Any]) -> Dict[str, Any]:
        """Execute a specific hook with given context"""
        return context

class ScriptPlugin:
    """Wrapper for script-based plugins"""
    
    def __init__(self, script_path: Path, info: PluginInfo):
        self.script_path = script_path
        self.info = info
        self.executable = self.detect_interpreter()
    
    def detect_interpreter(self) -> str:
        """Detect the appropriate interpreter for the script"""
        if self.script_path.suffix == '.py':
            return 'python3'
        elif self.script_path.suffix in ['.sh', '.bash']:
            return 'bash'
        elif self.script_path.suffix == '.zsh':
            return 'zsh'
        elif self.script_path.suffix == '.fish':
            return 'fish'
        else:
            # Try to detect from shebang
            try:
                with open(self.script_path, 'r') as f:
                    first_line = f.readline().strip()
                    if first_line.startswith('#!'):
                        return first_line[2:].split()[0]
            except:
                pass
            return 'bash'  # Default fallback
    
    def execute(self, action: str = 'run', args: List[str] = None) -> subprocess.CompletedProcess:
        """Execute the script with given action and arguments"""
        if args is None:
            args = []
        
        cmd = [self.executable, str(self.script_path), action] + args
        
        return subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            cwd=self.script_path.parent
        )

class PluginManager:
    def __init__(self, config=None):
        self.config = config
        self.plugins_dir = self.get_plugins_directory()
        self.loaded_plugins: Dict[str, Union[PluginBase, ScriptPlugin]] = {}
        self.plugin_configs: Dict[str, Dict[str, Any]] = {}
        self.hooks: Dict[str, List[str]] = {}  # hook_name -> [plugin_names]
        
        # Ensure plugins directory exists
        self.plugins_dir.mkdir(parents=True, exist_ok=True)
        
        # Load plugin configurations
        self.load_plugin_configs()
    
    def get_plugins_directory(self) -> Path:
        """Get the plugins directory"""
        if self.config:
            custom_dir = self.config.get('plugins.directory')
            if custom_dir:
                return Path(custom_dir).expanduser()
        
        return Path.home() / '.local' / 'share' / 'flatpack' / 'plugins'
    
    def load_plugin_configs(self):
        """Load plugin configurations from file"""
        config_file = self.plugins_dir / 'plugins.json'
        if config_file.exists():
            try:
                with open(config_file, 'r') as f:
                    self.plugin_configs = json.load(f)
            except json.JSONDecodeError as e:
                print(f"Warning: Invalid plugin config file: {e}")
    
    def save_plugin_configs(self):
        """Save plugin configurations to file"""
        config_file = self.plugins_dir / 'plugins.json'
        try:
            with open(config_file, 'w') as f:
                json.dump(self.plugin_configs, f, indent=2)
        except Exception as e:
            print(f"Error saving plugin configs: {e}")
    
    def discover_plugins(self) -> List[PluginInfo]:
        """Discover available plugins in the plugins directory"""
        discovered = []
        
        for item in self.plugins_dir.iterdir():
            if item.is_dir():
                # Python plugin directory
                plugin_info = self.discover_python_plugin(item)
                if plugin_info:
                    discovered.append(plugin_info)
            elif item.is_file() and item.suffix in ['.py', '.sh', '.bash', '.zsh', '.fish']:
                # Script plugin
                plugin_info = self.discover_script_plugin(item)
                if plugin_info:
                    discovered.append(plugin_info)
        
        return discovered
    
    def discover_python_plugin(self, plugin_dir: Path) -> Optional[PluginInfo]:
        """Discover a Python plugin from its directory"""
        # Look for plugin.json metadata file
        metadata_file = plugin_dir / 'plugin.json'
        if not metadata_file.exists():
            return None
        
        try:
            with open(metadata_file, 'r') as f:
                metadata = json.load(f)
            
            return PluginInfo(**metadata)
            
        except (json.JSONDecodeError, TypeError) as e:
            print(f"Invalid plugin metadata in {plugin_dir}: {e}")
            return None
    
    def discover_script_plugin(self, script_path: Path) -> Optional[PluginInfo]:
        """Discover a script plugin from its file"""
        # Look for metadata in comments at top of file
        try:
            with open(script_path, 'r') as f:
                lines = f.readlines()
            
            metadata = {}
            for line in lines[:20]:  # Check first 20 lines
                line = line.strip()
                if line.startswith('# PLUGIN:'):
                    key, value = line[9:].strip().split(':', 1)
                    metadata[key.strip().lower()] = value.strip()
                elif not line.startswith('#'):
                    break  # Stop at first non-comment line
            
            if 'name' not in metadata:
                return None
            
            return PluginInfo(
                name=metadata.get('name', script_path.stem),
                version=metadata.get('version', '1.0'),
                description=metadata.get('description', ''),
                author=metadata.get('author', 'Unknown'),
                plugin_type='script',
                entry_point=str(script_path)
            )
            
        except Exception as e:
            print(f"Error reading script plugin {script_path}: {e}")
            return None
    
    def load_python_plugin(self, plugin_info: PluginInfo) -> Optional[PluginBase]:
        """Load a Python plugin"""
        plugin_dir = self.plugins_dir / plugin_info.name
        main_file = plugin_dir / plugin_info.entry_point
        
        if not main_file.exists():
            print(f"Plugin entry point not found: {main_file}")
            return None
        
        try:
            # Load the module
            spec = importlib.util.spec_from_file_location(plugin_info.name, main_file)
            if spec is None or spec.loader is None:
                print(f"Could not load plugin spec: {plugin_info.name}")
                return None
            
            module = importlib.util.module_from_spec(spec)
            sys.modules[plugin_info.name] = module
            spec.loader.exec_module(module)
            
            # Get the plugin class
            plugin_class = getattr(module, 'Plugin', None)
            if plugin_class is None:
                print(f"Plugin class not found in {plugin_info.name}")
                return None
            
            # Create plugin instance
            plugin_config = self.plugin_configs.get(plugin_info.name, {})
            plugin = plugin_class(plugin_config)
            
            return plugin
            
        except Exception as e:
            print(f"Error loading Python plugin {plugin_info.name}: {e}")
            traceback.print_exc()
            return None
    
    def load_script_plugin(self, plugin_info: PluginInfo) -> Optional[ScriptPlugin]:
        """Load a script plugin"""
        script_path = Path(plugin_info.entry_point)
        if not script_path.exists():
            print(f"Script plugin not found: {script_path}")
            return None
        
        return ScriptPlugin(script_path, plugin_info)
    
    def load_plugin(self, plugin_info: PluginInfo) -> bool:
        """Load a single plugin"""
        if plugin_info.name in self.loaded_plugins:
            print(f"Plugin {plugin_info.name} already loaded")
            return True
        
        if not plugin_info.enabled:
            print(f"Plugin {plugin_info.name} is disabled")
            return False
        
        plugin = None
        
        if plugin_info.plugin_type == 'python':
            plugin = self.load_python_plugin(plugin_info)
        elif plugin_info.plugin_type == 'script':
            plugin = self.load_script_plugin(plugin_info)
        else:
            print(f"Unknown plugin type: {plugin_info.plugin_type}")
            return False
        
        if plugin is None:
            return False
        
        # Initialize Python plugins
        if isinstance(plugin, PluginBase):
            try:
                if not plugin.initialize():
                    print(f"Plugin {plugin_info.name} initialization failed")
                    return False
                
                # Register hooks for hook plugins
                if isinstance(plugin, HookPlugin):
                    for hook_name in plugin.get_supported_hooks():
                        if hook_name not in self.hooks:
                            self.hooks[hook_name] = []
                        self.hooks[hook_name].append(plugin_info.name)
                        
            except Exception as e:
                print(f"Error initializing plugin {plugin_info.name}: {e}")
                return False
        
        self.loaded_plugins[plugin_info.name] = plugin
        print(f"✅ Loaded plugin: {plugin_info.name} v{plugin_info.version}")
        return True
    
    def load_all_plugins(self) -> int:
        """Load all discovered plugins"""
        discovered = self.discover_plugins()
        loaded_count = 0
        
        print(f"Discovered {len(discovered)} plugins")
        
        for plugin_info in discovered:
            if self.load_plugin(plugin_info):
                loaded_count += 1
        
        print(f"Loaded {loaded_count}/{len(discovered)} plugins")
        return loaded_count
    
    def unload_plugin(self, plugin_name: str) -> bool:
        """Unload a plugin"""
        if plugin_name not in self.loaded_plugins:
            return False
        
        plugin = self.loaded_plugins[plugin_name]
        
        # Cleanup Python plugins
        if isinstance(plugin, PluginBase):
            try:
                plugin.cleanup()
            except Exception as e:
                print(f"Error during plugin cleanup {plugin_name}: {e}")
        
        # Remove from hooks
        for hook_name, plugin_names in self.hooks.items():
            if plugin_name in plugin_names:
                plugin_names.remove(plugin_name)
        
        del self.loaded_plugins[plugin_name]
        print(f"🔄 Unloaded plugin: {plugin_name}")
        return True
    
    def execute_hook(self, hook_name: str, context: Dict[str, Any] = None) -> Dict[str, Any]:
        """Execute all plugins registered for a specific hook"""
        if context is None:
            context = {}
        
        if hook_name not in self.hooks:
            return context
        
        for plugin_name in self.hooks[hook_name]:
            if plugin_name not in self.loaded_plugins:
                continue
            
            plugin = self.loaded_plugins[plugin_name]
            if isinstance(plugin, HookPlugin):
                try:
                    context = plugin.execute_hook(hook_name, context)
                except Exception as e:
                    print(f"Error executing hook {hook_name} in plugin {plugin_name}: {e}")
        
        return context
    
    def execute_script_plugin(self, plugin_name: str, action: str = 'run', args: List[str] = None) -> Optional[subprocess.CompletedProcess]:
        """Execute a script plugin with given action"""
        if plugin_name not in self.loaded_plugins:
            return None
        
        plugin = self.loaded_plugins[plugin_name]
        if not isinstance(plugin, ScriptPlugin):
            return None
        
        try:
            return plugin.execute(action, args)
        except Exception as e:
            print(f"Error executing script plugin {plugin_name}: {e}")
            return None
    
    def list_plugins(self) -> Dict[str, Any]:
        """List all loaded plugins"""
        result = {
            'loaded_plugins': {},
            'available_hooks': list(self.hooks.keys()),
            'plugin_count': len(self.loaded_plugins)
        }
        
        for name, plugin in self.loaded_plugins.items():
            if isinstance(plugin, PluginBase):
                info = plugin.get_info()
                result['loaded_plugins'][name] = {
                    'type': 'python',
                    'version': info.version,
                    'description': info.description,
                    'author': info.author
                }
            elif isinstance(plugin, ScriptPlugin):
                result['loaded_plugins'][name] = {
                    'type': 'script',
                    'version': plugin.info.version,
                    'description': plugin.info.description,
                    'author': plugin.info.author,
                    'interpreter': plugin.executable
                }
        
        return result
    
    def create_sample_plugins(self):
        """Create sample plugins for demonstration"""
        
        # Sample Python plugin
        python_plugin_dir = self.plugins_dir / 'sample_python'
        python_plugin_dir.mkdir(exist_ok=True)
        
        # Plugin metadata
        plugin_json = {
            "name": "sample_python",
            "version": "1.0.0",
            "description": "Sample Python plugin for demonstration",
            "author": "Flatpack",
            "plugin_type": "python",
            "entry_point": "main.py"
        }
        
        with open(python_plugin_dir / 'plugin.json', 'w') as f:
            json.dump(plugin_json, f, indent=2)
        
        # Plugin code
        plugin_code = '''from flatpack_plugins import HookPlugin, PluginInfo

class Plugin(HookPlugin):
    def get_info(self) -> PluginInfo:
        return PluginInfo(
            name="sample_python",
            version="1.0.0",
            description="Sample Python plugin",
            author="Flatpack",
            plugin_type="python",
            entry_point="main.py"
        )
    
    def initialize(self) -> bool:
        print("Sample Python plugin initialized!")
        return True
    
    def get_supported_hooks(self) -> list:
        return ["pre_install", "post_install"]
    
    def execute_hook(self, hook_name: str, context: dict) -> dict:
        print(f"Sample plugin executing hook: {hook_name}")
        context["sample_plugin_executed"] = True
        return context
'''
        
        with open(python_plugin_dir / 'main.py', 'w') as f:
            f.write(plugin_code)
        
        # Sample shell script plugin
        script_plugin = self.plugins_dir / 'sample_script.sh'
        script_content = '''#!/bin/bash
# PLUGIN: name: Sample Script Plugin  
# PLUGIN: version: 1.0.0
# PLUGIN: description: Sample shell script plugin
# PLUGIN: author: Flatpack

echo "🔌 Sample script plugin executed with action: ${1:-run}"

case "${1:-run}" in
    "run")
        echo "Running sample script plugin..."
        ;;
    "install")
        echo "Sample plugin install hook"
        ;;
    "update")
        echo "Sample plugin update hook"
        ;;
    *)
        echo "Unknown action: $1"
        exit 1
        ;;
esac

echo "✅ Sample script plugin completed"
'''
        
        with open(script_plugin, 'w') as f:
            f.write(script_content)
        
        script_plugin.chmod(0o755)
        
        print(f"Created sample plugins in {self.plugins_dir}")

# Convenience function
def get_plugin_manager(config=None) -> PluginManager:
    """Get plugin manager instance"""
    return PluginManager(config)

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Flatpack Plugin Manager")
    parser.add_argument("--discover", action="store_true", help="Discover available plugins")
    parser.add_argument("--load", action="store_true", help="Load all plugins")
    parser.add_argument("--list", action="store_true", help="List loaded plugins")
    parser.add_argument("--create-samples", action="store_true", help="Create sample plugins")
    parser.add_argument("--execute", nargs=2, metavar=("PLUGIN", "ACTION"), help="Execute script plugin")
    parser.add_argument("--hook", nargs=1, metavar="HOOK_NAME", help="Execute hook")
    
    args = parser.parse_args()
    
    manager = PluginManager()
    
    if args.create_samples:
        manager.create_sample_plugins()
        print("Sample plugins created!")
        
    elif args.discover:
        plugins = manager.discover_plugins()
        print(f"Discovered Plugins ({len(plugins)}):")
        for plugin in plugins:
            print(f"  📦 {plugin.name} v{plugin.version} ({plugin.plugin_type})")
            print(f"     {plugin.description}")
            
    elif args.load:
        count = manager.load_all_plugins()
        print(f"Loaded {count} plugins")
        
    elif args.list:
        info = manager.list_plugins()
        print(f"Loaded Plugins ({info['plugin_count']}):")
        for name, details in info['loaded_plugins'].items():
            print(f"  🔌 {name} v{details['version']} ({details['type']})")
            print(f"     {details['description']}")
        
        if info['available_hooks']:
            print(f"\nAvailable Hooks: {', '.join(info['available_hooks'])}")
            
    elif args.execute:
        plugin_name, action = args.execute
        manager.load_all_plugins()  # Ensure plugins are loaded
        result = manager.execute_script_plugin(plugin_name, action)
        if result:
            print(f"Script executed with return code: {result.returncode}")
            if result.stdout:
                print("Output:", result.stdout)
            if result.stderr:
                print("Error:", result.stderr)
        else:
            print(f"Failed to execute plugin: {plugin_name}")
            
    elif args.hook:
        hook_name = args.hook[0]
        manager.load_all_plugins()  # Ensure plugins are loaded
        context = {"test": True}
        result = manager.execute_hook(hook_name, context)
        print(f"Hook {hook_name} executed. Result context: {result}")
        
    else:
        manager.load_all_plugins()
        print("Plugin manager loaded. Use --help for available commands.")