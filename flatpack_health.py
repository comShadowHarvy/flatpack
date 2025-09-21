#!/usr/bin/env python3
"""
Flatpack System Health Monitor

Monitors system health during package operations including disk space,
network connectivity, memory usage, and performance metrics.
"""

import os
import shutil
import subprocess
import time
import threading
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
import json

try:
    import psutil
    HAS_PSUTIL = True
except ImportError:
    HAS_PSUTIL = False

@dataclass
class HealthMetrics:
    """System health metrics at a point in time"""
    timestamp: float
    disk_free_gb: float
    memory_available_gb: float
    memory_used_percent: float
    cpu_percent: float
    load_average: Optional[float]
    network_connected: bool
    flatpak_repo_accessible: bool
    temperature: Optional[Dict[str, float]] = None

class SystemHealthMonitor:
    def __init__(self, config=None):
        self.config = config
        self.monitoring = False
        self.monitor_thread = None
        self.metrics_history = []
        self.max_history = 1000
        
        # Health thresholds
        self.thresholds = {
            'disk_min_gb': self.get_setting('update_behavior.min_free_space_gb', 2.0),
            'memory_max_percent': 90.0,
            'cpu_max_percent': 95.0,
            'temperature_max_celsius': 85.0
        }
    
    def get_setting(self, key: str, default: Any) -> Any:
        """Get setting from config or use default"""
        if self.config:
            return self.config.get(key, default)
        return default
    
    def check_prerequisites(self) -> Dict[str, Any]:
        """Check if system has required tools and libraries"""
        status = {
            'psutil_available': HAS_PSUTIL,
            'flatpak_available': shutil.which('flatpak') is not None,
            'network_tools': shutil.which('ping') is not None,
            'system_monitoring': os.path.exists('/proc/loadavg'),
            'temperature_sensors': self.check_temperature_sensors()
        }
        
        status['overall_ready'] = all([
            status['flatpak_available'],
            status['network_tools'],
            status['system_monitoring']
        ])
        
        return status
    
    def check_temperature_sensors(self) -> bool:
        """Check if temperature sensors are available"""
        if HAS_PSUTIL:
            try:
                temps = psutil.sensors_temperatures()
                return len(temps) > 0
            except:
                pass
        
        # Check for common sensor files
        sensor_paths = [
            '/sys/class/thermal/thermal_zone0/temp',
            '/sys/class/hwmon/hwmon0/temp1_input'
        ]
        
        return any(Path(path).exists() for path in sensor_paths)
    
    def get_current_metrics(self) -> HealthMetrics:
        """Get current system health metrics"""
        
        # Disk space
        try:
            disk_usage = shutil.disk_usage('/')
            disk_free_gb = disk_usage.free / (1024**3)
        except:
            disk_free_gb = 0.0
        
        # Memory and CPU (with psutil if available)
        if HAS_PSUTIL:
            try:
                memory = psutil.virtual_memory()
                memory_available_gb = memory.available / (1024**3)
                memory_used_percent = memory.percent
                cpu_percent = psutil.cpu_percent(interval=0.1)
            except:
                memory_available_gb = 0.0
                memory_used_percent = 0.0
                cpu_percent = 0.0
        else:
            # Fallback methods
            memory_available_gb = self.get_memory_fallback()
            memory_used_percent = 0.0
            cpu_percent = 0.0
        
        # Load average
        load_average = None
        if hasattr(os, 'getloadavg'):
            try:
                load_average = os.getloadavg()[0]
            except:
                pass
        
        # Network connectivity
        network_connected = self.check_network_connectivity()
        
        # Flatpak repository accessibility
        flatpak_repo_accessible = self.check_flatpak_repos()
        
        # Temperature
        temperature = self.get_temperature_readings()
        
        return HealthMetrics(
            timestamp=time.time(),
            disk_free_gb=disk_free_gb,
            memory_available_gb=memory_available_gb,
            memory_used_percent=memory_used_percent,
            cpu_percent=cpu_percent,
            load_average=load_average,
            network_connected=network_connected,
            flatpak_repo_accessible=flatpak_repo_accessible,
            temperature=temperature
        )
    
    def get_memory_fallback(self) -> float:
        """Fallback method to get memory info without psutil"""
        try:
            with open('/proc/meminfo', 'r') as f:
                for line in f:
                    if line.startswith('MemAvailable:'):
                        kb_available = int(line.split()[1])
                        return kb_available / (1024**2)  # Convert to GB
        except:
            pass
        return 0.0
    
    def check_network_connectivity(self) -> bool:
        """Check network connectivity"""
        try:
            # Try to ping a reliable DNS server
            result = subprocess.run(
                ['ping', '-c', '1', '-W', '2', '8.8.8.8'],
                capture_output=True, text=True, timeout=5
            )
            return result.returncode == 0
        except:
            return False
    
    def check_flatpak_repos(self) -> bool:
        """Check if Flatpak repositories are accessible"""
        if not shutil.which('flatpak'):
            return False
        
        try:
            # Try to list remotes (should be fast)
            result = subprocess.run(
                ['flatpak', 'remotes', '--columns=name'],
                capture_output=True, text=True, timeout=10
            )
            return result.returncode == 0 and len(result.stdout.strip()) > 0
        except:
            return False
    
    def get_temperature_readings(self) -> Optional[Dict[str, float]]:
        """Get system temperature readings"""
        temperatures = {}
        
        if HAS_PSUTIL:
            try:
                temps = psutil.sensors_temperatures()
                for name, entries in temps.items():
                    if entries:
                        temperatures[name] = entries[0].current
                return temperatures if temperatures else None
            except:
                pass
        
        # Fallback: read from thermal zones
        try:
            thermal_zones = Path('/sys/class/thermal').glob('thermal_zone*')
            for zone in thermal_zones:
                temp_file = zone / 'temp'
                if temp_file.exists():
                    with open(temp_file, 'r') as f:
                        temp_millicelsius = int(f.read().strip())
                        temp_celsius = temp_millicelsius / 1000.0
                        temperatures[zone.name] = temp_celsius
                        
            return temperatures if temperatures else None
        except:
            return None
    
    def check_health_status(self, metrics: HealthMetrics) -> Dict[str, Any]:
        """Analyze health metrics and return status"""
        issues = []
        warnings = []
        
        # Disk space check
        if metrics.disk_free_gb < self.thresholds['disk_min_gb']:
            issues.append(f"Low disk space: {metrics.disk_free_gb:.1f}GB available")
        elif metrics.disk_free_gb < self.thresholds['disk_min_gb'] * 2:
            warnings.append(f"Disk space getting low: {metrics.disk_free_gb:.1f}GB available")
        
        # Memory check
        if metrics.memory_used_percent > self.thresholds['memory_max_percent']:
            issues.append(f"High memory usage: {metrics.memory_used_percent:.1f}%")
        elif metrics.memory_used_percent > self.thresholds['memory_max_percent'] - 10:
            warnings.append(f"Memory usage elevated: {metrics.memory_used_percent:.1f}%")
        
        # CPU check
        if metrics.cpu_percent > self.thresholds['cpu_max_percent']:
            warnings.append(f"High CPU usage: {metrics.cpu_percent:.1f}%")
        
        # Load average check
        if metrics.load_average and metrics.load_average > 4.0:
            warnings.append(f"High system load: {metrics.load_average:.2f}")
        
        # Temperature check
        if metrics.temperature:
            max_temp = max(metrics.temperature.values())
            if max_temp > self.thresholds['temperature_max_celsius']:
                issues.append(f"High temperature: {max_temp:.1f}°C")
            elif max_temp > self.thresholds['temperature_max_celsius'] - 10:
                warnings.append(f"Temperature elevated: {max_temp:.1f}°C")
        
        # Network connectivity
        if not metrics.network_connected:
            issues.append("No network connectivity")
        
        # Flatpak repos
        if not metrics.flatpak_repo_accessible:
            issues.append("Flatpak repositories not accessible")
        
        health_status = "healthy"
        if issues:
            health_status = "critical" if len(issues) > 2 else "warning"
        elif warnings:
            health_status = "warning"
        
        return {
            'status': health_status,
            'issues': issues,
            'warnings': warnings,
            'metrics': metrics,
            'safe_to_proceed': len(issues) == 0
        }
    
    def start_monitoring(self, interval_seconds: float = 5.0):
        """Start continuous health monitoring"""
        if self.monitoring:
            return
            
        self.monitoring = True
        self.monitor_thread = threading.Thread(
            target=self._monitor_loop,
            args=(interval_seconds,),
            daemon=True
        )
        self.monitor_thread.start()
    
    def stop_monitoring(self):
        """Stop continuous health monitoring"""
        self.monitoring = False
        if self.monitor_thread:
            self.monitor_thread.join(timeout=2.0)
    
    def _monitor_loop(self, interval: float):
        """Main monitoring loop (runs in separate thread)"""
        while self.monitoring:
            try:
                metrics = self.get_current_metrics()
                self.metrics_history.append(metrics)
                
                # Keep only recent history
                if len(self.metrics_history) > self.max_history:
                    self.metrics_history = self.metrics_history[-self.max_history:]
                
                time.sleep(interval)
            except Exception as e:
                print(f"Health monitoring error: {e}")
                time.sleep(interval)
    
    def get_monitoring_summary(self, duration_minutes: int = 10) -> Dict[str, Any]:
        """Get monitoring summary for the last N minutes"""
        if not self.metrics_history:
            return {'error': 'No monitoring data available'}
        
        cutoff_time = time.time() - (duration_minutes * 60)
        recent_metrics = [m for m in self.metrics_history if m.timestamp >= cutoff_time]
        
        if not recent_metrics:
            return {'error': f'No data in the last {duration_minutes} minutes'}
        
        # Calculate averages and trends
        avg_disk_free = sum(m.disk_free_gb for m in recent_metrics) / len(recent_metrics)
        avg_memory_used = sum(m.memory_used_percent for m in recent_metrics) / len(recent_metrics)
        avg_cpu = sum(m.cpu_percent for m in recent_metrics) / len(recent_metrics)
        
        # Network stability
        network_uptime = sum(1 for m in recent_metrics if m.network_connected) / len(recent_metrics) * 100
        
        # Temperature trends
        temp_readings = [m for m in recent_metrics if m.temperature]
        avg_temp = None
        if temp_readings:
            all_temps = []
            for m in temp_readings:
                all_temps.extend(m.temperature.values())
            avg_temp = sum(all_temps) / len(all_temps) if all_temps else None
        
        return {
            'duration_minutes': duration_minutes,
            'sample_count': len(recent_metrics),
            'averages': {
                'disk_free_gb': round(avg_disk_free, 1),
                'memory_used_percent': round(avg_memory_used, 1),
                'cpu_percent': round(avg_cpu, 1),
                'temperature_celsius': round(avg_temp, 1) if avg_temp else None
            },
            'network_uptime_percent': round(network_uptime, 1),
            'latest_status': self.check_health_status(recent_metrics[-1])
        }
    
    def recommend_action(self, health_status: Dict[str, Any]) -> List[str]:
        """Recommend actions based on health status"""
        recommendations = []
        
        for issue in health_status['issues']:
            if 'disk space' in issue.lower():
                recommendations.extend([
                    "Free up disk space before proceeding",
                    "Run 'flatpack cleanup' to remove old packages",
                    "Consider moving large files to external storage"
                ])
            elif 'memory' in issue.lower():
                recommendations.extend([
                    "Close unnecessary applications",
                    "Wait for system load to decrease",
                    "Consider upgrading RAM if this is frequent"
                ])
            elif 'temperature' in issue.lower():
                recommendations.extend([
                    "Allow system to cool down",
                    "Check system cooling/fans",
                    "Reduce concurrent operations"
                ])
            elif 'network' in issue.lower():
                recommendations.extend([
                    "Check network connectivity",
                    "Verify DNS settings",
                    "Try again when network is stable"
                ])
        
        return recommendations
    
    def show_health_report(self):
        """Display comprehensive health report"""
        print("🏥 System Health Report")
        print("=" * 50)
        
        # Prerequisites check
        prereqs = self.check_prerequisites()
        print("System Prerequisites:")
        for key, status in prereqs.items():
            if key == 'overall_ready':
                continue
            icon = "✅" if status else "❌"
            print(f"  {icon} {key.replace('_', ' ').title()}: {status}")
        
        print()
        
        # Current metrics
        current = self.get_current_metrics()
        health_status = self.check_health_status(current)
        
        status_colors = {
            'healthy': '🟢',
            'warning': '🟡', 
            'critical': '🔴'
        }
        
        print(f"Current Status: {status_colors.get(health_status['status'], '⚪')} {health_status['status'].upper()}")
        print()
        
        print("System Metrics:")
        print(f"  💾 Disk Free: {current.disk_free_gb:.1f} GB")
        print(f"  🧠 Memory Available: {current.memory_available_gb:.1f} GB ({current.memory_used_percent:.1f}% used)")
        print(f"  ⚡ CPU Usage: {current.cpu_percent:.1f}%")
        if current.load_average:
            print(f"  📊 Load Average: {current.load_average:.2f}")
        if current.temperature:
            max_temp = max(current.temperature.values())
            print(f"  🌡️  Temperature: {max_temp:.1f}°C")
        print(f"  🌐 Network: {'Connected' if current.network_connected else 'Disconnected'}")
        print(f"  📦 Flatpak Repos: {'Accessible' if current.flatpak_repo_accessible else 'Not accessible'}")
        
        # Issues and warnings
        if health_status['issues']:
            print("\n❗ Critical Issues:")
            for issue in health_status['issues']:
                print(f"  • {issue}")
        
        if health_status['warnings']:
            print("\n⚠️  Warnings:")
            for warning in health_status['warnings']:
                print(f"  • {warning}")
        
        # Recommendations
        if health_status['issues'] or health_status['warnings']:
            recommendations = self.recommend_action(health_status)
            if recommendations:
                print("\n💡 Recommendations:")
                for rec in recommendations[:5]:  # Show top 5
                    print(f"  • {rec}")
        
        # Monitoring summary if available
        if self.metrics_history:
            summary = self.get_monitoring_summary(10)
            if 'averages' in summary:
                print(f"\n📈 10-Minute Averages:")
                avgs = summary['averages']
                print(f"  Disk: {avgs['disk_free_gb']} GB, Memory: {avgs['memory_used_percent']}%, CPU: {avgs['cpu_percent']}%")
                if avgs['temperature_celsius']:
                    print(f"  Temperature: {avgs['temperature_celsius']}°C")
                print(f"  Network Uptime: {summary['network_uptime_percent']}%")
        
        print()
        safe = "✅ SAFE" if health_status['safe_to_proceed'] else "⚠️  PROCEED WITH CAUTION"
        print(f"Package Operations: {safe}")

# Convenience function
def get_health_monitor(config=None) -> SystemHealthMonitor:
    """Get health monitor instance"""
    return SystemHealthMonitor(config)

def quick_health_check(config=None) -> bool:
    """Quick health check - returns True if safe to proceed"""
    monitor = SystemHealthMonitor(config)
    metrics = monitor.get_current_metrics()
    status = monitor.check_health_status(metrics)
    return status['safe_to_proceed']

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Flatpack System Health Monitor")
    parser.add_argument("--report", action="store_true", help="Show health report")
    parser.add_argument("--check", action="store_true", help="Quick health check")
    parser.add_argument("--monitor", type=int, metavar="SECONDS", help="Monitor for N seconds")
    parser.add_argument("--json", action="store_true", help="Output in JSON format")
    
    args = parser.parse_args()
    
    monitor = SystemHealthMonitor()
    
    if args.check:
        metrics = monitor.get_current_metrics()
        status = monitor.check_health_status(metrics)
        
        if args.json:
            print(json.dumps({
                'safe_to_proceed': status['safe_to_proceed'],
                'status': status['status'],
                'issues': status['issues'],
                'warnings': status['warnings']
            }, indent=2))
        else:
            if status['safe_to_proceed']:
                print("✅ System health: OK - Safe to proceed")
            else:
                print("⚠️  System health: Issues detected")
                for issue in status['issues']:
                    print(f"  ❌ {issue}")
    elif args.monitor:
        print(f"Monitoring system health for {args.monitor} seconds...")
        monitor.start_monitoring(1.0)
        time.sleep(args.monitor)
        monitor.stop_monitoring()
        
        summary = monitor.get_monitoring_summary(args.monitor // 60 + 1)
        if args.json:
            print(json.dumps(summary, indent=2))
        else:
            print("Monitoring complete. Final report:")
            monitor.show_health_report()
    else:
        # Default: show health report
        monitor.show_health_report()