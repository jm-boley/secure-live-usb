#!/bin/bash
set -euo pipefail

# Source common functions
source /usr/local/sbin/container-scripts/common.sh

# Setup for each non-system user
for user_home in /home/*; do
    if [ -d "$user_home" ]; then
        username=$(basename "$user_home")
        uid=$(id -u "$username" 2>/dev/null || echo "")
        
        if [ -n "$uid" ] && [ "$uid" -ge 1000 ]; then
            echo "Setting up container configuration for user: $username"
            
            # Create user-specific container config directory
            mkdir -p "$user_home/.config/containers"
            chown -R "$username:$username" "$user_home/.config/containers"
            
            # Set default configuration for rootless containers
            su - "$username" -c "podman system reset --force >/dev/null 2>&1 || true"
        fi
    fi
done
