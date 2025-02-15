FROM debian:bookworm-slim

LABEL maintainer="Security Team <security@example.com>"
LABEL description="Debian live-build environment for creating custom security-focused live images"
LABEL version="1.0"

# Prevent apt from prompting for input
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        live-build \
        debootstrap \
        xorriso \
        isolinux \
        syslinux-common \
        squashfs-tools \
        grub-pc-bin \
        grub-efi-amd64-bin \
        mtools \
        dosfstools \
        rsync \
        ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create and set build directory
WORKDIR /build

# Set entrypoint to bash
CMD ["/bin/bash"]

