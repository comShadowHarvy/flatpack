#!/usr/bin/env python3
"""
Flatpack Logging and Update History System

Provides comprehensive logging, update history tracking, and rollback capabilities.
"""

import logging
import json
import os
import shutil
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict
import hashlib

@dataclass
class UpdateRecord:
    """Represents a single update operation"""
    timestamp: str
    operation: str  # install, update, remove
    package_type: str  # flatpak, native
    packages: List[str]
    success: bool
    duration_seconds: float
    error_message: Optional[str] = None
    system_info: Optional[Dict[str, str]] = None
    rollback_info: Optional[Dict[str, Any]] = None

class FlatpackLogger:
    def __init__(self, config=None):
        self.config = config
        
        # Setup directories
        self.log_dir = Path.home() / '.local' / 'share' / 'flatpack' / 'logs'
        self.history_dir = Path.home() / '.local' / 'share' / 'flatpack' / 'history'
        self.backup_dir = Path.home() / '.local' / 'share' / 'flatpack' / 'backups'
        
        for directory in [self.log_dir, self.history_dir, self.backup_dir]:
            directory.mkdir(parents=True, exist_ok=True)
        
        # Setup logging
        self.setup_logging()
        
        # History file
        self.history_file = self.history_dir / 'update_history.json'
        self.history = self.load_history()
    
    def setup_logging(self):
        """Configure logging with rotation and multiple levels"""
        log_level = getattr(logging, self.get_log_level().upper(), logging.INFO)
        
        # Create formatter
        formatter = logging.Formatter(
            '%(asctime)s | %(levelname)8s | %(name)s | %(message)s'
        )
        
        # Setup main logger
        self.logger = logging.getLogger('flatpack')
        self.logger.setLevel(log_level)
        
        # Clear existing handlers
        self.logger.handlers.clear()
        
        # File handler with rotation
        log_file = self.log_dir / 'flatpack.log'
        file_handler = logging.handlers.RotatingFileHandler(
            log_file, 
            maxBytes=10*1024*1024,  # 10MB
            backupCount=5
        )
        file_handler.setFormatter(formatter)
        file_handler.setLevel(logging.DEBUG)
        self.logger.addHandler(file_handler)
        
        # Console handler
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(logging.Formatter('%(levelname)s: %(message)s'))
        console_handler.setLevel(log_level)
        self.logger.addHandler(console_handler)
        
        # Error file handler
        error_file = self.log_dir / 'flatpack_errors.log'
        error_handler = logging.handlers.RotatingFileHandler(
            error_file,
            maxBytes=5*1024*1024,  # 5MB
            backupCount=3
        )
        error_handler.setFormatter(formatter)
        error_handler.setLevel(logging.ERROR)
        self.logger.addHandler(error_handler)
    
    def get_log_level(self) -> str:
        """Get log level from config or default"""
        if self.config:
            return self.config.get('preferences.log_level', 'info')
        return 'info'
    
    def log_operation_start(self, operation: str, packages: List[str], package_type: str = "flatpak") -> str:
        """Log the start of an operation and return operation ID"""
        operation_id = self.generate_operation_id(operation, packages)
        
        self.logger.info(f"Starting {operation} operation [{operation_id}]")
        self.logger.info(f"Package type: {package_type}")
        self.logger.info(f"Packages ({len(packages)}): {', '.join(packages[:5])}")
        if len(packages) > 5:
            self.logger.info(f"... and {len(packages) - 5} more")
            
        return operation_id
    
    def log_operation_end(self, operation_id: str, success: bool, duration: float, 
                         error_msg: Optional[str] = None):
        """Log the end of an operation"""
        status = "SUCCESS" if success else "FAILED"
        self.logger.info(f"Operation [{operation_id}] completed: {status} ({duration:.2f}s)")
        
        if not success and error_msg:
            self.logger.error(f"Operation [{operation_id}] error: {error_msg}")
    
    def log_package_operation(self, operation: str, package_type: str, packages: List[str],
                            success: bool, duration: float, error_msg: Optional[str] = None,
                            rollback_info: Optional[Dict[str, Any]] = None) -> str:
        """Log a complete package operation and add to history"""
        
        # Create update record
        record = UpdateRecord(
            timestamp=datetime.now().isoformat(),
            operation=operation,
            package_type=package_type,
            packages=packages,
            success=success,
            duration_seconds=duration,
            error_message=error_msg,
            system_info=self.get_system_info(),
            rollback_info=rollback_info
        )
        
        # Add to history
        self.add_to_history(record)
        
        # Log summary
        status = "completed" if success else "failed"
        self.logger.info(f"Package operation {status}: {operation} {len(packages)} {package_type} packages")
        
        return record.timestamp
    
    def generate_operation_id(self, operation: str, packages: List[str]) -> str:
        """Generate unique operation ID"""
        content = f"{operation}_{len(packages)}_{datetime.now().isoformat()}"
        return hashlib.md5(content.encode()).hexdigest()[:8]
    
    def get_system_info(self) -> Dict[str, str]:
        """Get current system information"""
        try:
            import platform
            import psutil
            
            return {
                "os": platform.system(),
                "dist": platform.platform(),
                "python": platform.python_version(),
                "memory_gb": f"{psutil.virtual_memory().total / (1024**3):.1f}",
                "disk_free_gb": f"{psutil.disk_usage('/').free / (1024**3):.1f}",
                "load_avg": str(os.getloadavg()[0]) if hasattr(os, 'getloadavg') else "N/A"
            }
        except Exception as e:
            self.logger.warning(f"Could not get system info: {e}")
            return {"error": str(e)}
    
    def load_history(self) -> List[UpdateRecord]:
        """Load update history from file"""
        if not self.history_file.exists():
            return []
        
        try:
            with open(self.history_file, 'r') as f:
                data = json.load(f)
                return [UpdateRecord(**record) for record in data]
        except (json.JSONDecodeError, TypeError) as e:
            self.logger.error(f"Failed to load history: {e}")
            return []
    
    def save_history(self):
        """Save update history to file"""
        try:
            with open(self.history_file, 'w') as f:
                json.dump([asdict(record) for record in self.history], f, indent=2)
        except Exception as e:
            self.logger.error(f"Failed to save history: {e}")
    
    def add_to_history(self, record: UpdateRecord):
        """Add update record to history"""
        self.history.append(record)
        
        # Keep only last 1000 records
        if len(self.history) > 1000:
            self.history = self.history[-1000:]
        
        self.save_history()
    
    def get_recent_history(self, days: int = 30, package_type: Optional[str] = None) -> List[UpdateRecord]:
        """Get recent update history"""
        cutoff_date = datetime.now() - timedelta(days=days)
        
        recent = []
        for record in self.history:
            try:
                record_date = datetime.fromisoformat(record.timestamp.replace('Z', '+00:00'))
                if record_date >= cutoff_date:
                    if package_type is None or record.package_type == package_type:
                        recent.append(record)
            except ValueError:
                continue
                
        return recent
    
    def get_failed_operations(self, days: int = 7) -> List[UpdateRecord]:
        """Get failed operations from recent history"""
        recent = self.get_recent_history(days)
        return [record for record in recent if not record.success]
    
    def create_backup_point(self, name: str) -> Optional[str]:
        """Create a backup point for potential rollback"""
        backup_id = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{name}"
        backup_path = self.backup_dir / backup_id
        
        try:
            backup_path.mkdir(exist_ok=True)
            
            # Backup flatpak list
            flatpak_result = subprocess.run(
                ['flatpak', 'list', '--columns=application,version,branch,origin'],
                capture_output=True, text=True
            )
            
            if flatpak_result.returncode == 0:
                with open(backup_path / 'flatpaks.txt', 'w') as f:
                    f.write(flatpak_result.stdout)
            
            # Backup native package list (if on Arch/CachyOS)
            if shutil.which('pacman'):
                pacman_result = subprocess.run(
                    ['pacman', '-Q'], capture_output=True, text=True
                )
                if pacman_result.returncode == 0:
                    with open(backup_path / 'native_packages.txt', 'w') as f:
                        f.write(pacman_result.stdout)
            
            # Save backup info
            backup_info = {
                "id": backup_id,
                "name": name,
                "timestamp": datetime.now().isoformat(),
                "system_info": self.get_system_info()
            }
            
            with open(backup_path / 'backup_info.json', 'w') as f:
                json.dump(backup_info, f, indent=2)
            
            self.logger.info(f"Created backup point: {backup_id}")
            return backup_id
            
        except Exception as e:
            self.logger.error(f"Failed to create backup: {e}")
            return None
    
    def list_backups(self) -> List[Dict[str, Any]]:
        """List available backup points"""
        backups = []
        
        for backup_dir in self.backup_dir.iterdir():
            if backup_dir.is_dir():
                info_file = backup_dir / 'backup_info.json'
                if info_file.exists():
                    try:
                        with open(info_file, 'r') as f:
                            backup_info = json.load(f)
                            backups.append(backup_info)
                    except json.JSONDecodeError:
                        continue
        
        # Sort by timestamp, newest first
        backups.sort(key=lambda x: x.get('timestamp', ''), reverse=True)
        return backups
    
    def cleanup_old_logs(self, days: int = 30):
        """Clean up old log files and backups"""
        cutoff_date = datetime.now() - timedelta(days=days)
        
        # Clean old backup points
        for backup_dir in self.backup_dir.iterdir():
            if backup_dir.is_dir():
                try:
                    dir_time = datetime.fromtimestamp(backup_dir.stat().st_mtime)
                    if dir_time < cutoff_date:
                        shutil.rmtree(backup_dir)
                        self.logger.info(f"Cleaned old backup: {backup_dir.name}")
                except Exception as e:
                    self.logger.warning(f"Failed to clean backup {backup_dir.name}: {e}")
        
        # Clean old history entries
        old_count = len(self.history)
        self.history = self.get_recent_history(days)
        if len(self.history) < old_count:
            self.save_history()
            self.logger.info(f"Cleaned {old_count - len(self.history)} old history entries")
    
    def show_statistics(self, days: int = 30):
        """Show operation statistics"""
        recent = self.get_recent_history(days)
        
        if not recent:
            print(f"No operations recorded in the last {days} days")
            return
        
        # Count by operation type
        operations = {}
        package_types = {}
        success_count = 0
        total_duration = 0
        
        for record in recent:
            operations[record.operation] = operations.get(record.operation, 0) + 1
            package_types[record.package_type] = package_types.get(record.package_type, 0) + 1
            if record.success:
                success_count += 1
            total_duration += record.duration_seconds
        
        print(f"📊 Flatpack Statistics (Last {days} days)")
        print("=" * 50)
        print(f"Total operations: {len(recent)}")
        print(f"Success rate: {success_count/len(recent)*100:.1f}%")
        print(f"Average duration: {total_duration/len(recent):.1f}s")
        print()
        
        print("Operations by type:")
        for op, count in operations.items():
            print(f"  {op}: {count}")
        
        print("\nPackage types:")
        for pkg_type, count in package_types.items():
            print(f"  {pkg_type}: {count}")
        
        failed = [r for r in recent if not r.success]
        if failed:
            print(f"\nRecent failures: {len(failed)}")
            for record in failed[-3:]:  # Show last 3 failures
                print(f"  {record.timestamp}: {record.operation} {record.package_type}")

# Convenience function
def get_logger(config=None) -> FlatpackLogger:
    """Get logger instance"""
    return FlatpackLogger(config)

if __name__ == "__main__":
    import subprocess
    import argparse
    
    parser = argparse.ArgumentParser(description="Flatpack Logger Management")
    parser.add_argument("--stats", action="store_true", help="Show statistics")
    parser.add_argument("--backup", metavar="NAME", help="Create backup point")
    parser.add_argument("--list-backups", action="store_true", help="List backup points")
    parser.add_argument("--cleanup", type=int, metavar="DAYS", help="Clean up old logs/backups")
    parser.add_argument("--history", type=int, default=30, metavar="DAYS", help="Show history (default: 30 days)")
    
    args = parser.parse_args()
    
    logger = FlatpackLogger()
    
    if args.stats:
        logger.show_statistics(args.history)
    elif args.backup:
        backup_id = logger.create_backup_point(args.backup)
        if backup_id:
            print(f"Created backup: {backup_id}")
    elif args.list_backups:
        backups = logger.list_backups()
        if backups:
            print("Available backups:")
            for backup in backups:
                print(f"  {backup['id']}: {backup['name']} ({backup['timestamp']})")
        else:
            print("No backups available")
    elif args.cleanup:
        logger.cleanup_old_logs(args.cleanup)
        print(f"Cleaned up files older than {args.cleanup} days")
    else:
        # Show recent history
        history = logger.get_recent_history(args.history)
        if history:
            print(f"Recent operations (last {args.history} days):")
            for record in history[-10:]:  # Show last 10
                status = "✓" if record.success else "✗"
                print(f"  {status} {record.timestamp}: {record.operation} {record.package_type} ({len(record.packages)} packages)")
        else:
            print(f"No operations in the last {args.history} days")