#!/bin/bash

# Enable strict error handling
set -euo pipefail
IFS=$'\n\t'

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a /var/log/security-init.log
}

# Function to verify command existence
require_cmd() {
    command -v "$1" >/dev/null 2>&1 || { log "Error: Required command '$1' not found"; exit 1; }
}

log "Starting security initialization..."

# Verify required commands
required_cmds=(sysctl mount chmod chown find)
for cmd in "${required_cmds[@]}"; do
    require_cmd "$cmd"
done

# Memory security measures
log "Configuring memory protection..."
echo 2 > /proc/sys/vm/panic_on_oom 2>/dev/null || log "Warning: Could not set OOM panic"
echo 1 > /proc/sys/kernel/dmesg_restrict 2>/dev/null || log "Warning: Could not restrict dmesg access"

# Additional filesystem security
log "Applying filesystem security measures..."
mount -o remount,nosuid,nodev /tmp 2>/dev/null || log "Warning: Could not remount /tmp with nosuid,nodev"
mount -o remount,nosuid,nodev /var/tmp 2>/dev/null || log "Warning: Could not remount /var/tmp with nosuid,nodev"

# Find and restrict world-writable directories
log "Securing world-writable paths..."
find /var /tmp /dev /usr /etc -xdev -type d -perm -0002 2>/dev/null | while read -r dir; do
    chmod o-w "$dir" 2>/dev/null || log "Warning: Could not remove world-writable permission from $dir"
done

# Initialize audit if available
if command -v auditctl >/dev/null 2>&1; then
    log "Configuring audit system..."
    # Set basic audit rules
    auditctl -e 1 || log "Warning: Could not enable audit system"
    # Monitor system calls
    auditctl -a always,exit -F arch=b64 -S execve -k exec_commands || log "Warning: Could not set execve audit rule"
    auditctl -a always,exit -F arch=b64 -S mount -k mount_operations || log "Warning: Could not set mount audit rule"
else
    log "Warning: Audit system not available"
fi

# Check for and configure MAC if present
if [ -f /etc/selinux/config ]; then
    log "Verifying SELinux configuration..."
    # Verify SELinux is enforcing
    if grep -q "SELINUX=enforcing" /etc/selinux/config; then
        setenforce 1 2>/dev/null || log "Warning: Could not set SELinux to enforcing"
    fi
elif [ -f /etc/apparmor/parser.conf ]; then
    log "Verifying AppArmor configuration..."
    if command -v aa-enabled >/dev/null 2>&1; then
        aa-enabled --force 2>/dev/null || log "Warning: Could not enable AppArmor"
    fi
fi

# Verify critical security settings
log "Verifying security settings..."
required_settings=(
    "kernel.randomize_va_space=2"
    "kernel.kptr_restrict=2"
    "kernel.yama.ptrace_scope=2"
)

for setting in "${required_settings[@]}"; do
    key="${setting%=*}"
    expected="${setting#*=}"
    actual=$(sysctl -n "$key" 2>/dev/null || echo "NOT_SET")
    if [ "$actual" != "$expected" ]; then
        log "Warning: $key=$actual (expected $expected)"
    fi
done

log "Security initialization completed"
exit 0
