#!/bin/bash
#
# Build NXP U-Boot for ATK-IMX6U (i.MX6ULL 14x14 EVK eMMC)
#
# Prerequisites:
#   - ARM cross-compiler (e.g., arm-linux-gnueabihf-gcc)
#   - U-Boot source cloned from:
#     git clone --depth 1 --branch lf_v2023.04 \
#       https://github.com/nxp-imx/uboot-imx.git
#
# Customizations applied on top of mx6ull_14x14_evk_defconfig
# (see ../configs/uboot_customizations.md):
#   - arch/arm/dts/imx6ull-atk.dts (custom board DTS, fec1 disabled)
#   - board/freescale/mx6ullevk/imximage.cfg (Nanya DDR3L-1866 DCD)
#   - include/configs/mx6ullevk.h (fdt_file=imx6ull-atk.dtb)
#   - CONFIG_DEFAULT_DEVICE_TREE / CONFIG_CMD_MII / CONFIG_NET_RANDOM_ETHADDR
#
# Usage:
#   export CROSS_COMPILE=/path/to/arm-linux-gnueabihf-
#   ./build_uboot.sh

set -e

UBOOT_DIR="${UBOOT_DIR:-../uboot-imx}"

if [ ! -d "$UBOOT_DIR" ]; then
    echo "Error: U-Boot source not found at $UBOOT_DIR"
    echo "Clone it first:"
    echo "  git clone --depth 1 --branch lf_v2023.04 https://github.com/nxp-imx/uboot-imx.git $UBOOT_DIR"
    exit 1
fi

if [ -z "$CROSS_COMPILE" ]; then
    echo "Error: CROSS_COMPILE not set"
    echo "  export CROSS_COMPILE=/path/to/arm-linux-gnueabihf-"
    exit 1
fi

export ARCH=arm

cd "$UBOOT_DIR"

echo "=== Applying defconfig ==="
make mx6ull_14x14_evk_defconfig

echo "=== Building U-Boot ==="
make -j$(nproc)

echo "=== Output ==="
ls -lh u-boot-dtb.imx
ls -lh u-boot.bin
echo "=== Build complete ==="
