#!/bin/bash
#
# Deploy kernel + DTB to ATK-IMX6U board via SCP + SSH
#
# Prerequisites:
#   - Board IP: 192.168.1.100
#   - SSH access (RSA key authentication)
#   - Built kernel and DTB in linux-imx/
#
# Usage:
#   export SSH_KEY=/path/to/private_key    # optional
#   ./deploy.sh
#
# Environment variables:
#   BOARD_IP   - Board IP address (default: 192.168.1.100)
#   KERNEL_DIR - Path to kernel source (default: ../linux-imx)
#   SSH_KEY    - Path to SSH private key (default: not set, uses agent)

set -e

BOARD_IP="${BOARD_IP:-192.168.1.100}"
KERNEL_DIR="${KERNEL_DIR:-../linux-imx}"
SSH_OPTS="-o StrictHostKeyChecking=no -o HostKeyAlgorithms=+ssh-rsa"

if [ -n "$SSH_KEY" ]; then
    SSH_OPTS="$SSH_OPTS -i $SSH_KEY"
fi

KERNEL_IMAGE="$KERNEL_DIR/arch/arm/boot/zImage"
DTB="$KERNEL_DIR/arch/arm/boot/dts/nxp/imx/imx6ull-atk.dtb"
SSH_DEST="root@$BOARD_IP"

echo "=== Deploying to $BOARD_IP ==="

# Check files exist
for f in "$KERNEL_IMAGE" "$DTB"; do
    if [ ! -f "$f" ]; then
        echo "Error: $f not found. Build kernel first."
        exit 1
    fi
done

# Mount boot partition on board
ssh $SSH_OPTS "$SSH_DEST" "mount /dev/mmcblk1p1 /boot 2>/dev/null || true"
echo "Boot partition mounted"

# Copy kernel + DTB in parallel
scp $SSH_OPTS "$KERNEL_IMAGE" "$SSH_DEST:/boot/zImage"
echo "Kernel deployed"

scp $SSH_OPTS "$DTB" "$SSH_DEST:/boot/imx6ull-atk.dtb"
echo "DTB deployed"

# Sync and verify
ssh $SSH_OPTS "$SSH_DEST" "sync; ls -la /boot/zImage /boot/imx6ull-atk.dtb"
echo "=== Deploy complete. Reboot the board. ==="
