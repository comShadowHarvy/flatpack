#!/usr/bin/env python3
"""
Flatpack Parallel Operations System

Implements concurrent package operations for faster installs/updates using threading
with intelligent resource management and safety controls.
"""

import threading
import queue
import time
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed, Future
from typing import List, Dict, Any, Optional, Callable, Tuple
from dataclasses import dataclass
from pathlib import Path
import json

@dataclass
class PackageOperation:
    """Represents a single package operation"""
    operation_type: str  # install, update, remove
    package_name: str
    package_manager: str  # flatpak, pacman, etc.
    command: List[str]
    priority: int = 0  # Higher number = higher priority
    dependencies: List[str] = None  # Package names this depends on
    estimated_duration: float = 30.0  # Estimated duration in seconds
    
    def __post_init__(self):
        if self.dependencies is None:
            self.dependencies = []

@dataclass
class OperationResult:
    """Result of a package operation"""
    operation: PackageOperation
    success: bool
    duration: float
    output: str = ""
    error: str = ""
    returncode: int = 0

class ParallelOperationManager:
    def __init__(self, config=None):
        self.config = config
        self.max_workers = self.get_max_workers()
        self.operation_queue = queue.PriorityQueue()
        self.completed_operations = {}
        self.failed_operations = {}
        self.running_operations = {}
        
        # Thread safety
        self.lock = threading.Lock()
        self.results_lock = threading.Lock()
        
        # Statistics
        self.stats = {
            'total_operations': 0,
            'completed_operations': 0,
            'failed_operations': 0,
            'total_duration': 0.0,
            'parallel_efficiency': 0.0
        }
    
    def get_max_workers(self) -> int:
        """Determine optimal number of worker threads"""
        if self.config:
            configured_workers = self.config.get('preferences.max_parallel_jobs', 0)
            if configured_workers > 0:
                return configured_workers
        
        # Auto-detect based on system capabilities
        import os
        cpu_count = os.cpu_count() or 1
        
        # Conservative approach: use fewer workers for package operations
        # as they're often I/O bound and can stress the system
        if cpu_count >= 8:
            return 4
        elif cpu_count >= 4:
            return 3
        elif cpu_count >= 2:
            return 2
        else:
            return 1
    
    def add_operation(self, operation: PackageOperation) -> bool:
        """Add an operation to the queue"""
        try:
            # Use negative priority for max-heap behavior (higher priority first)
            priority = -operation.priority
            self.operation_queue.put((priority, time.time(), operation))
            self.stats['total_operations'] += 1
            return True
        except Exception as e:
            print(f"Failed to add operation {operation.package_name}: {e}")
            return False
    
    def can_execute_operation(self, operation: PackageOperation) -> bool:
        """Check if operation dependencies are satisfied"""
        if not operation.dependencies:
            return True
        
        with self.results_lock:
            for dep in operation.dependencies:
                if dep not in self.completed_operations:
                    return False
                if not self.completed_operations[dep].success:
                    return False
        
        return True
    
    def execute_single_operation(self, operation: PackageOperation) -> OperationResult:
        """Execute a single package operation"""
        start_time = time.time()
        
        try:
            # Mark operation as running
            with self.lock:
                self.running_operations[operation.package_name] = operation
            
            # Execute the command
            result = subprocess.run(
                operation.command,
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout per operation
            )
            
            duration = time.time() - start_time
            
            # Create result
            operation_result = OperationResult(
                operation=operation,
                success=result.returncode == 0,
                duration=duration,
                output=result.stdout,
                error=result.stderr,
                returncode=result.returncode
            )
            
            return operation_result
            
        except subprocess.TimeoutExpired:
            duration = time.time() - start_time
            return OperationResult(
                operation=operation,
                success=False,
                duration=duration,
                error="Operation timed out",
                returncode=-1
            )
        except Exception as e:
            duration = time.time() - start_time
            return OperationResult(
                operation=operation,
                success=False,
                duration=duration,
                error=str(e),
                returncode=-1
            )
        finally:
            # Remove from running operations
            with self.lock:
                self.running_operations.pop(operation.package_name, None)
    
    def process_operation_result(self, result: OperationResult):
        """Process the result of an operation"""
        with self.results_lock:
            if result.success:
                self.completed_operations[result.operation.package_name] = result
                self.stats['completed_operations'] += 1
            else:
                self.failed_operations[result.operation.package_name] = result
                self.stats['failed_operations'] += 1
            
            self.stats['total_duration'] += result.duration
    
    def get_next_ready_operation(self) -> Optional[PackageOperation]:
        """Get the next operation that's ready to execute"""
        temp_operations = []
        next_operation = None
        
        # Look for an operation whose dependencies are satisfied
        while not self.operation_queue.empty():
            try:
                priority, timestamp, operation = self.operation_queue.get_nowait()
                
                if self.can_execute_operation(operation):
                    next_operation = operation
                    break
                else:
                    # Put it back for later
                    temp_operations.append((priority, timestamp, operation))
                    
            except queue.Empty:
                break
        
        # Put back operations that aren't ready
        for item in temp_operations:
            self.operation_queue.put(item)
        
        return next_operation
    
    def execute_operations_batch(self, progress_callback: Optional[Callable] = None) -> Dict[str, Any]:
        """Execute all queued operations in parallel"""
        start_time = time.time()
        
        print(f"Starting parallel execution with {self.max_workers} workers...")
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = {}
            
            while not self.operation_queue.empty() or futures:
                # Submit new operations up to worker limit
                while len(futures) < self.max_workers and not self.operation_queue.empty():
                    operation = self.get_next_ready_operation()
                    if operation:
                        future = executor.submit(self.execute_single_operation, operation)
                        futures[future] = operation
                        print(f"Started: {operation.package_name} ({operation.operation_type})")
                
                # Check for completed operations
                if futures:
                    # Wait for at least one operation to complete
                    completed_futures = []
                    try:
                        for future in as_completed(list(futures.keys()), timeout=1.0):
                            completed_futures.append(future)
                            break
                    except Exception:
                        # No operations completed in timeout, continue
                        pass
                    
                    # Process completed operations
                    for future in completed_futures:
                        operation = futures.pop(future)
                        try:
                            result = future.result()
                            self.process_operation_result(result)
                            
                            status = "✅" if result.success else "❌"
                            print(f"{status} {operation.package_name}: {result.duration:.1f}s")
                            
                            if progress_callback:
                                progress_callback(result)
                                
                        except Exception as e:
                            print(f"❌ {operation.package_name}: Exception - {e}")
                
                # Brief pause to prevent busy waiting
                time.sleep(0.1)
        
        total_duration = time.time() - start_time
        
        # Calculate parallel efficiency
        sequential_duration = sum(op.estimated_duration for _, _, op in list(self.operation_queue.queue))
        if sequential_duration > 0:
            self.stats['parallel_efficiency'] = (sequential_duration / total_duration) * 100
        
        return {
            'total_duration': total_duration,
            'completed': self.stats['completed_operations'],
            'failed': self.stats['failed_operations'],
            'parallel_efficiency': self.stats['parallel_efficiency'],
            'results': {
                'completed': list(self.completed_operations.values()),
                'failed': list(self.failed_operations.values())
            }
        }
    
    def create_flatpak_operations(self, app_ids: List[str], operation_type: str = "update") -> List[PackageOperation]:
        """Create Flatpak operations from app IDs"""
        operations = []
        
        for i, app_id in enumerate(app_ids):
            if operation_type == "update":
                command = ["flatpak", "update", "--noninteractive", app_id]
            elif operation_type == "install":
                command = ["flatpak", "install", "--noninteractive", "flathub", app_id]
            elif operation_type == "remove":
                command = ["flatpak", "remove", "--noninteractive", app_id]
            else:
                continue
            
            operation = PackageOperation(
                operation_type=operation_type,
                package_name=app_id,
                package_manager="flatpak",
                command=command,
                priority=100 - i,  # Earlier in list = higher priority
                estimated_duration=45.0 if operation_type == "install" else 20.0
            )
            operations.append(operation)
        
        return operations
    
    def create_pacman_operations(self, package_names: List[str], operation_type: str = "install") -> List[PackageOperation]:
        """Create pacman operations from package names"""
        operations = []
        
        if operation_type == "install":
            # Group packages for batch installation (more efficient)
            batch_size = 5
            for i in range(0, len(package_names), batch_size):
                batch = package_names[i:i + batch_size]
                command = ["sudo", "pacman", "-S", "--needed", "--noconfirm"] + batch
                
                operation = PackageOperation(
                    operation_type=operation_type,
                    package_name=f"batch_{i//batch_size}_{'+'.join(batch)}",
                    package_manager="pacman",
                    command=command,
                    priority=100 - i,
                    estimated_duration=30.0 * len(batch)
                )
                operations.append(operation)
        else:
            # Individual operations for updates/removes
            for i, package_name in enumerate(package_names):
                if operation_type == "update":
                    command = ["sudo", "pacman", "-S", "--noconfirm", package_name]
                elif operation_type == "remove":
                    command = ["sudo", "pacman", "-R", "--noconfirm", package_name]
                else:
                    continue
                
                operation = PackageOperation(
                    operation_type=operation_type,
                    package_name=package_name,
                    package_manager="pacman",
                    command=command,
                    priority=100 - i,
                    estimated_duration=15.0
                )
                operations.append(operation)
        
        return operations
    
    def get_status(self) -> Dict[str, Any]:
        """Get current status of parallel operations"""
        with self.lock, self.results_lock:
            return {
                'queued_operations': self.operation_queue.qsize(),
                'running_operations': len(self.running_operations),
                'completed_operations': len(self.completed_operations),
                'failed_operations': len(self.failed_operations),
                'running_details': {name: op.operation_type for name, op in self.running_operations.items()},
                'stats': self.stats.copy()
            }

def create_parallel_manager(config=None) -> ParallelOperationManager:
    """Factory function to create a parallel operation manager"""
    return ParallelOperationManager(config)

# Example usage and testing
if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Flatpack Parallel Operations Test")
    parser.add_argument("--test-flatpak", action="store_true", help="Test with dummy Flatpak operations")
    parser.add_argument("--test-pacman", action="store_true", help="Test with dummy pacman operations") 
    parser.add_argument("--workers", type=int, default=0, help="Number of worker threads")
    
    args = parser.parse_args()
    
    # Create manager
    manager = ParallelOperationManager()
    if args.workers > 0:
        manager.max_workers = args.workers
    
    print(f"Parallel Operation Manager (Max workers: {manager.max_workers})")
    print("=" * 50)
    
    if args.test_flatpak:
        # Test with dummy Flatpak operations
        test_apps = [
            "org.mozilla.firefox",
            "org.libreoffice.LibreOffice", 
            "org.gimp.GIMP",
            "org.blender.Blender",
            "com.visualstudio.code"
        ]
        
        operations = manager.create_flatpak_operations(test_apps, "update")
        for op in operations:
            # Replace with harmless test command
            op.command = ["sleep", "2"]  # Simulate 2-second operation
            op.estimated_duration = 2.0
            manager.add_operation(op)
        
        print(f"Added {len(operations)} test Flatpak operations")
        
    elif args.test_pacman:
        # Test with dummy pacman operations
        test_packages = ["git", "curl", "wget", "htop", "neofetch"]
        
        operations = manager.create_pacman_operations(test_packages, "install")
        for op in operations:
            # Replace with harmless test command
            op.command = ["sleep", "3"]  # Simulate 3-second operation
            op.estimated_duration = 3.0
            manager.add_operation(op)
        
        print(f"Added {len(operations)} test pacman operations")
    else:
        print("Use --test-flatpak or --test-pacman to run tests")
        exit(0)
    
    # Execute operations
    def progress_callback(result):
        status = "✅ SUCCESS" if result.success else "❌ FAILED" 
        print(f"  Progress: {result.operation.package_name} - {status}")
    
    results = manager.execute_operations_batch(progress_callback)
    
    print("\n" + "=" * 50)
    print("PARALLEL EXECUTION SUMMARY")
    print("=" * 50)
    print(f"Total Duration: {results['total_duration']:.2f}s")
    print(f"Completed: {results['completed']}")
    print(f"Failed: {results['failed']}")
    print(f"Parallel Efficiency: {results['parallel_efficiency']:.1f}%")
    
    if results['failed'] > 0:
        print("\nFailed Operations:")
        for result in results['results']['failed']:
            print(f"  ❌ {result.operation.package_name}: {result.error}")