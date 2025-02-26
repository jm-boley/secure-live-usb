#!/bin/bash

INSTALL_WARP=false                 # Default, no Warp terminal install
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

# Download Warp AppImage
download_warp_appimage() {
    local temp_dir=$(mktemp -d)
    local warp_dir="$temp_dir/warp"
    local target_dir="overlay-includes.chroot/var/lib/warp"
    local appimage_path="$warp_dir/warp.AppImage"

    # Create directory
    mkdir -p "$warp_dir"

    echo "Downloading latest Warp AppImage..."
    # Download latest version from official Warp endpoint
    if ! curl -L --progress-bar \
        "https://app.warp.dev/download?package=appimage" \
        -o "$appimage_path"; then
        rm -rf "$temp_dir"
        echo "Error: Failed to download Warp AppImage"
        echo "Please check your internet connection and try again"
        exit 1
    fi

    # Make AppImage executable
    if ! chmod +x "$appimage_path"; then
        rm -rf "$temp_dir"
        echo "Error: Failed to make Warp AppImage executable"
        exit 1
    fi

    # Move to final location
    mkdir -p "$target_dir"
    mv "$appimage_path" "$target_dir/"
    rm -rf "$temp_dir"

    echo "Warp AppImage downloaded and configured successfully"
}

cleanup() {
    if ! $INSTALL_WARP; then
        rm -rf overlay-includes.chroot/var/lib/warp
    fi
    if $CLEAN_BUILD; then
        rm -rf build/*
        touch build/.gitkeep
    fi
}
trap cleanup EXIT

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
    if $CLEAN_BUILD; then
        echo "Cleaning previous build..."
        "$CONTAINER_MANAGER" run --privileged \
            "${SECURITY_OPTS[@]}" \
            -v "build:/build$VOLUME_OPTS" \
            "$IMAGE_NAME" 'sh -c "lb clean"'
    else
        echo "WARNING: Skipping clean step. This may lead to non-deterministic builds and should not be used for production."
    fi

    # Run the config
    if ! "$CONTAINER_MANAGER" run --privileged \
            "${SECURITY_OPTS[@]}" \
            -v "build:/build$VOLUME_OPTS" \
            "$IMAGE_NAME" "sh -c \"lb config noauto ${CONFIG_OPTS[@]}\""; then
        echo "Error: lb config failed"
        exit 1
    fi

    # Copy custom configurations
    echo "Copying custom configurations..."
    if ! cp -rv overlay-config/* build/config/; then
        echo "Error: Failed to copy custom configurations"
        exit 1
    fi
    echo "Custom configurations copied successfully"

    # Run the build
    if ! "$CONTAINER_MANAGER" run --privileged \
            "${SECURITY_OPTS[@]}" \
            -v "build:/build$VOLUME_OPTS" \
            -v "overlay-includes.chroot:/build/config/includes.chroot$VOLUME_OPTS" \
            "$IMAGE_NAME" 'sh -c "lb build"'; then
        echo "Error: Build failed"
        exit 1
    fi
}

# Main script body
check_required_struct
process_args "$@"
setup_container_manager

if $INSTALL_WARP; then
    download_warp_appimage
else
    # Clean up any existing Warp files if not installing
    rm -rf overlay-includes.chroot/var/lib/warp  
fi

prepare_build_image
run_build_process
