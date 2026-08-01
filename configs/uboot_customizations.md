# U-Boot Customizations for ATK-IMX6U

This document tracks every customization applied to the NXP
`lf_v2023.04` U-Boot so the build is fully reproducible.

Base: `mx6ull_14x14_evk_defconfig` (i.MX6ULL 14x14 EVK)

```
git clone --depth 1 --branch lf_v2023.04 https://github.com/nxp-imx/uboot-imx.git
```

---

## 1. Custom Device Tree (`arch/arm/dts/imx6ull-atk.dts`)

Own minimal board DTS for U-Boot (see `DTS/imx6ull-atk-uboot.dts` in this repo):

- `#include "imx6ul-14x14-evk-u-boot.dtsi"` (U-Boot pre-reloc markers)
- UART1 / UART2 (no RTS/CTS) / UART3 (RS-485, no DMA) / eMMC (usdhc2)
- **fec1 disabled** (`status = "disabled"`) — workaround for the shared MDIO
  bus crash (`undefined instruction` after `Get shared mii bus`)
- `phy-reset-gpios` fixed per schematic J2:
  - `fec1` → `<&gpio5 8>` (ENET2_RST = TAMPER8)
  - `fec2` → `<&gpio5 7>` (ENET1_RST = TAMPER7)
- UART2 RTS/CTS pins removed to free pins for UART3

Registration:

- `arch/arm/dts/Makefile` → add `imx6ull-atk.dtb`
- `configs/mx6ull_14x14_evk_defconfig` →
  `CONFIG_DEFAULT_DEVICE_TREE="imx6ull-atk"`

## 2. DDR3L DCD (`board/freescale/mx6ullevk/imximage.cfg`)

Replaced with timing for the **Nanya NT5CC256M16EP-EK** (DDR3L-1866).
The exact file lives in this repo: `configs/imximage_NT5CC256M16EP_EK.cfg`.

```bash
cp configs/imximage_NT5CC256M16EP_EK.cfg \
   uboot-imx/board/freescale/mx6ullevk/imximage.cfg
```

## 3. Default DTB (`include/configs/mx6ullevk.h`)

Line 89: `fdt_file=undefined` → `fdt_file=imx6ull-atk.dtb`

The NXP `findfdt` logic only overrides `fdt_file` when it is `undefined`,
so the board always loads our DTB (even after the environment is wiped).

## 4. defconfig Additions (`configs/mx6ull_14x14_evk_defconfig`)

```kconfig
CONFIG_DEFAULT_DEVICE_TREE="imx6ull-atk"
CONFIG_CMD_MII=y                  # manual MDIO debug
CONFIG_NET_RANDOM_ETHADDR=y       # random MAC fallback (OTP unblown)
```

## 5. Boot Environment

```text
setenv eth1addr 00:1c:c8:00:00:01   # fixed MAC for fec2 (eth1)
setenv ipaddr 192.168.1.100
saveenv
```

## 6. Build

```bash
export PATH=/path/to/buildroot/output/host/bin:$PATH
make mx6ull_14x14_evk_defconfig
make CROSS_COMPILE=arm-buildroot-linux-gnueabihf- -j$(nproc)
# output: u-boot-dtb.imx
```

## 7. Flash to eMMC boot0

```bash
echo 0 > /sys/block/mmcblk1boot0/force_ro
dd if=u-boot-dtb.imx of=/dev/mmcblk1boot0 bs=1K seek=1 conv=fsync
echo 1 > /sys/block/mmcblk1boot0/force_ro
```

or via UUU (Serial Downloader) — see `scripts/uuu_recover_boot0.cmd`.

> **Always back up boot0 first:**
> `dd if=/dev/mmcblk1boot0 of=boot0_backup.bin bs=1K count=4096`
