# ATK-IMX6U Embedded Linux BSP

A minimal embedded Linux system for the ATK-IMX6U board, built with Buildroot and the NXP i.MX6ULL BSP.

## Hardware

| Component | Specification |
|-----------|---------------|
| **SoC** | NXP i.MX6ULL, Cortex-A7 @ 792MHz |
| **RAM** | 512MB DDR3L |
| **Storage** | 8GB eMMC (mmcblk1) |
| **Ethernet** | SR8201F PHY via RMII (ENET1 + ENET2) |
| **Serial** | UART1 (ttymxc0), 115200 baud |
| **RS-485** | TP8485E via UART3 (ttymxc2), auto direction control |
| **Boot** | U-Boot 2016.03 → eMMC |

## Software Stack

| Component | Source | Version |
|-----------|--------|---------|
| **Kernel** | [NXP linux-imx](https://github.com/nxp-imx/linux-imx) | `lf-6.6.y` (6.6.52) |
| **Rootfs** | [Buildroot](https://github.com/buildroot/buildroot) | 2024.02 |
| **Bootloader** | [NXP uboot-imx](https://github.com/nxp-imx/uboot-imx) | `lf_v2023.04` |
| **Toolchain** | Buildroot-built | GCC 12.3.0, glibc |

## Directory Structure

```
GitHubUpload/
├── DTS/
│   └── imx6ull-atk.dts              Custom Device Tree (UARTs + eMMC + dual FEC + UART3)
├── configs/
│   ├── kernel_defconfig/
│   │   └── kernel_atk_imx6u_defconfig  Minimal kernel config (incl. USB host)
│   ├── atk_imx6u_min_defconfig         Buildroot config (toolchain + Dropbear)
│   ├── kernel-minimal.fragment         Kernel config fragment
│   ├── usb.fragment                    USB host config fragment
│   └── rootfs-overlay/                 Rootfs overlay (hostname, network, SSH keys)
├── scripts/
│   ├── build_kernel.sh              Build kernel + DTBs
│   ├── build_uboot.sh               Build U-Boot
│   ├── build_rootfs.sh              Build Buildroot rootfs
│   └── deploy.sh                    SCP deploy to board
├── docs/
│   ├── DevLog_20260727.md           English dev log (Day 1)
│   ├── 歷程紀錄_20260727.md          Chinese dev log (Day 1)
│   ├── DevLog_20260728.md             English dev log (Day 2: SSH + USB)
│   ├── 歷程紀錄_20260728.md            Chinese dev log (Day 2)
│   ├── DevLog_20260729.md             English dev log (Day 3: UART3 + RS-485)
│   └── 歷程紀錄_20260729.md            Chinese dev log (Day 3)
└── hardware/
    ├── imx6ull-sr8201f-interface.md  Ethernet PHY wiring doc
    └── pinmux.md                     Pin function table + PHY address map
```

## Quick Start

### Prerequisites

```bash
sudo apt install gcc make libncurses-dev libssl-dev flex bison
```

### 1. Clone Kernel Source

```bash
git clone --depth 1 --branch lf-6.6.y https://github.com/nxp-imx/linux-imx.git
```

### 2. Build Kernel

```bash
export ARCH=arm
export CROSS_COMPILE=/path/to/arm-linux-gnueabihf-gcc  # or use Buildroot toolchain

# Copy our defconfig into kernel tree
cp configs/kernel_defconfig/kernel_atk_imx6u_defconfig linux-imx/arch/arm/configs/
cp configs/usb.fragment linux-imx/

cd linux-imx
make kernel_atk_imx6u_defconfig

# (Optional) Merge USB host support fragment
scripts/kconfig/merge_config.sh -m -O . .config usb.fragment
make ARCH=arm olddefconfig

make -j$(nproc) zImage nxp/imx/imx6ull-atk.dtb
```

### 3. Build Rootfs (Buildroot)

```bash
cd buildroot
make atk_imx6u_min_defconfig  # or copy configs/atk_imx6u_min_defconfig
make
# Output: output/images/rootfs.tar
```

### 4. Build U-Boot

```bash
cd uboot-imx
export ARCH=arm
export CROSS_COMPILE=/path/to/arm-linux-gnueabihf-
make atk_imx6u_config      # or your board config
make
```

### 5. Deploy to Board

```bash
# Option A: Via SCP (requires network, recommended)
./scripts/deploy.sh

# Option B: Copy manually to boot partition
mount /dev/mmcblk1p1 /boot
cp arch/arm/boot/zImage /boot/
cp arch/arm/boot/dts/nxp/imx/imx6ull-atk.dtb /boot/
sync

# Extract rootfs to root partition (mmcblk1p2)
mount /dev/mmcblk1p2 /mnt
tar xf rootfs.tar -C /mnt
sync
```

### 6. Boot

Reset the board. U-Boot loads `fdt_file=imx6ull-atk.dtb` automatically.

## Hardware Peripherals

### RS-485 (UART3)

UART3 is connected to a TP8485E RS-485 transceiver with automatic direction control:

```bash
# UART3 appears as /dev/ttymxc2
stty -F /dev/ttymxc2 115200

# Test loopback
echo "test" > /dev/ttymxc2
```

The direction is handled by an inverter between TXD and RE/DE pins — no GPIO required.

## Post-Boot

### Network Configuration

The board auto-configures a static IP at boot via `/etc/network/interfaces`:

```
eth0 (ENET1): 192.168.1.100/24
eth1 (ENET2): 192.168.1.101/24
```

### SSH Access

SSH (Dropbear) starts automatically at boot. Use the provided RSA key:

```powershell
ssh -i <path/to/atk_rsa_key> root@192.168.1.100
```

### USB Support

The kernel supports USB host mode (ChipIdea controller), tested with USB flash drives:

```bash
# Plug in a USB device, then:
mount /dev/sda1 /mnt
ls /mnt
```

## Project Evolution

This project was built incrementally across multiple development sessions:

| Date | Milestone |
|------|-----------|
| Jul 27 | Initial BSP: minimal kernel, Buildroot rootfs, ENET2 + UART1 + eMMC |
| Jul 28 | DTS debugging: dual ENET with SR8201F PHY + SSH setup + USB host enablement |
| Jul 29 | UART3 integration with TP8485E RS-485 + DTB deployment debug |

See the `docs/` folder for detailed development logs. Each session documents the
problems encountered and the solutions implemented.

## Known Issues

- MAC address is random (OCOTP fuses not accessible in current setup)
- USB is limited to USB 2.0 (EHCI); USB 3.0 is not supported on this SoC
- UART2 RTS/CTS pins were removed to free pins for UART3 (no hardware flow control on UART2)
- Power management features are disabled in the kernel config
