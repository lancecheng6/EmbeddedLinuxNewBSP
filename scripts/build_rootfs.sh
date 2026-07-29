#!/bin/bash
#
# Build Buildroot rootfs for ATK-IMX6U
#
# Prerequisites:
#   - Buildroot source cloned from:
#     git clone --depth 1 --branch 2024.02 \
#       https://github.com/buildroot/buildroot.git
#
# Usage:
#   export CROSS_COMPILE=/path/to/arm-linux-gnueabihf-
#   ./build_rootfs.sh
#
# Environment variables:
#   BUILDROOT_DIR - Path to Buildroot source (default: ../buildroot)
#   DEFCONFIG     - Path to defconfig (default: ../configs/atk_imx6u_min_defconfig)

set -e

BUILDROOT_DIR="${BUILDROOT_DIR:-../buildroot}"
DEFCONFIG_SRC="${DEFCONFIG:-$(dirname "$0")/../configs/atk_imx6u_min_defconfig}"
OVERLAY_SRC="$(dirname "$0")/../configs/rootfs-overlay"

# Validate
if [ ! -d "$BUILDROOT_DIR" ]; then
    echo "Error: Buildroot source not found at $BUILDROOT_DIR"
    echo "Clone it first:"
    echo "  git clone --depth 1 --branch 2024.02 https://github.com/buildroot/buildroot.git $BUILDROOT_DIR"
    exit 1
fi

# Copy defconfig
cp "$DEFCONFIG_SRC" "$BUILDROOT_DIR/configs/atk_imx6u_min_defconfig"

# Copy rootfs overlay
if [ -d "$OVERLAY_SRC" ]; then
    mkdir -p "$BUILDROOT_DIR/board/atk-imx6u"
    cp -r "$OVERLAY_SRC" "$BUILDROOT_DIR/board/atk-imx6u/rootfs-overlay"
fi

cd "$BUILDROOT_DIR"

echo "=== Applying defconfig ==="
make atk_imx6u_min_defconfig

echo "=== Building rootfs ==="
make

echo "=== Output ==="
ls -lh output/images/rootfs.tar
echo "=== Build complete ==="
