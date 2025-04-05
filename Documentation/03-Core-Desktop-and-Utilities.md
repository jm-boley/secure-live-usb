# Core Desktop and Utilities Security Baseline

## Overview

This document details the security baseline for desktop components and utilities in the core system. Our approach prioritizes essential security measures while maintaining compatibility with DevOps workflows. More stringent security measures are available in the security spin for high-security environments.

## Design Philosophy

### Balance of Security and Usability

The core system's desktop security follows these principles:
- Implement reasonable defaults that don't impede common DevOps tasks
- Focus on preventing accidental security issues rather than enforcing strict controls
- Maintain user productivity while providing basic security guardrails
- Reserve stricter security measures for the dedicated security spin

### Target Use Cases

The baseline configuration supports:
- Regular development and testing workflows
- Container and virtual machine management
- Local and remote system administration
- Cross-system file operations and networking tasks

## Component Security Configurations

### Display Manager (LightDM)

#### Configuration Location
`/etc/lightdm/lightdm.conf.d/10-core-security.conf`

#### Implementation
```ini
allow-guest=false
greeter-hide-users=false
autologin-user=none
```

#### Rationale
- Disables guest access to prevent unauthorized system use
- Shows user list for easier account switching in DevOps environments
- Disables autologin to ensure basic authentication security

### Desktop Environment (LXQt)

#### Configuration Location
`~/.config/lxqt/session.conf` and `~/.config/lxqt/lxqt-powermanagement.conf`

#### Implementation
```ini
# Session Configuration
lock-screen-before-power-actions=true
screenlock-timeout=1800

# Power Management
enableBatteryWatcher=true
enableIdlenessWatcher=true
idlenessAction=lockScreen
idlenessTimeSecs=1800
```

#### Rationale
- 30-minute screen lock provides basic security without frequent interruptions
- Power action locks prevent unauthorized access during system state changes
- Battery monitoring ensures system availability for mobile workstations

### File Manager (PCManFM-Qt)

#### Configuration Location
`~/.config/pcmanfm-qt/default/settings.conf`

#### Implementation
```ini
ConfirmDelete=true
NoUsbTrash=false
ShowHidden=true
```

#### Rationale
- Delete confirmation prevents accidental file loss
- Normal trash operations maintain familiar workflow
- Hidden file visibility supports development tasks
- USB trash enabled for consistent file operations across devices

### Terminal (QTerminal)

#### Configuration Location
`~/.config/qterminal.org/qterminal.ini`

#### Implementation
```ini
AskOnExit=false
HistoryLimitedTo=1000
```

#### Rationale
- Reasonable history size balances utility with memory usage
- No exit confirmation supports rapid terminal usage
- Default security relies on shell-level controls

### Network Management

#### Configuration Location
`/etc/NetworkManager/conf.d/10-core-security.conf`

#### Implementation
```ini
[device]
wifi.mac-address-randomization=1
connection.auth-retries=3
```

#### Rationale
- Basic MAC randomization provides network privacy
- Reasonable authentication retry limit prevents lockouts
- Balanced for both wireless and wired connections

### Web Browser (Brave)

#### Configuration Location
`/etc/brave/policies/managed/core_policies.json`

#### Implementation
```json
{
  "SafeBrowsingEnabled": true,
  "PasswordManagerEnabled": true,
  "AutoplayAllowed": true,
  "IncognitoModeAvailability": 0
}
```

#### Rationale
- Enables safe browsing for basic web protection
- Allows password management for development tools
- Permits media autoplay for web-based applications
- Enables incognito mode for testing and privacy

## Impact Assessment

### Security Benefits
- Basic protection against common threats
- Reasonable defaults for unattended systems
- Prevention of accidental security issues
- Foundation for additional security measures

### Workflow Compatibility
- Minimal interference with development tasks
- Support for common DevOps tools and practices
- Balanced timeout values for real-world usage
- Flexible file and network operations

### Performance Considerations
- Minimal overhead from security measures
- No significant impact on system resources
- Efficient power management integration
- Optimized for development workstations

## Security Spin Considerations

The core baseline deliberately omits certain security measures that are more appropriate for high-security environments. These stricter controls are implemented in the security spin and include:

- Mandatory user list hiding in LightDM
- Shorter screen lock timeouts (5 minutes)
- Stricter file system controls
- Enhanced terminal security
- Mandatory network security policies
- Restricted browser functionality

For high-security environments, refer to the security spin documentation for enhanced protection measures.

## Maintenance and Updates

The desktop security baseline is maintained through:
- Regular review of security settings
- Updates based on new threat information
- Compatibility testing with development tools
- User feedback integration

Configuration changes should be tested thoroughly to ensure they don't disrupt DevOps workflows while maintaining the intended security benefits.

# Core Desktop and Utilities Reference

This document provides a comprehensive overview of the core tools and capabilities included in the base Live USB environment. The implementation follows a lightweight-first approach while ensuring all necessary functionality for both DevOps and Security operations is available.

## Desktop Environment

The desktop environment is built around LXQt, chosen for its minimal resource footprint while providing a modern desktop experience:

- **Core Desktop Components**
  - LXQt Desktop Environment (lxqt-core)
  - LightDM Display Manager
  - QTerminal for terminal operations
  - PCManFM-Qt file manager
  - LXQt Power Management

- **System Integration**
  - Network Manager Tray (nm-tray)
  - System Monitoring Center
  - Flameshot for screenshots
  - OBS Studio and Peek for screen recording
  - PulseAudio with pavucontrol-qt

## System Security

Basic security tools providing fundamental protection across all variants:

- **System Integrity**
  - AIDE (Advanced Intrusion Detection Environment)
  - Checksecurity for basic system security checks
  - Sysdig for system-level exploration

- **Access Control**
  - ACL utilities for fine-grained access control
  - Auditd for system auditing
  - Crypto-policies for system-wide cryptographic settings

- **Malware Protection**
  - ClamAV antivirus scanner and daemon

## Container Support

Containerization support through Flatpak:

- **Core Components**
  - Flatpak package management
  - XDG Desktop Portal integration
  - Bubblewrap for sandboxing
  - PolicyKit for permissions

## System Monitoring

Comprehensive system observation tools:

- **Process Management**
  - htop (interactive process viewer)
  - iotop (I/O monitoring)
  - strace (system call tracer)
  - lsof (list open files)

- **Resource Monitoring**
  - sysstat suite (iostat, mpstat)
  - System Monitoring Center
  - Neofetch and inxi for system information

## Network Tools

Network diagnostics and utilities:

- **Diagnostics**
  - mtr-tiny (network diagnostics)
  - nmap (network exploration)
  - tcpdump (packet analyzer)
  - iproute2 modern networking tools

- **Utilities**
  - curl and wget for file transfers
  - OpenSSH client
  - DNS utilities (dig, nslookup)
  - socat and netcat for data transfer

## File Operations

File management and processing tools:

- **File Management**
  - Midnight Commander (mc)
  - tree for directory visualization
  - ncdu for disk usage analysis
  - fd-find as modern find alternative

- **Archive Support**
  - zip/unzip
  - tar/gzip
  - rsync for file synchronization

## Text Processing

Text editing and processing capabilities:

- **Editors**
  - Vim (vim-nox)
  - Neovim
  - nano
  - Featherpad (GUI editor)

- **Text Utilities**
  - bat (modern cat replacement)
  - ripgrep (modern grep replacement)
  - tmux for terminal multiplexing
  - jq for JSON processing

## Design Philosophy

The core implementation follows these key principles:

1. **Lightweight First**: All components are chosen with resource efficiency in mind, starting with the LXQt desktop environment.
2. **Modern Alternatives**: Where beneficial, modern replacements for traditional tools are included (e.g., ripgrep, fd-find).
3. **Dual Interface**: Critical functions have both GUI and CLI options available.
4. **Extensibility**: Flatpak support enables easy addition of applications while maintaining system integrity.
5. **Security Baseline**: Basic security tools are included in the core, allowing specialized hardening in security variants.

This core implementation serves as a foundation for both DevOps and Security variants, providing essential tools while remaining lean and efficient.
