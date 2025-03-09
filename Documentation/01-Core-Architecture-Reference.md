# Core Architecture Implementation Reference

This document provides a detailed technical overview of the core architecture in our custom Debian-based distribution.

## Build System Architecture

The build system utilizes live-build with a containerized build environment:

### Build Environment Implementation
**Container Runtime**: 
- Supports both Podman (preferred) and Docker
- Automated environment setup via Dockerfile
- Consistent build environment across platforms
- Volume management for build artifacts

**Build Process Flow**:
1. Container environment initialization
2. Directory structure preparation
3. Configuration application
4. Package selection and installation
5. System customization via overlays
6. ISO image generation

### Directory Structure Implementation
**Core Directories**:
- `overlay-includes.chroot/`: Core system overlay files
- `overlay-config/`: Build-time configuration
    - `archives/`: Repository configurations
    - `hooks/`: Build hook scripts
- `build/`: Output directory for artifacts

## System Configuration Management

The core system uses a layered configuration approach:

### Configuration Layer Implementation
**Base Configuration**:
- Debian live-build base configuration
- Core package selection
- System service defaults
- Network configuration baseline

**Overlay System**:
- File placement during build
- Service configuration
- System defaults
- User environment setup

### Configuration Distribution Strategy
**Configuration System Limitations**:
- Traditional drop-in configuration approaches (e.g., sysctl.d) do not extend to key security systems:
    * AppArmor uses complete policy files rather than composable fragments
    * Python/pip configuration lacks true drop-in support
    * Many security tools require complete, non-mergeable configurations
- Configuration conflicts between variant-specific requirements cannot be resolved through simple overlays

**Template-Based Distribution**:
- Core provides template configurations that variants can adapt:
    * Reference security policies
    * Base configuration structures
    * Documented configuration points
    * Implementation guidelines
- Templates ensure consistency while allowing complete customization
- Each variant maintains its own complete configuration files
- Version control tracks template evolution and variant-specific changes

**Core vs. Variant Responsibilities**:
- Core Implementation:
    * Directory structure specifications
    * Template configurations and examples
    * Documentation of required security measures
    * Common configuration elements
- Variant Implementation:
    * Complete security policies
    * Tool-specific configurations
    * Custom security measures
    * Variant-specific overrides

**Template Implementation**:
- Template Structure:
    * Annotated configuration sections
    * Required vs. optional elements
    * Extension points documentation
    * Version compatibility notes
- Distribution Method:
    * Templates stored in overlay directories
    * Reference implementations included
    * Update mechanism documented
    * Migration paths specified

### Build Hook Implementation
**Hook Categories**:
- Pre-build configuration
- Package installation customization
- Post-installation setup
- System finalization

**Hook Management**:
- Sequential execution
- Error handling
- Logging and verification
- State management

### Package Selection and Management

The system implements a robust package selection strategy that ensures consistent availability of critical components across different environments:

**Package Priority Management**:
- Priority Levels:
    * Required: Core system functionality
    * Important: System reliability
    * Standard: Common tools and utilities
    * Optional: Additional functionality
- Implementation Strategy:
    * Explicit inclusion of security-critical packages regardless of priority
    * Versioning requirements for sensitive components
    * Dependency resolution handling
    * Conflict management between variants

**Core Package Selection Implementation**:
- Selection Criteria:
    * Security relevance
    * Operational necessity
    * Dependency implications
    * Resource impact
- Package List Structure:
    * Categorized by function (core-basic-security.list.chroot, etc.)
    * Documented package purposes
    * Inter-package relationships
    * Version constraints

**Critical Service Management**:
- System Services:
    * Scheduling services (cron, anacron)
    * Security monitoring
    * System maintenance
- Implementation:
    * Explicit package inclusion
    * Service configuration management
    * Dependency handling
    * State preservation

**Base System Integration**:
- Integration Points:
    * Package conflicts resolution
    * Shared dependency management
    * Version compatibility
    * Configuration overlays
- Quality Assurance:
    * Package presence verification
    * Version compatibility checks
    * Configuration validation
    * Service state verification

This comprehensive approach ensures that:
1. Critical security and system maintenance packages are consistently available
2. Package relationships are properly managed
3. System stability is maintained across variants
4. Security requirements are met regardless of base system configuration

## Core Security Features

The base system implements fundamental security measures:

### Kernel Security Configuration
The system implements comprehensive kernel-level security and performance optimizations through sysctl:

**Memory Protection**:
- Address Space Layout Randomization (ASLR)
- Kernel pointer address restrictions
- NULL pointer dereference prevention
- Shared memory segment controls
- OOM kill protection mechanisms

**Filesystem Security**:
- Protected hardlinks and symlinks
- SUID program core dump restrictions
- I/O optimization settings:
    * Inotify watch limits
    * VFS pipe configurations
    * Async I/O request management

**Process and Resource Control**:
- Restricted process tracing (ptrace)
- BPF hardening and restrictions
- Thread and process limits
- System-wide resource boundaries:
    * Message queue sizes
    * Semaphore restrictions
    * Thread maximums
    * Scheduler optimizations

**Network Security**:
- TCP/IP hardening:
    * SYN flood protection
    * Time-wait assassination prevention
    * ICMP redirect restrictions
    * Source routing controls
- Performance optimization:
    * TCP buffer sizing
    * Connection backlogs
    * Socket parameters

**Live Environment Specific**:
- Container and namespace configurations
- Memory management tuning:
    * Cache pressure adjustments
    * Swap behavior optimization
    * Dirty page handling
- I/O optimizations:
    * Overlay filesystem tuning
    * File handle limits
    * Emergency recovery settings

Each configuration category is implemented through separate sysctl configuration files in `/etc/sysctl.d/`, ensuring modularity and maintainability while providing comprehensive system hardening and performance optimization.

### Base Security Implementation
**System Hardening**:
- **Core Security Features**:
- User permission model
- Service access controls
- Resource limitations
- Audit logging

### Device Security Implementation
**Mount Control System**:
- Coordinated security through multiple layers:
    * UDisks2 desktop environment controls
    * udev system-level device handling
    * Boot process safety mechanisms

**Implementation Components**:
- UDisks2 Configuration:
    * Global automount prevention
    * Secure mount options (noexec, nosuid)
    * User interaction requirements
    * Internal device visibility control

- udev Rule Structure:
    * USB storage device handling
    * Removable drive controls
    * Optical media management
    * Flash storage security
    * Boot-time safety checks

**Temporary Storage Security**:
- Systemd Mount Unit Implementation:
    * Hardened /tmp mount options:
        - nodev: Prevent device file creation
        - nosuid: Disable SUID/SGID binaries
        - noexec: Prevent code execution
    * Automatic enforcement through systemd
    * Complements existing mount controls
    * Runtime environment protection

Security Benefits:
- Prevents privilege escalation via SUID/SGID binaries in /tmp
- Blocks creation of malicious device files
- Stops direct execution of downloaded or temporary files
- Reduces attack surface from /tmp-based exploits

### Audit System Implementation
The system implements a resource-conscious audit framework optimized for live environments:

**Core Audit Configuration**:
- **Buffer Management**:
    * Optimized 4096-byte buffer size
    * Incremental async flushing
    * Lossy dispatch quality for memory preservation
    * Increased flush frequency (100) for buffer efficiency

**Log Management Strategy**:
- Storage Optimization:
    * 4MB maximum log file size
    * Two-file rotation system
    * Conservative space thresholds
    * SYSLOG-based warnings
- Resource Protection:
    * Early warning at 50% capacity
    * Administrative alerts at 25% remaining
    * Non-disruptive error handling
    * Disk-error fallback to syslog

**Rule Structure Implementation**:
- High-Priority Monitoring:
    * Authentication events (/etc/shadow, sudoers)
    * Privileged command execution (sudo, su)
    * Kernel module operations
    * Critical system changes
- Resource Impact Considerations:
    * Selective file monitoring
    * Focused execution tracking
    * Essential-only system call auditing
    * Efficient rule organization

**Security Benefits**:
- Protection against:
    * Unauthorized privilege escalation
    * Critical file modifications
    * Kernel module tampering
    * System configuration changes
- Balanced with:
    * Minimal memory footprint
    * Reduced I/O impact
    * Live environment compatibility
    * Resource availability

**Implementation Components**:
- Configuration Distribution:
    * Core rules in overlay-includes.chroot
    * Separate daemon configuration
    * Modular rule organization
    * Built-in resource protections
- Optimization Strategy:
    * Memory-conscious buffer settings
    * Efficient log rotation
    * Minimal disk I/O
    * Performance-focused dispatch

This implementation ensures comprehensive security auditing while maintaining system usability in resource-constrained live environments, supporting both Security and DevOps use cases through carefully balanced configuration choices.

### System-wide Cryptographic Policies

The system enforces standardized cryptographic policies through the crypto-policies framework, which provides consistent cryptographic settings across all supported applications and services.

#### Configuration

- **Policy Level**: DEFAULT
  - Provides a balanced security profile suitable for both Security and DevOps use cases
  - Ensures FIPS-compatible algorithms while maintaining broad compatibility
  - Applies to supported applications including OpenSSH, GnuTLS, OpenSSL, and other crypto backends

#### Implementation

The crypto policy is implemented through:
- Configuration files in `/etc/crypto-policies/`
- Required packages:
  - crypto-policies: Core policy definitions and configurations
  - crypto-policies-scripts: Support scripts for policy management

#### Impact

This system-wide policy ensures:
- Consistent cryptographic security across all supported applications
- Prevention of weak or deprecated cryptographic algorithms
- Automated compliance with security best practices

### Update Management
- Service access controls
- Resource limitations
- Audit logging

**Repository Configuration**:
- Secure repository sources
- Package verification
- Update automation
- Version control

## Bootloader Implementation

The system uses a secure boot process:

### Boot Process Implementation
**GRUB Configuration**:
- Secure boot support
- Boot parameter validation
- Menu customization
- Password protection options

**Initial RAM Disk**:
- Custom initramfs configuration
- Early boot security
- Module management
- Boot process integrity

## Resource Management Implementation

System resources are managed through multiple mechanisms:

### Resource Control Implementation
**Process Management**:
- systemd resource controls
- Process isolation
- CPU allocation
- Memory limits

**Storage Management**:
- Disk space allocation
- Temporary storage controls
- Cache management
- Quota implementation

## Customization and Extension

The core system provides several customization points:

### Extension Points Implementation
**Build-time Customization**:
- Package selection mechanisms
- Configuration override methods
- Hook integration points
- Overlay extension system

**Runtime Configuration**:
- System service customization
- User environment configuration
- Network setup options
- Security policy adaptation

## Performance Considerations

The core implementation balances security with performance:

### Performance Optimization Implementation
The system balances security with performance through careful tuning:

**Memory Management**:
- Dynamic cache pressure control
- Optimized swap usage
- Dirty page ratio tuning
- Shared memory optimization
- ZRAM Configuration:
    * Adaptive sizing based on system memory:
        - 25% ZRAM for systems with ≤8GB RAM
        - 50% ZRAM for systems with >8GB RAM
    * ZSTD compression for optimal performance
    * Dynamic swappiness tuning:
        - 80 for systems with ≤8GB RAM
        - 100 for systems with >8GB RAM
    * Implemented via hook script for consistent configuration across all variants

**I/O Subsystem**:
- Overlay filesystem optimizations
- Read-ahead tuning
- File handle management
- VFS parameter optimization

**Process Scheduling**:
- Automatic process group management
- Migration cost tuning
- Granularity optimization
- Resource limit balancing

**Network Stack**:
- TCP buffer optimization
- Connection handling tuning
- Backlog management
- Socket parameter optimization

### Resource Management
- **Resource Controls**: Sized for typical workloads while preventing abuse
- **Service Management**: Optimized startup and runtime performance
- **Cache Management**: Efficient use of system resources
- **Build Performance**: Optimized build process with caching

This implementation represents the foundation of our system, providing a secure and efficient base for specialized variants while maintaining flexibility for customization.

