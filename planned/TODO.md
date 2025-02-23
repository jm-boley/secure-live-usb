# Core Infrastructure Tasks

> Note: Data persistence features are now managed as separate subprojects:
> - Standard persistence: See `planned/standard-persistence.md`
> - Spin-specific persistence: See respective spin documentation

## High Priority

### User Configuration Script (configure-user.sh)
- Implement secure username/password input handling
- Add input validation for:
    - Username format and length
    - Password complexity
    - System username conflicts
- Implement template variable replacement ({{user}}, {{uid}}, {{gid}}, etc.)
- Implement secure password hashing
- Add system file updates with validation
- Add home directory creation with proper permissions
- Implement dependency checking on graft_delta.sh

### Build System Core
- Add validation checks for critical configuration files
- Implement --dry-run option for all scripts
- Add verbose logging options
- Implement file backup system
- Add rollback capability for failed operations

## Repository Organization

### Branch Migration Strategy
- Implement Git worktree based approach for spin separation:
    ```
    # Create branches without switching
    git branch devops
    git branch security
    
    # Create separate worktrees
    git worktree add ../devops-live-usb-devops devops
    git worktree add ../devops-live-usb-security security
    ```
- Benefits:
    - Direct organization of files in final locations
    - Simultaneous work on multiple branches
    - Independent testing of configurations
    - Cleaner git history
    - No cleanup of migration directories needed

#### Implementation Steps
- Create feature branches (devops, security)
- Set up worktrees for each branch
- Move current migration/{devops,security} content to respective worktrees
- Test builds in each worktree
- Remove worktrees after branch migration complete
- Delete migration directory from main branch

## Documentation

### User Documentation
- Enhance README.md with:
    - Quick-start guide
    - Troubleshooting section
    - Links to spin-specific documentation
- Add example configurations in delta/
- Document version tagging strategy

### Documentation Reorganization
- Implement hybrid documentation approach:
    ```
    Wiki/
    ├── Technical References/
    │   ├── Network Hardening Guide
    │   └── Container Security Guide
    ├── Best Practices/
    │   ├── Network Security
    │   └── Container Security
    └── Implementation Examples/
        ├── Network Configurations
        └── Container Configurations

    Repo/
    ├── docs/
    │   ├── network-configs/
    │   │   └── current-settings.md
    │   └── container-configs/
    │       └── default-policies.md
    └── README.md (with wiki links)
    ```

#### Implementation Steps
- Create wiki infrastructure and initial structure
- Migrate existing technical references to wiki:
    - Network Hardening Reference
    - Container Security Reference
- Extract version-specific configurations to repo
- Update README.md with wiki links
- Implement cross-referencing between repo docs and wiki
- Review and migrate additional technical content as needed

### Data Persistence
- Implement standard persistence features:
    - User data preservation
    - System configuration backup
    - State restoration tools
- Create unified persistence documentation
- Add recovery procedures guide
