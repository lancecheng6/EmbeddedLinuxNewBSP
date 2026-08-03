# ATK-IMX6U Embedded Linux BSP

A minimal embedded Linux system for the ATK-IMX6U board, built with Buildroot and the NXP i.MX6ULL BSP.

## Hardware

| Component | Specification |
|-----------|---------------|
| **SoC** | NXP i.MX6ULL, Cortex-A7 @ 792MHz |
| **RAM** | 512MB DDR3L |
| **Storage** | 8GB eMMC (mmcblk1) |
| **Ethernet** | SR8201F PHY via RMII (ENET1 + ENET2) |
| **Display** | ATK-MD0700R 7" 1024x600 RGB888 (DRM mxsfb + PWM backlight) |
| **Touch** | GOODIX GT911 capacitive touchscreen (I2C2, addr 0x14) |
| **Serial** | UART1 (ttymxc0), 115200 baud |
| **RS-485** | TP8485E via UART3 (ttymxc2), auto direction control |
| **Boot** | U-Boot lf_v2023.04 → eMMC boot0 |

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
│   ├── imx6ull-atk.dts              Custom Device Tree (UARTs + eMMC + dual FEC + UART3 + audio + LCD + GT911)
│   └── imx6ull-atk-uboot.dts        U-Boot-specific DTS (fec1 disabled, pre-reloc markers)
├── configs/
│   ├── kernel_defconfig/
│   │   └── kernel_atk_imx6u_defconfig  Minimal kernel config (incl. USB host)
│   ├── atk_imx6u_min_defconfig         Buildroot config (toolchain + Dropbear + ALSA)
│   ├── kernel-minimal.fragment         Kernel config fragment
│   ├── usb.fragment                    USB host config fragment
│   ├── audio.fragment                  WM8960 audio config fragment (SAI2 + SDMA)
│   ├── lcd.fragment                    LCD + backlight config fragment (DRM mxsfb + fbdev)
│   ├── imximage_NT5CC256M16EP_EK.cfg   U-Boot DCD for Nanya DDR3L-1866
│   ├── uboot_customizations.md         U-Boot customization checklist
│   └── rootfs-overlay/                 Rootfs overlay (hostname, network, SSH keys)
├── scripts/
│   ├── build_kernel.sh              Build kernel + DTBs
│   ├── build_uboot.sh               Build U-Boot
│   ├── build_rootfs.sh              Build Buildroot rootfs
│   ├── deploy.sh                    SCP deploy to board
│   └── uuu_recover_boot0.cmd        UUU emergency recovery for eMMC boot0
├── docs/
│   ├── DevLog_20260727.md           English dev log (Day 1)
│   ├── 歷程紀錄_20260727.md          Chinese dev log (Day 1)
│   ├── DevLog_20260728.md             English dev log (Day 2: SSH + USB)
│   ├── 歷程紀錄_20260728.md            Chinese dev log (Day 2)
│   ├── DevLog_20260729.md             English dev log (Day 3: UART3 + RS-485)
│   ├── 歷程紀錄_20260729.md            Chinese dev log (Day 3)
│   ├── DevLog_20260730.md             English dev log (Day 4: DDR3L + U-Boot DCD)
│   ├── 歷程紀錄_20260730.md            Chinese dev log (Day 4)
│   ├── DevLog_20260731.md             English dev log (Day 5: power chain + U-Boot net fix)
│   ├── 歷程紀錄_20260731.md            Chinese dev log (Day 5)
│   ├── DevLog_20260801.md             English dev log (Day 6: WM8960 audio + playback)
│   ├── 歷程紀錄_20260801.md            Chinese dev log (Day 6)
│   ├── DevLog_20260802.md             English dev log (Day 7: LCD display + GT911 touch)
│   └── 歷程紀錄_20260802.md            Chinese dev log (Day 7)
└── hardware/
    ├── imx6ull-sr8201f-interface.md  Ethernet PHY wiring doc
    ├── lcd-gt911.md                  LCD 40-pin + GT911 touch wiring doc
    ├── pinmux.md                     Pin function table + PHY address map
    └── power-chain.md                Discrete power architecture doc
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
cp configs/audio.fragment linux-imx/
cp configs/lcd.fragment linux-imx/

cd linux-imx
make kernel_atk_imx6u_defconfig

# (Optional) Merge feature fragments: USB host, WM8960 audio, LCD + touch
scripts/kconfig/merge_config.sh -m -O . .config usb.fragment
scripts/kconfig/merge_config.sh -m -O . .config audio.fragment
scripts/kconfig/merge_config.sh -m -O . .config lcd.fragment
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
make mx6ull_14x14_evk_defconfig   # with customizations (see configs/uboot_customizations.md)
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

# IMPORTANT: clean the partition FIRST. Overlay-extracting rootfs.tar onto an
# existing rootfs (busybox tar) silently drops symlinks (/sbin/init,
# /sbin/getty, ...), which bricks boot with "init not found". A clean extract
# avoids the problem. If symlinks are ever lost, rebuild them with:
#   busybox --install -s /sbin /bin /usr/sbin /usr/bin
rm -rf /mnt/*
tar xf rootfs.tar -C /mnt
sync
```

### 6. Boot

Reset the board. U-Boot loads `fdt_file=imx6ull-atk.dtb` automatically.

### 7. Flash U-Boot to eMMC boot0

```bash
# On the board (SSH):
echo 0 > /sys/block/mmcblk1boot0/force_ro
dd if=u-boot-dtb.imx of=/dev/mmcblk1boot0 bs=1K seek=1 conv=fsync
echo 1 > /sys/block/mmcblk1boot0/force_ro
```

> **Always back up boot0 first:**
> `dd if=/dev/mmcblk1boot0 of=boot0_backup.bin bs=1K count=4096`

If the board is bricked, recover via UUU Serial Downloader
(see `scripts/uuu_recover_boot0.cmd`): boot our own U-Boot over SDP, then
write boot0 through the fastboot interface.

## Hardware Peripherals

### Audio (WM8960)

The board has a Wolfson WM8960G codec (SAI2 audio + I2C1 control):

```bash
# Play a 48 kHz WAV file through the speaker
aplay -l                                   # card 0: atkwm8960
amixer cset numid=52 on                    # Left Output Mixer PCM
amixer cset numid=55 on                    # Right Output Mixer PCM
amixer sset 'Speaker' 30%                  # volume
aplay /root/test.wav
```

Mixer settings are restored automatically at boot (`S60alsa-state` +
`alsactl store`). See `docs/DevLog_20260801.md` for the full study and debug
journey (including the SAI2 MCLK direction / IOMUXC_GPR1 fix).

### Display (ATK-MD0700R 7" LCD) & Touch (GT911)

The 7" 1024x600 RGB888 panel is driven by the DRM mxsfb driver with a
pwm-backlight; the GOODIX GT911 controller sits on I2C2 (addr `0x14`):

```bash
# The penguin logo is shown at boot (CONFIG_LOGO) when the display works
ls /dev/fb0                          # /dev/fb0 (mxsfb fbdev emulation)
cat /proc/fb                         # 0 mxsfb-drmdrmfb
cat /sys/class/graphics/fb0/virtual_size   # 1024,600

# Backlight brightness (0..7, 8 levels)
cat /sys/class/backlight/backlight-display/brightness
echo 2 > /sys/class/backlight/backlight-display/brightness

# Touch: read events while touching the screen
dmesg | grep -i goodix               # ID 911, version: 1060
hexdump -C /dev/input/event1         # ABS_MT_POSITION_X/Y reports
```

Key notes:
- The mxsfb DRM driver requires a **graph** binding (`&lcdif` port →
  `panel-dpi` with `panel-timing`); the legacy `display` property is ignored
  on NXP 6.6.
- `/dev/fb0` needs **`CONFIG_FB_DEVICE=y`** on kernel 6.6 (not auto-selected
  by DRM fbdev emulation).
- LCDIF pinctrl uses **`0x49`** (SGM3157 analog switches on DATA7/15/23).
- GT911 probe the I2C bus first: `i2cdetect -y -r 1` → found at `0x14`.

See `hardware/lcd-gt911.md` for the full wiring doc and
`docs/DevLog_20260802.md` for the debug journey.

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
| Jul 30 | DDR3L timing analysis + U-Boot DCD config for NT5CC256M16EP-EK |
| Jul 31 | Power chain analysis + U-Boot network fix: custom U-Boot DTS, UUU crash recovery, phy-reset cross-wiring fix, SR8201F PHY ID verified (0x001CC816), `CONFIG_NET_RANDOM_ETHADDR`, ping OK |
| Aug 01 | WM8960 audio codec study + Linux playback: SAI2/I2C1 wiring verified, ALSA stack (fsl-sai + fsl-asoc-card + wm8960 + SDMA firmware), mixer auto-restore, `aplay` → speaker OK |
| Aug 02 | ATK-MD0700R 7" LCD display + GT911 touch: pin mapping verified (SGM3157 / UM805RE), DRM mxsfb + panel-dpi graph, pwm-backlight, `CONFIG_FB_DEVICE` fix for /dev/fb0, GT911 on I2C2 (0x14), touch events OK |

See the `docs/` folder for detailed development logs. Each session documents the
problems encountered and the solutions implemented.

## Known Issues

- MAC address: OTP fuses are unblown; U-Boot falls back to a random MAC
  (`CONFIG_NET_RANDOM_ETHADDR=y`) unless a fixed `eth1addr` is saved in the
  environment (e.g. `00:1c:c8:00:00:01` → Linux eth0)
- U-Boot fec1 (ENET2) is disabled in the U-Boot DTS (shared-MDIO-bus crash
  workaround); both PHYs still work in Linux
- USB is limited to USB 2.0 (EHCI); USB 3.0 is not supported on this SoC
- UART2 RTS/CTS pins were removed to free pins for UART3 (no hardware flow control on UART2)
- Audio: playback is verified for 48 kHz family rates (MCLK = 12.288 MHz =
  256fs); 44.1 kHz needs a different MCLK/PLL setup
- Display: `/dev/fb0` requires `CONFIG_FB_DEVICE=y` on kernel 6.6; the DRM
  mxsfb driver needs the graph (port → panel-dpi) binding
- Touch: GT911 is at I2C2 address `0x14`; do **not** combine `interrupts`
  with `irq-gpios` on the same GPIO (gpiochip IRQ lock → `-EBUSY`)
- Power management features are disabled in the kernel config
