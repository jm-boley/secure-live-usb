#!/bin/bash
set -euo pipefail

# Source common functions
source /usr/local/sbin/container-scripts/common.sh

# Default container storage location
DEFAULT_STORAGE="/var/lib/containers"

# Try to find USB storage
USB_MOUNT=$(find_usb_storage || echo "")

if [ -n "$USB_MOUNT" ]; then
    CONTAINER_PATH="$USB_MOUNT/containers"
    echo "USB storage found at $USB_MOUNT, setting up container storage"
    setup_container_storage "$CONTAINER_PATH"
    generate_storage_conf "$CONTAINER_PATH"
else
    echo "No USB storage found, using default storage location"
    setup_container_storage "$DEFAULT_STORAGE"
    generate_storage_conf "$DEFAULT_STORAGE"
fi

# Set appropriate SELinux context if SELinux is enabled
if command -v selinuxenabled >/dev/null 2>&1 && selinuxenabled; then
    chcon -R system_u:object_r:container_var_lib_t:s0 "$CONTAINER_PATH"
fi
