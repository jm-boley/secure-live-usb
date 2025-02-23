# Modular Debian Live Build System

This project provides a framework for building customized Debian-based live distributions with a focus on specialized developer and security workflows. Built on a common core system, it offers distinct specialized "spins" targeting specific use cases:

- **Core System**: A lightweight LXQt desktop with essential system tools and security hardening
- **DevOps Spin**: Extended with container runtime, development tools, and monitoring capabilities
- **Security/Forensics Spin**: Enhanced with security analysis, forensics, and network monitoring tools

Each spin extends the core system with targeted package selections, configurations, and workflow optimizations while maintaining a consistent base architecture.

## Features

### Stock DevOps Toolkit

The built image "ships" with a carefully selected set of DevOps tools, prioritizing security and isolation while maintaining full functionality for development workflows. Visual Studio Code is provided for coding and debugging tasks, while Podman containers provide isolated runtimes for code development and testing environments. Containers may also host specialized applications to perform non-standard development activities, such as Postman for API testing. The git CLI is also provided in addition to VSCode's git management plugin for working with code repositories.

#### Container Runtime (Podman)

Modern development demands container isolation, but security shouldn't be optional. Podman provides a daemonless container engine that puts security first without sacrificing developer productivity. Running containers as your regular user account is the default, ensuring that even a compromised container can't escalate beyond your regular user permissions.

- Rootless Container Operations
    - Zero-trust container execution by default
    - User namespace isolation
    - No privileged daemon process
    - Seamless integration with user services
- Pod and Container Management
    - Native pod support for microservices
    - Docker-compatible CLI interface
    - Built-in container health monitoring
    - Automated container lifecycle management
- System Integration
    - Native systemd service management
    - Socket activation support
    - Unified logging with journald
    - Resource cleanup on service shutdown
- Security Controls
    - SELinux mandatory access control
    - Seccomp system call filtering
    - Fine-grained capability management
    - cgroups v2 resource constraints

#### Development Environment (Visual Studio Code)

** Planned **

#### Version Control (Git)

** Planned **

#### Backup and Recovery Tools

Because "we have backups" and "we have *tested* backups" are two very different statements. Our backup strategy follows the "trust no one, verify everything" philosophy—with a dash of "seriously, verify it again" for good measure. Colonial Pipeline wishes they had been this paranoid.

- Automated Backup Systems
    - restic with encryption-at-rest
    - Immutable snapshot management
    - Multi-target replication
    - Tamper-evident storage
- Recovery Testing
    - Automated restore verification
    - Integrity validation routines
    - Air-gapped backup copies
    - Recovery simulation tools
- State Management
    - Configuration versioning
    - System state snapshots
    - Roll-back capabilities
    - Point-in-time recovery
- Disaster Recovery
    - Documented recovery procedures
    - Offline recovery tools
    - Emergency access protocols
    - Integrity verification chains

#### Terminal Emulator Options

##### Default Terminal
- Modern terminal emulator with full feature set:
    - Split pane support
    - Tab management
    - Command history
    - Shell integration

##### Optional: Warp Terminal
The build script includes optional support for [Warp](https://www.warp.dev), a modern, Rust-based terminal that features GPU acceleration, AI assistance, and collaborative features. 

To include Warp in your build:
```bash
./build.sh --with-warp
```

When enabled, the latest Warp AppImage will be downloaded during the build process and placed in the built image's `/var/lib/warp` directory. Note that Warp:
- Requires a GPU that supports OpenGL 3.3+
- Is currently in beta for Linux
- Requires a free account for basic functionality, and that paid subscriptions are required to unlock full access to LLM assistants
- Is proprietary software (not open source)

The AppImage is downloaded fresh with each build to ensure compliance with Warp's distribution terms.

### Stock Security Toolkit

The distribution comes equipped with a comprehensive suite of security tools, carefully selected to provide a complete security operations workflow while maintaining ease of use. The toolkit spans the full spectrum of security needs, from system hardening and monitoring to incident response and forensics. Core components like AppArmor provide mandatory access control, while specialized tools enable thorough system auditing, network analysis, and threat detection. The toolkit supports both proactive security measures through tools like Lynis and AIDE, as well as reactive capabilities with forensics utilities such as Sleuthkit and dc3dd.

#### System Monitoring and Auditing

Effective system security begins with comprehensive visibility. This toolkit integrates multiple layers of monitoring and auditing capabilities to maintain continuous system observability. From low-level system calls to high-level resource utilization, these tools work in concert to provide a complete picture of system activity and maintain detailed audit trails for security analysis and compliance requirements.

- `auditd` + `audispd-plugins`: System call auditing and plugin framework
    - Captures and logs security-critical system events
    - Maintains tamper-resistant audit trails for compliance
    - Extensible plugin architecture for custom monitoring
    - Configurable rules for focused event capture
- `sysstat`, `iotop`, `htop`, `atop`: System performance monitoring
    - Real-time resource utilization tracking
    - Historical performance trend analysis
    - I/O bottleneck identification
    - Process behavior monitoring
- `logwatch`, `syslog-ng`: Log management and analysis
    - Centralized log aggregation and routing
    - Automated log analysis and reporting
    - Configurable alert thresholds
    - Log integrity verification

#### Intrusion Detection and Prevention

Detecting and kicking out unwelcome snoops who'd love to steal your coding inspirations (and anything else they can get their grubby little mitts on) requires multiple layers of defense. This toolkit combines both signature-based and behavior-based detection methods to create a robust security posture. From file integrity monitoring to sophisticated rootkit detection, these tools work in concert to identify potential compromises. Regular automated scans help ensure system integrity, while real-time monitoring helps catch suspicious activities as they occur.

- `aide`, `rkhunter`, `chkrootkit`: File integrity and rootkit detection
    - AIDE maintains cryptographic checksums of critical system files
    - Detects file modifications, additions, and deletions
    - RKHunter and Chkrootkit provide complementary rootkit scanning
    - Identifies common rootkit signatures and suspicious system modifications
- `tripwire`: File and directory integrity checker
    - Policy-driven integrity monitoring
    - Cryptographically secure database of system state
    - Detailed reporting of file system changes
    - Configurable rules for different security levels
- `unhide`, `tiger`: Process and anomaly detection
    - Identifies hidden processes and ports
    - Detects discrepancies between different system views
    - Tiger performs comprehensive security audits
    - Automated system security status reporting

#### Network Security

Let's face it; your cybersecurity infrastructure is only as good as your ability to detect and respond to the latest threats. This collection of network security tools helps you monitor, control, and secure all traffic flowing through your system. From packet inspection to intrusion detection, these tools work together to keep your network communications locked down tight.

- `nmap`, `netstat`, `ss`: Network scanning and monitoring
    - Comprehensive port and service detection
    - Real-time connection tracking
    - Network topology mapping
    - Service version detection and security assessment
- `tcpdump`, `wireshark`: Network packet analysis
    - Deep packet inspection capabilities
    - Traffic pattern analysis
    - Protocol-specific debugging
    - Network forensics support
- `fail2ban`, `iptables`: Access control and intrusion prevention
    - Automated ban system for malicious actors
    - Customizable firewall rule management
    - Protection against brute force attacks
    - Rate limiting and access control
- `snort`, `suricata`: Network intrusion detection
    - Real-time traffic analysis
    - Threat detection and prevention
    - Protocol analysis
    - Custom rule creation support

## Architecture Overview

The project uses a modular architecture consisting of:

1. **Core System**
- Lightweight LXQt desktop environment
- Essential system utilities
- Basic security hardening
- Common development tools
- Network configuration

2. **Specialized Spins**
- DevOps Environment (`migration/devops/`)
    * Container runtime and orchestration
    * Development environment and IDEs
    * Monitoring and logging tools
    * Performance testing utilities
- Security/Forensics Tools (`migration/security/`)
    * Network security analysis
    * Forensics toolkit
    * Intrusion detection
    * Security monitoring

Each spin extends the core system while maintaining a consistent base architecture and build process.

## Prerequisites

To build any spin image, you'll need either:
- Docker
OR
- Podman

No other dependencies are required as all build tools are contained within the builder image.

## Project Structure

```
project-root/
├── .gitignore                 # Git exclusions
├── build.sh                   # Main build automation script
├── Dockerfile                 # Build environment definition
├── overlay-includes.chroot/   # Core system overlay files
├── overlay-config/            # Core configuration files
│   ├── archives/             # Repository configurations
│   ├── hooks/               # Build hook scripts
│   ├── includes/            # File inclusions
│   └── package-lists/       # Core package selections
├── build/                    # Build workspace
│   ├── auto/               # Build automation
│   └── config/             # Live-build configs
├── Documentation/            # Core documentation
└── migration/               # Specialized spins
    ├── devops/             # DevOps spin
    │   ├── README.md       # DevOps documentation
    │   └── overlay-config/ # DevOps-specific configs
    └── security/           # Security spin
        ├── README.md       # Security documentation
        └── overlay-config/ # Security-specific configs
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
3. The `overlay-includes.chroot/` directory contains system files and configurations that get overlaid into the chroot environment during build

These components work together to create a reproducible build environment where:
- The container provides isolation and dependency management
- System overlays from overlay-includes.chroot/ are consistently applied
- The build process is automated and reproducible
- All components are version controlled for consistency

Benefits of the containerized approach:
- Consistent build environment across different systems
- Isolated dependencies that don't affect the host system
- Reproducible builds
- Easy setup without installing multiple system packages
- Versioned build environment that can be tracked with the project

## Overlay Configuration Management

The `overlay-config/` directory preserves our overlay configurations separate from the build/config directory

### Overlay Configuration Structure

The `overlay-config/` directory contains several subdirectories containing security and DevOps-focused enhancements.
- `archives/`: Contains custom archive configurations
    - VS Code repository configuration (vscode.list.chroot, vscode.key.chroot)

- `hooks/`: Contains custom build hook scripts
    - Custom hooks in live/
        - 0020-configure-zram.hook.chroot: Configures ZRAM for optimized memory management
        - 0100-install-vscode-extensions.chroot: Manages VS Code extension installation
    - Standard hooks from live-build (symlinked from /usr/share/live/build/hooks/)

- `package-lists/`: Defines our custom package selections
    - security.list.chroot: Security-focused tools and packages
    - devops.list.chroot: DevOps and development tools
    - live.list.chroot: Live system specific packages
    - desktop.list.chroot: Desktop environment and applications
    - networking.list.chroot: Network tools and utilities

During the build process, these overlay configurations are copied into the appropriate locations in the build/config directory after running `lb config`. This ensures our configurations are preserved while allowing us to safely regenerate the base configuration as needed.

The `planned/` directory contains specifications and prototype implementations for future enhancements. This includes the TODO.md file detailing planned features and improvements, as well as directories containing preliminary work on specific features that are slated for future integration. This organization helps track and manage the project's planned evolution while keeping work-in-progress separate from the current stable implementation.

Additional placeholder directories are provided for user customizations:

- `apt/`: For custom APT preferences and configurations
    - Add custom APT pinning configurations
    - Configure APT sources and preferences

- `packages.chroot/`: For custom .deb packages
    - Place locally built or custom .deb packages here
    - These will be installed during image build

- `rootfs/`: For custom root filesystem overlays
    - Add files that need to be placed in specific locations
    - Maintains the same directory structure as the target system

- `bootloaders/`: For custom bootloader configurations
    - Custom GRUB configurations
    - Boot splash screen customizations
    - Bootloader theme files

- `includes.chroot/`: For files to be copied into the chroot
    - Files to be included in the final system
    - Maintains target system directory structure

- `includes.binary/`: For files to be copied into the binary image
    - Files needed at boot time
    - Content for the bootable media structure

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
- Mounts the overlay-includes.chroot/ directory as the includes.chroot location for filesystem overlays

Note: The build container requires privileged mode due to the nature of creating filesystem images and handling loop devices during the live image build process.

## System Customization

This project uses Debian live-build's standard customization mechanisms with modifications to accommodate the automation of the build process targeting a customized image.

### Configuration Structure

- `build/auto/config`: Defines the base configuration and build parameters
- `overlay-config/archives`: Contains drop-in non-Debian repository information, including repo addresses and GPG keys
- `overlay-config/hooks`: Contains scripts that are executed during different phases of the build process
- `overlay-config/package-lists/`: Lists of packages to be installed
- `build/config/apt/`: APT configuration and preferences

### Customization Methods

1. **Package Selection**: Define required packages in package lists
2. **Configuration Files**: Place custom configurations in `build/config/includes.chroot/`
3. **Build Hooks**: Implement custom scripts for complex modifications
4. **APT Sources**: Configure additional repositories as needed

All modifications are version controlled, providing clear tracking of changes and enabling collaborative development.

## Network Security Hardening
This distribution implements comprehensive network security measures combining kernel hardening, firewall rules, and nftables-based defense-in-depth mechanisms to protect against common network-based threats:

- Kernel security parameters configured for protection against SYN floods, IP spoofing, and various network-based attacks
- Defense-in-depth network security approach using nftables
- Default-deny firewall policy with targeted allowances for required services
- Multi-layered connection tracking and state validation
- Rate limiting and anti-scan protection mechanisms
- Comprehensive security event logging with flood protection

For detailed technical implementation information, see [Network Hardening Reference](Documentation/01-Network%20Hardening%20Reference.md).
This distribution implements comprehensive network security measures combining kernel hardening, firewall rules, and nftables-based defense-in-depth mechanisms to protect against common network-based threats:

- Kernel security parameters configured for protection against SYN floods, IP spoofing, and various network-based attacks
- Defense-in-depth network security approach using nftables
- Default-deny firewall policy with targeted allowances for required services
- Multi-layered connection tracking and state validation
- Rate limiting and anti-scan protection mechanisms
- Comprehensive security event logging with flood protection

## Container Configuration and Security

The distribution implements a comprehensive container runtime system that prioritizes security while maintaining usability:

- Secure storage implementation using fuse-overlayfs with strict access controls
- User-level container management with automatic environment configuration
- Rootless container operations by default through Podman
- Multi-layered security featuring SELinux integration and strict access controls
- Resource management with quota enforcement and monitoring
- Network isolation by default with controlled access mechanisms
- Comprehensive error handling and security event logging

For detailed technical implementation information, see [Container Security Reference](Documentation/02-Container-Security-Reference.md).
- Regularly audit container network configurations

## Memory Management

This distribution implements an adaptive ZRAM-based memory management system that optimizes memory usage based on available system resources.

### ZRAM Configuration

The system uses a dynamic ZRAM configuration that adapts to the host system's available RAM:

#### Adaptive Sizing Strategy
- **Systems with 8GB RAM or less**:
  - ZRAM Size: 25% of total RAM
  - Swappiness: 80 (conservative)
  - Example (8GB system):
    - Physical RAM: 8GB
    - ZRAM: 2GB
    - Effective additional memory: ~6GB (with compression)

- **Systems with more than 8GB RAM**:
  - ZRAM Size: 50% of total RAM
  - Swappiness: 100 (aggressive)
  - Example (16GB system):
    - Physical RAM: 16GB
    - ZRAM: 8GB
    - Effective additional memory: ~24GB (with compression)

#### Technical Implementation
- **Compression Algorithm**: zstd (optimal balance of speed and compression)
- **Swap Priority**: -10 (ensures ZRAM is used before disk swap)
- **Cache Pressure**: 50 (balanced cache management)
- **Automatic Configuration**: Implemented via systemd service
- **Runtime Detection**: Automatically determines optimal settings at boot

## Build Instructions

Choose which spin to build:

```bash
# Build core system only
./build.sh --core-only

# Build DevOps spin
./build.sh --spin devops

# Build Security spin
./build.sh --spin security
```

The resulting ISO will be created in the `build/` directory.

## Documentation

- [Core System Documentation](Documentation/)
- [DevOps Spin Documentation](migration/devops/README.md)
- [Security Spin Documentation](migration/security/README.md)

## For Contributors

This repository tracks only configuration files and scripts. Build artifacts and the source image are excluded via .gitignore.

When contributing:
1. Determine if your change applies to:
- Core system
- Specific spin
- Build infrastructure
2. Create an appropriately named branch:
```bash
# For core changes
git checkout -b core/feature-name

# For spin-specific changes
git checkout -b spin/devops/feature-name
git checkout -b spin/security/feature-name

# For build system changes
git checkout -b build/feature-name
```

Use pull requests and include testing notes especially for spin-specific changes.
