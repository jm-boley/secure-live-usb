find_usb_storage() {
    local VALID_FILESYSTEMS="ext4|xfs|btrfs|f2fs"
    local MOUNT_OPTIONS="rw,noatime,exec"

    for device in $(find /dev -regex '/dev/sd[a-z][0-9]?' -o -regex '/dev/nvme[0-9]n[0-9]p[0-9]?'); do
        # Skip already mounted devices
        if grep -q "^${device} " /proc/mounts; then
            continue
        fi

        # Only consider USB transport devices
        if ! udevadm info --query=property --name="$device" | grep -q "^ID_BUS=usb$"; then
            continue
        fi

        # Get filesystem type
        local fstype=$(blkid -s TYPE -o value "$device")
        if ! echo "$fstype" | grep -qE "^(${VALID_FILESYSTEMS})$"; then
            continue
        fi

        echo "$device"
        return 0
    done

    return 1
}

mount_usb_device() {
    local device="$1"
    if [ -z "$device" ]; then
        return 1
    }

    local mount_point="/mnt/container-storage-${device##*/}"
    if ! mkdir -p "$mount_point"; then
        return 1
    }

    # Ensure proper permissions
    if ! chmod 700 "$mount_point"; then
        rmdir "$mount_point"
        return 1
    }

    if ! mount -o rw,noatime,exec "$device" "$mount_point"; then
        rmdir "$mount_point"
        return 1
    }

    # Verify we can write
    if ! touch "$mount_point/.write_test" 2>/dev/null; then
        umount "$mount_point"
        rmdir "$mount_point"
        return 1
    }
    rm -f "$mount_point/.write_test"

    echo "$mount_point"
    return 0
}

