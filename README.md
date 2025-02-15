# Custom Security-Focused Debian Live Build

This project contains configuration files and build scripts for creating a customized Debian-based live distribution focused on DevOps and security tools. Inspired by the comprehensive toolset found in security-focused distributions like ParrotOS, this project builds a lightweight, customized system from the ground up using Debian as its foundation.

## Prerequisites

To build the image, you'll need either:
- Docker
OR
- Podman

No other dependencies are required as all build tools are contained within the builder image.

## Project Structure

```
.
├── .gitignore             # Git exclusions
├── build.sh               # Build automation script
├── delta/                 # Custom system modifications and configurations
├── Dockerfile             # Container definition for build environment
└── build/                 # Main build directory
    ├── auto/               # Build automation scripts
    │   ├── config         # Build configuration
    │   └── build          # Build script
    └── config/            # Live build configuration
        ├── apt/           # APT sources and preferences
        ├── hooks/         # Build hooks
        ├── includes.chroot/# Files to include in image
        └── package-lists/ # Package selection
```

The `build/` directory serves as the main live-build working directory, containing all configuration and automation scripts needed to create the live image. While build artifacts themselves are excluded from version control, the directory structure and configuration files are tracked because they define how the system is constructed.

This directory follows live-build's expected layout, with `auto/` containing build automation and `config/` holding the detailed configuration elements like package lists, hooks, and file overlays. Each subdirectory serves a specific purpose in the live-build process:

- `auto/`: Contains scripts that automate the build process
- `config/`: Holds all configuration elements divided by purpose
- `package-lists/`: Defines what packages are installed
- `hooks/`: Scripts that run at different build stages
- `includes.chroot/`: Files to include in the final system
- `apt/`: APT sources and preferences configuration

**Note**: While build artifacts (ISOs, caches, etc.) are excluded via .gitignore, the configuration within build/ is essential and version controlled. This ensures build reproducibility while keeping the repository size manageable.

## Containerized Build Environment

This project uses a containerized build environment to ensure consistent and reproducible builds across different systems. The build container includes all necessary dependencies and tools (live-build, debootstrap, etc.) preconfigured for building Debian-based live images.

The build process is orchestrated through three main components:
1. The `build.sh` script automates container creation and management, handling:
- Container runtime detection (Podman/Docker)
- Directory mounting and permissions
- Build environment setup
- Volume management for live-build
2. The `Dockerfile` defines the build environment with all required tools
3. The `delta/` directory contains system modifications that get integrated during the build

These components work together to create a reproducible build environment where:
- The container provides isolation and dependency management
- System modifications from delta/ are consistently applied
- The build process is automated and reproducible
- All components are version controlled for consistency

Benefits of the containerized approach:
- Consistent build environment across different systems
- Isolated dependencies that don't affect the host system
- Reproducible builds
- Easy setup without installing multiple system packages
- Versioned build environment that can be tracked with the project

## Build Instructions

1. Clone this repository

2. Build the builder container:
```bash
# The script will automatically use Podman if available, otherwise Docker
./build.sh

# To explicitly use Docker instead of Podman
./build.sh --override-manager Docker
```

The resulting ISO will be created in the `build/` directory.

### Build Script Details

The `build.sh` script handles the container management and build process:

- Automatically detects available container managers (Podman or Docker)
- Defaults to Podman if both are available for better security
- Can be forced to use Docker with `--override-manager Docker` flag
- Creates needed directories automatically
- Handles SELinux contexts when using Podman
- Mounts the delta/ directory as the includes.chroot location for easy customization

Note: The build container requires privileged mode due to the nature of creating filesystem images and handling loop devices during the live image build process.

## System Customization

This project uses Debian live-build's standard customization mechanisms:

### Configuration Structure

- `build/auto/config`: Defines the base configuration and build parameters
- `build/config/includes.chroot/`: Contains files to be copied directly into the live system
- `build/config/hooks/`: Scripts that run during different phases of the build process
- `build/config/package-lists/`: Lists of packages to be installed
- `build/config/apt/`: APT configuration and preferences

### Customization Methods

1. **Package Selection**: Define required packages in package lists
2. **Configuration Files**: Place custom configurations in `build/config/includes.chroot/`
3. **Build Hooks**: Implement custom scripts for complex modifications
4. **APT Sources**: Configure additional repositories as needed

All modifications are version controlled, providing clear tracking of changes and enabling collaborative development.
## Container Configuration and Security

The container runtime system in this distribution provides a secure, user-friendly environment that balances security with usability.

### Storage Management System

Our container storage management implements a flexible, secure storage system:

#### Dynamic Storage Detection
- **USB Storage Priority**: Automatically detects and utilizes available USB storage
- **Fallback Mechanism**: Uses /var/lib/containers when no USB storage is available
- **Filesystem Support**: Compatible with ext4, xfs, btrfs, and f2fs
- **Mount Security**: Implements secure mount options (rw,noatime,exec)

#### Storage Configuration
- **Overlay Storage**: Uses fuse-overlayfs driver for efficient container layering
- **Quota Management**: Implements storage quotas (default: 10GB)
- **Directory Structure**: Automated creation of required storage hierarchy
- **SELinux Integration**: Proper context management for container storage

### User Container Management

The framework provides comprehensive user-level container management:

#### User Setup
- **Automatic Configuration**: Per-user container environment setup
- **Non-System Users**: Targets users with UID >= 1000
- **Configuration Isolation**: User-specific container configurations
- **Rootless Operation**: Default rootless container support via Podman

#### Initialization Process
- **Clean State**: Automatic system reset during initialization
- **Permission Structure**: User-owned configuration directories
- **Configuration Templates**: Standard container configurations per user

### Security Features

The container runtime implements multiple security layers:

#### Access Control
- **Directory Permissions**: Strict 700 permissions for storage
- **SELinux Contexts**: Container-specific security contexts
- **User Isolation**: Separate configurations per user
- **Storage Verification**: Mount point and permission validation

#### Operational Security
- **Rootless Containers**: Non-privileged container operations
- **Storage Isolation**: Separate storage spaces per user
- **Mount Safety**: Verified mount point security
- **Error Handling**: Secure failure handling and logging

### Network Security Considerations

Our distribution implements strict default network isolation for containers to enhance security:

#### Default Network Policy
- **Network Isolation**: Containers have no external network access by default
- **Security-First Design**: Requires explicit action to enable networking
- **Attack Surface Reduction**: Minimizes potential network-based vulnerabilities
- **Data Control**: Prevents unauthorized data exfiltration

#### Enabling Container Networking
When network access is required:
1. Create isolated networks for specific workloads
2. Use host networking tools from within containers when possible
3. Implement proper network namespacing
4. Configure explicit network policies

#### Best Practices
- Enable networking only when absolutely necessary
- Use separate networks for different container groups
- Implement proper network isolation between containers
- Monitor and log container network activity
- Regularly audit container network configurations

## Git Workflow

This repository tracks only configuration files and scripts. Build artifacts and the source image are excluded via .gitignore.

Basic workflow:
1. Create a branch for your changes:
```bash
git checkout -b feature/new-feature
```
2. Make changes to configurations
3. Commit your changes:
```bash
git add -A
git commit -m "Description of changes"
```
4. Push to remote (optional):
```bash
git push origin feature/new-feature
```

For significant changes, use feature branches and merge them back to main once tested.

## Security Hardening

This section details the security measures implemented and planned for our custom Debian-based distribution. Each measure is carefully selected to enhance system security while maintaining usability.
### Kernel and System Hardening

**Status: Partially Implemented**

✓ Implemented Features:
- **Kernel Parameter Hardening** (/etc/sysctl.d/99-security-hardening.conf):
- Network stack protection against common attacks (SYN floods, IP spoofing)
- Restricted IP forwarding and packet redirection
- Disabled core dumps for security-sensitive processes
- Improved memory protection against buffer overflows
- Enhanced file system security controls

⊗ Planned Enhancements:
- AppArmor profile refinements for system services
- Kernel module blacklisting for unused hardware support
- Process scheduling and resource limits optimization
- Boot-time security parameter enforcement

### Authentication and Access Control

**Status: Planned**

⊗ Planned Features:
- Enhanced PAM configuration:
- Strong password requirements using pam_pwquality
- Account lockout after failed attempts
- Password aging and history policies
- Restricted sudo access and command logging
- Session timeout configuration
- USB storage device access controls

### Network Security

**Status: Partially Implemented**

✓ Implemented Features:
- Restrictive default network parameters via sysctl
- TCP/IP stack hardening against common attacks
- Comprehensive NFTables firewall implementation:
- Sophisticated rate limiting for different services
- Anti-scanning protection mechanisms
- TCP flag validation and state enforcement
- Connection tracking and state management
- Comprehensive security event logging
- Protection against common network attacks
- Default-deny policy with explicit allows
- Hardened SSH Client Configuration:
- Modern cryptographic settings:
- Strong ciphers (ChaCha20-Poly1305, AES-GCM)
- Secure MACs with ETM variants
- Modern key exchange algorithms (Curve25519)
- Strict host key verification enforcement
- Public key authentication only
- Disabled agent forwarding
- Disabled X11 forwarding
- Conservative connection timeouts
- Limited connection attempts
- Restrictive forwarding controls
⊗ Planned Enhancements:
- Network monitoring and analysis tools
- Automated intrusion detection
- Network segmentation improvements
### File System and Process Security

**Status: Planned**

⊗ Planned Features:
- Mount options hardening:
- noexec, nosuid, nodev where appropriate
- Separate partitions for /tmp, /var, /home
- File permission reviews and adjustments
- AIDE (Advanced Intrusion Detection Environment) implementation
- Process isolation and resource constraints
- Temporary file security enhancements

### Monitoring and Auditing

**Status: Planned**
#### Planned:
- Auditd configuration:
- System call auditing
- File access monitoring
- Security event logging
- Enhanced logging configuration:
- Remote logging setup
- Log rotation and compression
- Critical event alerting
- Regular system integrity checking
- Security compliance scanning tools
Note: This security configuration balances protection with usability, focusing on hardening measures appropriate for a live system environment. Some features may be configurable at runtime to allow user customization.


## Appendix A: Security Implementation Details

This appendix provides detailed documentation of the security measures implemented in our custom Debian-based distribution.

### Network Security Implementation

Our network security implementation uses nftables with a defense-in-depth approach, combining multiple security mechanisms:

#### Rate Limiting Implementation
- **ICMP Traffic**: Limited to 10 packets per second to prevent ICMP floods while maintaining network diagnostics
- **Standard TCP Services**: 30 connections per minute per source, balancing service availability with DoS protection
- **Critical Services**: 60 connections per minute per source for essential services requiring higher throughput

#### Anti-Scan Protection
- **Port Scan Detection**: Tracks and blocks sources making multiple failed connection attempts
- **Service Probing Protection**: Rate limits on new connection attempts per source IP
- **Connection State Tracking**: Maintains state table for legitimate connections
- **Auto-blacklisting**: Temporary blocks for IPs showing scanning behavior

#### TCP Protocol Security
- **Flag Validation**: Enforces RFC-compliant TCP flag combinations
- **Invalid Flag Detection**: Blocks packets with illegal flag combinations (e.g., SYN+FIN, FIN without ACK)
- **State Tracking**: Validates TCP handshake sequence
- **Anti-Spoofing**: Verifies packet sequences match expected states

#### Connection Tracking
- **State-based Filtering**: Allows only packets belonging to established connections
- **Dynamic State Table**: Adapts to connection volume while preventing state table overflow
- **Timeout Optimization**: Customized timeouts for different protocols and states
- **Invalid State Drop**: Immediate rejection of packets not matching valid state transitions

#### Logging Implementation
- **Security Event Logging**: Records suspicious activity with source details
- **Rate-limited Logging**: Prevents log flooding during attacks
- **Attack Pattern Recognition**: Logs patterns indicating potential attacks
- **Audit Trail**: Maintains detailed records for security analysis

### System Hardening Implementation

Our system hardening measures focus on kernel and system-level security while maintaining usability:

#### Kernel Security Parameters
- **ASLR (Address Space Layout Randomization)**
- Implemented: `kernel.randomize_va_space = 2`
- Rationale: Maximum protection against buffer overflow exploits
- Impact: Negligible performance impact, significant security benefit

- **Restricted Core Dumps**
- Implementation: Disabled for sensitive processes
- Rationale: Prevents exposure of sensitive data in crash dumps
- Trade-off: More challenging debugging, but essential for security

- **Network Stack Hardening**
- TCP SYN cookie protection
- RFC1337 compliance
- Reverse path filtering
- ICMP redirect restrictions
- Rationale: Prevents common network-based attacks

#### File System Security
- **Mount Options**
- noexec on /tmp and temporary storage
- nosuid where appropriate
- nodev restrictions
- Rationale: Prevents execution of malicious code from mounted filesystems

#### Process Isolation
- **Resource Limits**
- Controlled through systemd slices
- Memory, CPU, and I/O restrictions
- Rationale: Prevents resource exhaustion attacks

#### Security vs. Usability Considerations
- **Rate Limiting**: Balanced to prevent abuse while allowing legitimate use
- **Connection Tracking**: Sized for typical workloads while preventing state table floods
- **Resource Controls**: Tuned to allow normal operation while preventing abuse
- **Logging**: Detailed enough for security analysis without overwhelming storage
This implementation demonstrates our commitment to security while maintaining system usability. Each measure is carefully chosen and configured to provide maximum protection with minimal impact on legitimate usage patterns.

