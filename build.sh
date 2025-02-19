#!/bin/bash

INSTALL_WARP=false

# Check for required security configuration directories
if [ ! -d "build" ]; then
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

if [ ! -d "custom-config" ]; then
    echo "Error: custom-config/ directory not found"
    echo "The custom-config/ directory is required and must contain your custom"
    echo "live-build configurations that will be applied after the base config."
    echo ""
    echo "To initialize:"
    echo "1. Create the custom-config/ directory"
    echo "2. Add your custom live-build configurations"
    echo "3. Ensure all configurations are properly documented"
    exit 1
fi

if [ ! -d "delta" ]; then
    echo "Error: delta/ directory not found"
    echo "The delta/ directory is required for system hardening modifications"
    echo "and custom security configurations that will be applied to the live image."
    echo ""
    echo "To initialize:"
    echo "1. Create the delta/ directory"
    echo "2. Add custom configurations following the target filesystem structure"
    echo "3. Ensure all security modifications are properly documented"
    exit 1
fi

# Download Warp AppImage
download_warp_appimage() {
    local temp_dir=$(mktemp -d)
    local warp_dir="$temp_dir/warp"
    local target_dir="delta/var/lib/warp"
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

# Default to Podman unless overridden
CONTAINER_MANAGER=""
IMAGE_NAME="debian-live-builder"

# Process arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --override-manager)
            if [[ $2 == "Docker" ]]; then
                CONTAINER_MANAGER="docker"
            else
                echo "Error: --override-manager only accepts 'Docker' as an argument"
                exit 1
            fi
            shift 2
            ;;
        --with-warp)
            INSTALL_WARP=true
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Usage: $0 [--override-manager Docker] [--with-warp]"
            echo ""
            echo "Options:"
            echo "  --override-manager Docker  Use Docker instead of Podman"
            echo "  --with-warp                Install Warp terminal (downloads proprietary AppImage)"
            exit 1
            ;;
    esac
done

# Handle Warp installation
if [[ $INSTALL_WARP == true ]]; then
    download_warp_appimage
else
    # Clean up any existing Warp files if not installing
    rm -rf delta/var/lib/warp
fi

# Check for container managers
have_docker=$(command -v docker)
have_podman=$(command -v podman)

if [[ -z $CONTAINER_MANAGER ]]; then
    if [[ -n $have_podman ]]; then
        CONTAINER_MANAGER="podman"
    elif [[ -n $have_docker ]]; then
        CONTAINER_MANAGER="docker"
    else
        echo "Error: Neither Docker nor Podman found. Please install one of them to continue."
        exit 1
    fi
elif [[ $CONTAINER_MANAGER == "docker" && -z $have_docker ]]; then
    echo "Error: Docker selected but not found. Please install Docker or use Podman."
    exit 1
fi

# Set Z flag for SELinux contexts if using Podman
VOLUME_OPTS=""
if [[ $CONTAINER_MANAGER == "podman" ]]; then
    VOLUME_OPTS=":Z"
fi

echo "Using container manager: $CONTAINER_MANAGER"

echo "Copying custom configurations..."


# Run the config
$CONTAINER_MANAGER run --privileged \
    -v "$PWD/build:/build$VOLUME_OPTS" \
    $IMAGE_NAME 'sh -c "lb config"'

# Copy custom configurations
if ! [[ cp -rv /custom-config/* /build/config/ ]]; then
    echo "Error: Failed to copy custom configurations"
    exit 1
fi


if [ $? -ne 0 ]; then
    echo "Error: Failed to copy custom configurations"
    exit 1
fi
echo "Custom configurations copied successfully"

# Run the build
$CONTAINER_MANAGER run --privileged \
    -v "$PWD/build:/build$VOLUME_OPTS" \
    -v "$PWD/delta:/build/config/includes.chroot$VOLUME_OPTS" \
    $IMAGE_NAME

