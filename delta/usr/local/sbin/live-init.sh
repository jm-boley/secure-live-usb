#!/bin/bash
set -euo pipefail

# Source common functions if they exist
[ -f /usr/local/sbin/container-scripts/common.sh ] && source /usr/local/sbin/container-scripts/common.sh

# Enable necessary kernel modules for containers
modprobe overlay
modprobe br_netfilter
modprobe vxlan

# Configure kernel parameters for container networking
sysctl -w net.bridge.bridge-nf-call-iptables=1
sysctl -w net.bridge.bridge-nf-call-ip6tables=1
sysctl -w net.ipv4.ip_forward=1

# Configure resource limits for containers
sysctl -w fs.inotify.max_user_instances=8192
sysctl -w fs.inotify.max_user_watches=524288

# Ensure cgroup v2 is properly mounted
if [ ! -d "/sys/fs/cgroup/unified" ]; then
    mkdir -p /sys/fs/cgroup/unified
    mount -t cgroup2 none /sys/fs/cgroup/unified
fi

# Run container storage initialization
if [ -x /usr/local/sbin/container-scripts/container-storage-init.sh ]; then
    /usr/local/sbin/container-scripts/container-storage-init.sh
fi

# Run user container initialization
if [ -x /usr/local/sbin/container-scripts/user-container-init.sh ]; then
    /usr/local/sbin/container-scripts/user-container-init.sh
fi

exit 0
