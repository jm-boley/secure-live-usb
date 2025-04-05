#!/bin/bash

# Arrays to hold optional installer functions and their corresponding flags
declare -a OPTIONAL_INSTALLER_FUNCTIONS
declare -a OPTIONAL_INSTALLER_FLAGS

# Function to register optional installers
register_optional_installer() {
    local func_name="$1"
    local flag_name="$2"
    OPTIONAL_INSTALLER_FUNCTIONS+=("$func_name")
    OPTIONAL_INSTALLER_FLAGS+=("$flag_name")
}

CONTAINER_MANAGER="podman"         # Default, use Podman unless overridden
IMAGE_NAME="debian-live-builder"   # Default builder image name

# Security options for container operations
SECURITY_OPTS=(
    "--security-opt=no-new-privileges"
    "--security-opt" "seccomp=default"
    "--cap-drop=ALL"
    "--cap-add=SETFCAP"
    "--cap-add=SETUID"
    "--cap-add=SETGID"
    "--cap-add=CHOWN"
    "--cap-add=DAC_OVERRIDE"
    "--tmpfs" "/tmp:rw,noexec,nosuid,size=128M"
)

# Configuration options for lb config
CONFIG_OPTS=(
    "--distribution" "bookworm"
    "--architectures" "amd64"
    "--archive-areas" "main contrib non-free-firmware"
    "--binary-images" "iso-hybrid"
    "--bootloader" "grub-efi"
    "--debian-installer" "none"
    "--memtest" "none"
    "--binary-filesystem" "fat32"
    "--apt-indices" "false"
    "--apt-recommends" "false"
    "--debootstrap-options" "--variant=minbase"
    "--firmware-binary" "true"
    "--firmware-chroot" "true"
)

check_required_struct() {
    # Check for required project directories
    if [[ ! -d "build" ]]; then
        echo "Error: build/ directory not found"
        echo "The build/ directory is required and must contain your live-build configuration"
        echo "including security-focused boot options and system hardening settings."
        echo ""
        echo "To initialize:"
        echo "1. Create the build/ directory"
        echo "2. Copy the base live-build configuration template"
        echo "3. Customize security settings in build/config/"
        exit 1
    fi

    if [[ ! -d "overlay-config" ]]; then
        echo "Error: overlay-config/ directory not found"
        echo "The overlay-config/ directory is required and must contain your custom"
        echo "live-build configurations that will be applied after the base config."
        echo ""
        echo "To initialize:"
        echo "1. Create the overlay-config/ directory"
        echo "2. Add your custom live-build configurations"
        echo "3. Ensure all configurations are properly documented"
        exit 1
    fi

    if [[ ! -d "overlay-includes.chroot" ]]; then
        echo "Error: overlay-includes.chroot/ directory not found"
        echo "The overlay-includes.chroot/ directory is required for system hardening modifications"
        echo "and custom security configurations that will be applied to the live image."
        echo ""
        echo "To initialize:"
        echo "1. Create the overlay-includes.chroot/ directory"
        echo "2. Add custom configurations following the target filesystem structure"
        echo "3. Ensure all security modifications are properly documented"
        exit 1
    fi
}

# Source optional installer scripts and run registered installers
process_install_modifiers() {
    local installer_dir="optional/install_mods"
    if [[ ! -d "$installer_dir" ]]; then
        echo "  - No optional installers directory found, skipping"
        return 0
    fi

    # Source all installer scripts
    echo "  - Discovering optional installers"
    for installer in "$installer_dir"/*.sh; do
        if [[ -f "$installer" ]]; then
            echo "    • Loading installer: $(basename "$installer")"
            if ! source "$installer"; then
                echo "    • Error: Failed to source installer $(basename "$installer")" >&2
                return 1
            fi
        fi
    done

    # Execute registered installers if their flags are set
    if ((${#OPTIONAL_INSTALLER_FUNCTIONS[@]} > 0)); then
        echo "  - Processing optional installers"
        local i
        for ((i=0; i<${#OPTIONAL_INSTALLER_FUNCTIONS[@]}; i++)); do
            local func="${OPTIONAL_INSTALLER_FUNCTIONS[$i]}"
            local flag="${OPTIONAL_INSTALLER_FLAGS[$i]}"
            
            # Check if this installer's flag was provided
            if [[ " $* " =~ " $flag " ]]; then
                echo "    • Executing: $func (triggered by $flag)"
                if ! "$func"; then
                    echo "    • Error: Optional installer $func failed" >&2
                    return 1
                fi
            else
                echo "    • Skipping: $func ($flag not specified)"
            fi
        done
        echo "    • All optional installers processed"
    else
        echo "  - No optional installers registered"
    fi
}

cleanup() {
    if $CLEAN_BUILD; then
        rm -rf build/*
        touch build/.gitkeep
    fi
}
trap cleanup EXIT

query_acctdets() {
    local username
    local password1
    local password2

    # Prompt for username
    echo "Enter the username for the live system (default: liveuser):"
    read username
    username=${username:-liveuser}  # Default to "liveuser" if empty

    # Prompt for password (repeat for confirmation)
    while true; do
        echo "Enter the password for '$username':"
        stty -echo
        read password1
        stty echo
        echo "Confirm password:"
        stty -echo
        read password2
        stty echo
        if [ "$password1" = "$password2" ]; then
            password="$password1"
            break
        else
            echo "Passwords do not match. Try again."
        fi
    done

    # Ensure config.conf.d directory exists
    mkdir -p overlay-includes.chroot/etc/live/config.conf.d/

    # Write live-config settings
    cat << 'EOF' > overlay-includes.chroot/etc/live/config.conf.d/user.conf
LIVE_USERNAME="$username"
LIVE_USER_FULLNAME="Live User"
LIVE_HOSTNAME="debian-live"
LIVE_USER_DEFAULT_GROUPS="audio cdrom dip floppy video plugdev netdev bluetooth sudo"
EOF

    # Export username and password for use in hook script
    export LIVE_USER="$username"
    export LIVE_PASSWD="$password1"
}

usage() {
    cat << 'EOF'
Secure Live USB Builder
----------------------
Creates a hardened Debian-based live USB image using secure container-based build
environment with either Podman (default) or Docker.

Usage:
    ./build.sh [options]

Options:
    --use-docker       Use Docker instead of Podman for container operations
    --with-warp        Install Warp terminal (downloads proprietary AppImage)
    --no-clean         Skip cleaning previous build (not recommended for production)
    -h, --help         Display this help message

Requirements:
    - Either Podman (preferred) or Docker installed and running
    - Sufficient disk space for build environment (~10GB recommended)
    - Internet connection for package downloads
    - Root/sudo access for container operations

Examples:
    # Standard build using Podman (recommended)
    ./build.sh

    # Build with Docker and include Warp terminal
    ./build.sh --use-docker --with-warp

    # Development build without cleaning
    ./build.sh --no-clean

Notes:
    - The --no-clean option should only be used for development
    - Building requires privileged container access
    - Custom configurations should be placed in overlay-config/
    - System modifications belong in overlay-includes.chroot/
EOF
}

process_args() {
    # Process command line arguments
    CLEAN_BUILD=true
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-clean)
                CLEAN_BUILD=false
                shift
                ;;
            --use-docker)
                CONTAINER_MANAGER="docker"
                shift
                ;;
            --with-warp)
                INSTALL_WARP=true
                shift
                ;;
	    -h | --help)
		usage
		exit 0
            *)
                echo "Unknown argument: $1"
		usage
                exit 1
                ;;
        esac
    done
}

setup_container_manager() {
    # Verify that at least one of Podman or Docker is installed
    local have_docker=$(command -v "docker")
    local have_podman=$(command -v "podman")
    if ! [[ -n $have_docker ]] && ! [[ -n $have_podman ]]; then
        echo "Error: Neither Docker nor Podman found. Please install one of them to continue."
	exit 1
    elif [[ -n $have_docker ]] && ! [[ -n $have_podman ]]; then
	CONTAINER_MANAGER="docker"
    fi

    # Set Z flag for SELinux contexts if using Podman
    VOLUME_OPTS=""
    if [[ $CONTAINER_MANAGER == "podman" ]]; then
        VOLUME_OPTS=":Z"
        export REGISTRY_TRUST_MODE=accept
    fi

    echo "Using container manager: $CONTAINER_MANAGER"
}

prepare_build_image() {
    if ! "$CONTAINER_MANAGER" images -q "$IMAGE_NAME" > /dev/null 2>&1; then
        echo "Building container image $IMAGE_NAME..."
        if ! "$CONTAINER_MANAGER" build "${SECURITY_OPTS[@]}" -t "$IMAGE_NAME" .; then
            echo "Error: Failed to build container image"
            exit 1
        fi
    fi
}

run_build_process() {
    echo "Stage 1: Preparation"
    if $CLEAN_BUILD; then
        echo "  - Cleaning build environment"
        if ! "$CONTAINER_MANAGER" run --privileged \
            "${SECURITY_OPTS[@]}" \
            -v "build:/build$VOLUME_OPTS" \
            "$IMAGE_NAME" 'sh -c "lb clean"'; then
            echo "    • Error: Failed to clean build environment" >&2
            return 1
        fi
        echo "    • Build environment cleaned successfully"
    else
        echo "  - WARNING: Skipping clean step (not recommended for production)" >&2
    fi

    echo -e "\nStage 2: Live Build Configuration"
    echo "  - Configuring live-build parameters"
    if ! "$CONTAINER_MANAGER" run --privileged \
            "${SECURITY_OPTS[@]}" \
            -v "build:/build$VOLUME_OPTS" \
            "$IMAGE_NAME" "sh -c \"lb config noauto ${CONFIG_OPTS[@]}\""; then
        echo "    • Error: Live build configuration failed" >&2
        return 1
    fi
    echo "    • Live build configured successfully"

    echo -e "\nStage 3: Optional Components"
    if ! process_install_modifiers "$@"; then
        echo "  - Error: Optional component installation failed" >&2
        return 1
    fi

    echo -e "\nStage 4: Overlay Configuration"
    echo "  - Applying overlay configurations"
    if ! cp -rv overlay-config/* build/config/; then
        echo "Error: Failed to copy overlay-config/ to build directory" >&2
        return 1
    fi
    echo "  - All configurations copied successfully"

    echo -e "\nStage 5: Build Execution"
    echo "  - Running live-build process"
    if ! "$CONTAINER_MANAGER" run --privileged \
            "${SECURITY_OPTS[@]}" \
            -v "build:/build$VOLUME_OPTS" \
            -v "overlay-includes.chroot:/build/config/includes.chroot$VOLUME_OPTS" \
            "$IMAGE_NAME" 'sh -c "lb build"'; then
        echo "    • Error: Build process failed" >&2
        return 1
    fi
    echo "    • Build completed successfully"
}

# Main script body
check_required_struct
process_args "$@"
setup_container_manager

query_acctdets
prepare_build_image
run_build_process
