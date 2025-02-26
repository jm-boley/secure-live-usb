# Security Initialization Service Technical Reference

## Overview

The security-init.service implements early-boot security hardening measures and verifies the system's security posture. This systemd service runs exactly once during system initialization, after basic system services are available but before user sessions begin. The service implements a carefully balanced set of security controls that maintain essential security measures while ensuring full functionality for forensics and security analysis tools.

## Service Implementation

### Unit Configuration

The service is implemented as a oneshot systemd unit with strategic security hardening directives:

```ini
[Unit]
Description=Security Initialization Service
DefaultDependencies=no
After=local-fs.target systemd-sysctl.service
Before=multi-user.target display-manager.service
Conflicts=shutdown.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/sbin/security-init.sh

# Security directives
PrivateTmp=yes
ProtectKernelTunables=yes
ProtectControlGroups=yes
LockPersonality=yes
CapabilityBoundingSet=CAP_SYS_ADMIN CAP_SYS_PTRACE CAP_SYS_NICE CAP_NET_ADMIN CAP_DAC_OVERRIDE CAP_SETUID CAP_SETGID CAP_SYS_RAWIO
```

### Security Directive Implementation

The service maintains a minimal but essential set of security directives while ensuring forensics capabilities:

#### Active Security Directives
- `PrivateTmp=yes`: Provides private /tmp directory isolation
- `ProtectKernelTunables=yes`: Prevents modification of kernel parameters
- `ProtectControlGroups=yes`: Prevents modification of cgroup hierarchies
- `LockPersonality=yes`: Prevents switching execution domain

#### Capability Configuration
The CapabilityBoundingSet grants specific capabilities required for forensics analysis:
- `CAP_SYS_ADMIN`: Required for various system administration operations
- `CAP_SYS_PTRACE`: Enables process tracing and memory analysis
- `CAP_SYS_NICE`: Allows priority management for resource-intensive analysis
- `CAP_NET_ADMIN`: Required for network interface and traffic analysis
- `CAP_DAC_OVERRIDE`: Enables forensic access to filesystem objects
- `CAP_SETUID/SETGID`: Required for identity management operations
- `CAP_SYS_RAWIO`: Enables direct hardware access for forensics

### Kernel Module Access

The kernel module protection (`ProtectKernelModules=yes`) directive has been deliberately omitted to support critical forensics functionality:

#### Required Use Cases
- Loading specialized modules for memory capture devices
- Memory analysis and acquisition modules
- Kernel module forensics and rootkit analysis
- Network capture and analysis modules
- Hardware-specific forensics modules

This represents a calculated trade-off between security and forensics capabilities. While unrestricted kernel module access increases the system's attack surface, it is essential for comprehensive forensics analysis. This decision enables critical forensics functionality while relying on other security controls to maintain system integrity.

### Security Design Decisions

Several common security directives have been intentionally omitted to ensure full forensics functionality:

#### Access Control Requirements
- `ProtectSystem`: Forensics tools require comprehensive system access
- `ProtectHome`: Will be replaced by granular ACL-based access control
- `NoNewPrivileges`: Forensics tools require privilege escalation capabilities
- `PrivateDevices`: USB and device access required in Live environment

#### Execution Requirements
- `MemoryDenyWriteExecute`: Analysis tools require executable memory
- `RestrictRealtime`: Timing-sensitive analysis must be permitted
- `RestrictSUIDSGID`: SUID/SGID capabilities needed for certain tools
- `SystemCallArchitectures`: Must support mixed architecture libraries
- `RestrictNamespaces`: Namespace analysis required for container forensics

These exclusions were carefully considered decisions, balancing essential security controls against the practical requirements of forensics tools. The service maintains core protections while enabling comprehensive system analysis capabilities.

### Planned Access Control Implementation

To compensate for the removal of `ProtectHome`, a more granular access control system is planned using:
- ACLs for fine-grained directory access control
- Dedicated 'analysts' group for approved security tool users
- Group-based permissions for sensitive directories
- Default-deny access to /home, /root, and /run/user
- Selective access for specific tools and users

This approach will provide better control over sensitive directory access while maintaining necessary functionality for security analysis tools.

## Boot Sequence Integration

The service activates after basic system initialization but before user-facing services:

1. System Boot → basic.target
2. systemd-sysctl.service (applies sysctl settings)
3. **security-init.service**
4. multi-user.target
5. User sessions and applications

## Security Init Script (security-init.sh)

The initialization script implements runtime security measures:

```bash
set -euo pipefail

# Basic memory security settings
echo 2 > /proc/sys/vm/mmap_rnd_bits
echo 32 > /proc/sys/kernel/randomize_va_space

# Verify mandatory access control
if command -v selinuxenabled >/dev/null && selinuxenabled; then
    echo "SELinux is enabled and enforcing"
elif command -v aa-enabled >/dev/null && aa-enabled; then
    echo "AppArmor is enabled and enforcing"
else
    echo "WARNING: No mandatory access control system detected"
    exit 1
fi

# Verify security sysctls
sysctl -a | grep -E "kernel\.(kptr_restrict|yama|perf_event_paranoid)"

# Additional filesystem security
mount -o remount,nosuid,nodev /tmp
mount -o remount,nosuid,nodev /var/tmp
```

## Capabilities and Restrictions

The service operates with the following capabilities:

- Can modify filesystem mount options
- Can read and verify system security settings
- Can write to specific /proc entries
- Cannot load kernel modules
- Cannot modify most kernel parameters
- Cannot access user home directories
- Cannot create new privileges or capabilities

## Troubleshooting

### Common Issues

1. Service fails to start:
- Verify script exists at `/usr/local/sbin/security-init.sh`
- Check script permissions (should be 0755)
- Review systemd journal: `journalctl -u security-init.service`

2. Security verifications fail:
- Check if SELinux/AppArmor is properly installed
- Verify sysctl settings in `/etc/sysctl.d/`
- Check mount points and options: `mount | grep tmp`

3. Boot process hangs:
- Review service dependencies: `systemctl list-dependencies security-init.service`
- Check if basic.target completed: `systemctl status basic.target`
- Verify no deadlocks with other services

### Logging and Debugging

Monitor service execution:
```bash
# Watch service status
systemctl status security-init.service

# View detailed logs
journalctl -u security-init.service -n 50 --no-pager

# Debug service startup
systemctl list-dependencies --before security-init.service
```

## Integration Notes

- Service requires root privileges
- Coordinates with other security measures like sysctl settings
- Verifies mandatory access control (SELinux/AppArmor)
- Implements additional filesystem security measures
- Runs exactly once per boot
- Fails safely if security requirements not met

