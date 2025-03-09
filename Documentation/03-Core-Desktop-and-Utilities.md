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
