#!/bin/bash
#
# Build NXP Linux kernel for ATK-IMX6U
#
# Prerequisites:
#   - ARM cross-compiler (e.g., arm-linux-gnueabihf-gcc)
#   - Kernel source cloned from:
#     git clone --depth 1 --branch lf-6.6.y \
#       https://github.com/nxp-imx/linux-imx.git
#
# Usage:
#   export CROSS_COMPILE=/path/to/arm-linux-gnueabihf-
#   ./build_kernel.sh

set -e

KERNEL_DIR="${KERNEL_DIR:-../linux-imx}"
DEFCONFIG_SRC="$(dirname "$0")/../configs/kernel_defconfig/kernel_atk_imx6u_defconfig"
DTBS="nxp/imx/imx6ull-atk.dtb"

# Validate
if [ ! -d "$KERNEL_DIR" ]; then
    echo "Error: Kernel source not found at $KERNEL_DIR"
    echo "Clone it first:"
    echo "  git clone --depth 1 --branch lf-6.6.y https://github.com/nxp-imx/linux-imx.git $KERNEL_DIR"
    exit 1
fi

if [ -z "$CROSS_COMPILE" ]; then
    echo "Error: CROSS_COMPILE not set"
    echo "  export CROSS_COMPILE=/path/to/arm-linux-gnueabihf-"
    exit 1
fi

export ARCH=arm

# Copy our defconfig into kernel tree
cp "$DEFCONFIG_SRC" "$KERNEL_DIR/arch/arm/configs/"

cd "$KERNEL_DIR"

echo "=== Applying defconfig ==="
make kernel_atk_imx6u_defconfig

echo "=== Building kernel + DTBs ==="
make -j$(nproc) zImage $DTBS

echo "=== Output ==="
ls -lh arch/arm/boot/zImage
ls -lh arch/arm/boot/dts/$DTBS
echo "=== Build complete ==="
