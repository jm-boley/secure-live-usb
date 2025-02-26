#!/bin/bash

# Common functions for container scripts
VALID_FILESYSTEMS="ext4|xfs|btrfs|f2fs"
MOUNT_OPTIONS="rw,noatime,exec"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

is_valid_filesystem() {
    local device="$1"
    local fs_type=$(lsblk -no fstype "$device")
    if echo "$fs_type" | grep -E -q "^($VALID_FILESYSTEMS)$"; then
        return 0
    fi
    return 1
}

is_writable_mount() {
    local mount_point="$1"
    if touch "$mount_point/.container_storage_test" 2>/dev/null; then
        rm -f "$mount_point/.container_storage_test"
        return 0
    fi
    return 1
}

mount_usb_device() {
    local device="$1"
    local mount_point="$2"

    # Create mount point if it doesn't exist
    mkdir -p "$mount_point"

    # Check if already mounted
    if mountpoint -q "$mount_point"; then
        if is_writable_mount "$mount_point"; then
            log "Device $device already mounted at $mount_point and is writable"
            return 0
        else
            log "Device $device mounted at $mount_point but not writable"
            return 1
        fi
    fi

    # Mount with appropriate options
    if mount -o "$MOUNT_OPTIONS" "$device" "$mount_point"; then
        if is_writable_mount "$mount_point"; then
            log "Successfully mounted $device at $mount_point"
            return 0
        else
            log "Mounted $device at $mount_point but not writable"
            umount "$mount_point" 2>/dev/null
            return 1
        fi
    fi
    return 1
}

find_usb_storage() {
    local mount_base="/mnt/container-storage"
    local selected_device=""
    local mount_point=""

    # Iterate through USB devices
    while read -r dev_name transport; do
        if [ "$transport" = "usb" ]; then
            local device="/dev/$dev_name"
            
            # Skip partitions that are already mounted elsewhere
            if grep -q "^$device " /proc/mounts; then
                continue
            }

            # Check if device has a valid filesystem
            if is_valid_filesystem "$device"; then
                selected_device="$device"
                mount_point="${mount_base}-${dev_name}"
                
                if mount_usb_device "$selected_device" "$mount_point"; then
                    echo "$mount_point"
                    return 0
                fi
            fi
        fi
    done < <(lsblk -rno name,tran)

    log "No suitable USB storage device found"
    return 1
}

setup_container_storage() {
    local storage_path="$1"
    
    if [ ! -d "$storage_path" ]; then
        log "Creating container storage directory structure at $storage_path"
        mkdir -p "$storage_path"/{storage,config}
        chmod 700 "$storage_path"/{storage,config}
    fi

    # Verify storage location is usable
    if ! is_writable_mount "$(dirname "$storage_path")"; then
        log "Storage location $storage_path is not writable"
        return 1
    fi
}

generate_storage_conf() {
    local storage_path="$1"
    log "Generating storage configuration at $storage_path/config/storage.conf"
    
    cat << CONF > "$storage_path/config/storage.conf"
[storage]
driver = "overlay"
runroot = "/run/containers/storage"
graphroot = "$storage_path/storage"

[storage.options]
mount_program = "/usr/bin/fuse-overlayfs"
size = "10G"

[storage.options.overlay]
mount_program = "/usr/bin/fuse-overlayfs"
mountopt = "nodev,metacopy=on"
CONF
}
