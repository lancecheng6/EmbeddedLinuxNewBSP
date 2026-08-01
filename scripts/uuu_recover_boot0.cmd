# UUU script — Emergency recovery of eMMC boot0 for ATK-IMX6U
#
# Usage:
#   1. Set BOOT_MODE switches to Serial Downloader, connect USB OTG, power on.
#   2. Put this script (as "uuu.auto") together with the following files in
#      one directory:
#        _flash.bin  - a working U-Boot image with DDR3L DCD
#                      (e.g. a known-good u-boot-dtb.imx)
#        boot0.bin   - the 4 MB boot0 image to write:
#                         dd if=/dev/zero of=boot0.bin bs=1K count=4096
#                         dd if=u-boot-dtb.imx of=boot0.bin bs=1K seek=1 conv=notrunc
#   3. Run from that directory:  uuu.exe  (libuuu auto-loads uuu.auto)
#
# The SDP stage boots our own U-Boot, which then exposes fastboot;
# the FB stage selects the eMMC boot0 hardware partition and writes 4 MB
# (0x2000 blocks) from the download buffer at 0x83800000.
#
# NOTE: "FB: flash bootloader" is NOT used — it requires
# CONFIG_FASTBOOT_MMC_BOOT_SUPPORT which is not enabled.

uuu_version 1.2.39

SDP: boot -f _flash.bin

FB: ucmd mmc dev 1 1
FB: download -f boot0.bin
FB: ucmd mmc write 0x83800000 0x0 0x2000
FB: ucmd mmc dev 1 0
FB: done
