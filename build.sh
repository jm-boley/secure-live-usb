#!/bin/bash

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
        *)
            echo "Unknown argument: $1"
            echo "Usage: $0 [--override-manager Docker]"
            exit 1
            ;;
    esac
done

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

# Run the build
$CONTAINER_MANAGER run --privileged \
    -v "$PWD/build:/build$VOLUME_OPTS" \
    -v "$PWD/delta:/build/config/includes.chroot$VOLUME_OPTS" \
    $IMAGE_NAME

