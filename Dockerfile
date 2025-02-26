# syntax=docker/dockerfile:1.4

FROM debian:bookworm-slim

# Prevent apt from prompting for input
ENV DEBIAN_FRONTEND=noninteractive

# Add environment variables for required capabilities and enable security features
ENV REQUIRED_CAPS="cap_setfcap,cap_setuid,cap_setgid,cap_chown,cap_dac_override"
ENV DOCKER_CONTENT_TRUST=1 \
    DOCKER_BUILDKIT=1

# Install required packages
# Note: ca-certificates, gnupg, and wget moved to the front as they're often needed for adding repositories
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        wget \
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
        cpio \
        zstd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create build user and group with explicit UID/GID
RUN groupadd -r -g 10000 builder && \
    useradd -r -g builder -u 10000 -s /bin/bash -d /build builder && \
    mkdir -p /build && \
    chown builder:builder /build

# Set secure permissions
RUN chmod 755 /build && \
    chmod 644 /etc/passwd /etc/group

# Create and set build directory
WORKDIR /build

# Add metadata labels
LABEL maintainer="Joshua Boley <jm.boley.se@gmail.com>" \
    description="Debian live-build environment" \
    version="1.0" \
    org.opencontainers.image.title="debian-live-builder" \
    org.opencontainers.image.description="Secure Debian live-build environment" \
    org.opencontainers.image.vendor="Joshua Boley" \
    org.opencontainers.image.authors="Joshua Boley <jm.boley.se@gmail.com>" \
    org.opencontainers.image.licenses="MIT"

# Switch to non-root user
USER builder

CMD ["/bin/bash"]
