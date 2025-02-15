# Scripts to Implement

## Overview
The following script needs to be implemented to support proper system customization:
- `configure-user.sh`: User account configuration script
## User Configuration Script Requirements
- Accept username and password as secure inputs
- Validate inputs for:
- Username format/length
- Password complexity
- System username conflicts
- Update template variables in copied files:
- {{user}} - username
- {{uid}} - user ID (default 1000)
- {{gid}} - group ID (default 1000)
- {{gecos}} - GECOS field
- {{home}} - home directory path
- Generate secure password hash using modern algorithm
- Update system files:
- /etc/passwd
- /etc/group
- /etc/shadow
- /etc/sudoers.d/
- Run after graft_delta.sh completes
- Verify all files are updated correctly
- Generate user home directory with correct permissions

## Template Variables in delta/
The delta/ directory contains files with template variables that must be updated by configure-user.sh:
```
/etc/passwd: {{user}}:x:{{uid}}:{{gid}}:{{gecos}}:{{home}}:/bin/bash
/etc/group: {{user}}:x:{{gid}}:
/etc/sudoers.d/: {{user}} ALL=(ALL) ALL
```

## Dependencies and Order
1. Base system files must be available (rootfs/ or other source)
2. graft_delta.sh must run first to create includes.chroot/
3. configure-user.sh runs after graft completes
4. Both scripts should be idempotent
5. Scripts should validate prerequisites before running
6. Error handling should preserve original files on failure

## Additional Considerations
- Backup all files before modification
- Log all operations for debugging
- Verify file permissions after updates
- Consider adding rollback capability
- Add dry-run option for testing

## Future Enhancements

### Secure Shutdown Copy Service
A planned security feature to protect against data loss and unauthorized access in Live USB environments:

- Implements secure copying of user data to encrypted storage during shutdown
- Protects against unauthorized access to temporary files and swap
- Provides configurable data persistence between sessions
- Ensures sensitive data is not left on the host system

## Project Infrastructure TODOs

### Documentation Improvements
- Add CONTRIBUTING.md with contribution guidelines
- Create SECURITY.md for security policy and reporting
- Implement version tagging strategy
- Add quick-start guide to README.md
- Create troubleshooting section in README.md
- Add example configurations in delta/
- Add build status badges to README.md

### Build Script Enhancements
- Add validation checks for critical configuration files
- Implement --dry-run option
- Add verbose logging options
- Add configuration validation tools

### CI/CD Implementation
- Set up automated testing pipeline
- Implement automated builds
- Add automated security scanning
- Set up release automation
