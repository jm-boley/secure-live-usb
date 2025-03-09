# Modular Installation Modifier System

## Overview

The Modular Installation Modifier System is a flexible framework that allows for the optional inclusion of additional software, configurations, and customizations during the live system build process. This system is designed to keep the core build clean and minimal while providing a standardized way to extend functionality through optional modules.

## Architecture

The modular system is organized into the following structure:

```
optional/
├── install_mods/           # Installation modifier scripts
│   └── *.sh               # Individual installation scripts
└── overlay-config/        # Configuration files for optional components
    └── package-lists/     # Additional package lists for optional modules
        └── *-deps.list.chroot
```

### Key Components

1. **Installation Modifier Scripts** (`install_mods/*.sh`)
   - Executable shell scripts that implement the installation logic
   - Located in the `optional/install_mods/` directory
   - Named descriptively with a `.sh` extension
   - Execute during the chroot phase of the build process

2. **Package Dependencies** (`overlay-config/package-lists/`)
   - Package list files ending in `-deps.list.chroot`
   - Define additional packages required by optional modules
   - One package per line format
   - Automatically included when the corresponding module is enabled

## Creating New Optional Modules

### Step 1: Create the Installation Script

1. Create a new script in `optional/install_mods/` (e.g., `mymodule.sh`)
2. Make the script executable: `chmod +x mymodule.sh`
3. Implement the installation logic following this template:

```bash
#!/bin/bash

# Module name (used in logs and identifiers)
MODULE_NAME="MyModule"

# Function to perform the installation
install_module() {
    # Your installation logic here
    echo "Installing ${MODULE_NAME}..."
    
    # Return 0 for success, non-zero for failure
    return 0
}

# Execute the installation
install_module
exit $?
```

### Step 2: Define Package Dependencies

If your module requires additional packages:

1. Create a package list file in `optional/overlay-config/package-lists/`
2. Name it `mymodule-deps.list.chroot`
3. List one package per line, for example:
```
package1
package2
package3
```

### Best Practices

1. **Error Handling**
   - Always check for errors and return appropriate exit codes
   - Use meaningful error messages
   - Handle cleanup in case of failures

2. **Logging**
   - Use echo statements for important steps
   - Include the module name in log messages
   - Log both successful and failed operations

3. **Idempotency**
   - Scripts should be safe to run multiple times
   - Check if components are already installed
   - Clean up partial installations if necessary

4. **Dependencies**
   - List all required packages in the corresponding `-deps.list.chroot` file
   - Document any system requirements or prerequisites
   - Consider interactions with other modules

### Example Module

Here's a complete example of a module that installs a hypothetical service:

```bash
#!/bin/bash

MODULE_NAME="ExampleService"

install_module() {
    echo "Installing ${MODULE_NAME}..."
    
    # Create required directories
    mkdir -p /opt/example-service || return 1
    
    # Download and install components
    wget https://example.com/service.tar.gz || return 1
    tar xzf service.tar.gz -C /opt/example-service || return 1
    
    # Configure the service
    cat > /etc/example-service.conf <<EOF
    # Configuration settings
    port=8080
    max_connections=100
    EOF
    
    # Enable the service
    systemctl enable example-service || return 1
    
    echo "${MODULE_NAME} installation completed successfully"
    return 0
}

install_module
exit $?
```

## Integration with Build System

The build system automatically:

1. Detects and loads available modules from `optional/install_mods/`
2. Incorporates package lists from `optional/overlay-config/package-lists/`
3. Executes enabled modules during the chroot phase
4. Handles module dependencies and execution order

## Testing Modules

Before submitting a new module:

1. Test the installation script independently in a clean environment
2. Verify all dependencies are correctly listed
3. Test uninstallation and cleanup procedures
4. Ensure the module works with different system configurations
5. Verify compatibility with other modules

## Troubleshooting

Common issues and solutions:

1. **Script Execution Failures**
   - Check script permissions (must be executable)
   - Verify syntax and shell compatibility
   - Check for missing dependencies

2. **Package Installation Issues**
   - Verify package names in the deps list
   - Ensure package availability in configured repositories
   - Check for version conflicts

3. **Integration Problems**
   - Verify module naming conventions
   - Check file locations and paths
   - Review module execution order

## Module Guidelines

1. **Naming Conventions**
   - Use descriptive, lowercase names for scripts
   - Follow the pattern: `modulename.sh`
   - Use `-deps.list.chroot` suffix for package lists
   - Installation flags must follow the pattern: `--install-modulename`
     (e.g., `--install-warp` for `warp.sh`)

2. **Documentation**
   - Include comments explaining complex operations
   - Document any required configuration
   - List known limitations or conflicts

3. **Security Considerations**
   - Validate downloads and checksums
   - Use secure paths and permissions
   - Handle sensitive data appropriately

## Support and Maintenance

1. **Updating Modules**
   - Test updates thoroughly
   - Maintain backward compatibility
   - Document breaking changes

2. **Removing Modules**
   - Provide cleanup instructions
   - Handle dependency removal
   - Update documentation

3. **Contributing**
   - Follow coding standards
   - Include test procedures
   - Update relevant documentation

