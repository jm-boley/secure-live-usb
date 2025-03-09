# USB Device Override Reference

This document details the USB device override implementation in the DevOps spin, following the hook-based override pattern defined in the core documentation.

## Overview

The USB device override system provides a secure mechanism for DevOps users to temporarily enable restricted USB devices when needed for development tasks. It implements all components of the standard override pattern while adding USB-specific functionality.

## Implementation Details

### Hook Installation

The system is installed via `/overlay-config/hooks/live/0040-configure-usb-override.hook.chroot`, which:

1. Creates the override tool at `/usr/local/sbin/usb-override`
2. Sets up directory structure and permissions
3. Configures systemd cleanup services
4. Installs documentation

### Command Interface

The `usb-override` tool provides the following commands:

```bash
# List USB devices and their override status
sudo usb-override list

# Enable a device for 1 hour (default)
sudo usb-override enable <bus> <device>

# Enable with custom duration (in seconds)
sudo usb-override enable <bus> <device> 7200

# Disable a device before timeout
sudo usb-override disable <bus> <device>
```

### Directory Structure

Following the standard override pattern:

```bash
/usr/local/sbin/
  └── usb-override          # Main executable

/etc/usb-override/          # Persistent configuration (mode 700)
  
/run/usb-override/          # Active session tracking
  └── <bus>_<device>        # Session expiry timestamps

/var/log/usb-override/
  └── audit.log             # Audit trail (mode 640)
```

### Security Implementation

1. Session Management
   - All overrides are temporary
   - Sessions stored in volatile memory
   - Automatic expiration after timeout
   - Boot-time session clearing

2. Access Control
   - Root-only access
   - Protected configuration directory
   - Restricted audit log access

3. Monitoring
   - Comprehensive audit logging
   - Session status tracking
   - Device state visibility

## Integration with Core Security

The override system works in conjunction with core USB security measures:

1. Respects the containerboot safety check
2. Uses udev for device management
3. Maintains core security boundaries
4. Provides explicit override documentation

## Usage Examples

### Development Device Access

```bash
# List available devices
sudo usb-override list

# Enable a development board for 2 hours
sudo usb-override enable 001 004 7200

# Check device status
sudo usb-override list

# Disable when done
sudo usb-override disable 001 004
```

### Audit Review

The audit log at `/var/log/usb-override/audit.log` tracks:
- Enable/disable operations
- Session expirations
- User information
- Timestamps
- Device identifiers

## Related Documentation

- [Override Patterns Reference](../core/Documentation/02-Override-Patterns-Reference.md)
- [Core Architecture Reference](../core/Documentation/01-Core-Architecture-Reference.md)
