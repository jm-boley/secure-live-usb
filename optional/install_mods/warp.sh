#!/bin/bash

# Warp Terminal Installer Script
# -----------------------------
# This script handles the installation of Warp terminal and its dependencies.
# It provides:
# - Staging of Warp-specific package lists
# - Staging of AppImage dependencies
# - Configuration for Warp terminal location
# - Integration with the main build system's optional package framework

# Exit on any error
set -e

# Function: stage_warp_dependencies
# -------------------------------
# Stages necessary dependencies and configurations for Warp terminal.
# Return codes:
#   0: Success
#   1: Error staging dependencies
stage_warp_dependencies() {
    echo "  - Starting Warp dependency staging..."

    local DEST_DIR="overlay-config/package-lists"
    local SRC_DIR="optionals/overlay-config/package-lists"
    local WARP_DIR="overlay-includes.chroot/var/lib/warp"

    # Ensure destination directories exist
    mkdir -p "$DEST_DIR" "$WARP_DIR" || {
        echo "    • Failed to create required directories" >&2
        return 1
    }

    # Copy Warp-specific package lists
    echo "    • Staging Warp package dependencies..."
    cp -v "$SRC_DIR/warp-deps.list.chroot" "$DEST_DIR/" || {
        echo "    • Failed to stage Warp package dependencies" >&2
        return 1
    }

    echo "    • Warp dependencies staged successfully"
    return 0
}

# Function: register_warp_installer
# ------------------------------
# Registers the Warp installer function with the build system.
# This function is called by the main build script when INSTALL_WARP is true.
register_warp_installer() {
    if [[ "$INSTALL_WARP" == "true" ]]; then
        echo "  - Registering Warp installer..."
        # Register our staging function
        OPTIONAL_INSTALLERS+=("stage_warp_dependencies")
        OPTIONAL_INSTALLER_FLAGS+=("--install-warp")
        echo "    • Warp installer registered successfully"
    fi
}

# Export the registration function
export -f register_warp_installer

