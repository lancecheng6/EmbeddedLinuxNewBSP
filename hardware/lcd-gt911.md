# i.MX6ULL ↔ ATK-MD0700R LCD + GT911 Touch Interface (ATK-IMX6U)

**Devices:**
- **Display:** ATK-MD0700R V1.4 — 7.0" TFT, 1024×600, RGB888 (24-bit) parallel
  RGB interface with integrated PWM backlight
- **Touch:** GOODIX **GT911G** capacitive touch controller (integrated on the
  display FPC, connected via I2C)
- **Board:** ATK-IMX6U (i.MX6ULL core board + ALPHA baseboard V2.4)

---

## 1. LCD Interface (40-pin RGBLCD Connector)

The display connects through the 40-pin RGBLCD connector on the baseboard.
Verified against the baseboard schematic.

| Function | Signal | i.MX6ULL Ball | IOMUX |
|:---|:---|:---|:---|
| RGB data | LCD_DATA0–23 | (24 pins) | LCDIF_DATA00–23 |
| Pixel clock | LCD_CLK | | LCDIF_CLK |
| Data enable | LCD_ENABLE | | LCDIF_ENABLE |
| Horizontal sync | LCD_HSYNC | | LCDIF_HSYNC |
| Vertical sync | LCD_VSYNC | | LCDIF_VSYNC |
| Backlight PWM | BLT_PWM | N17 | GPIO1_IO08 / PWM1_OUT |
| Touch I2C clock | TSC_SCL | F17 | UART5_TXD / I2C2_SCL / GPIO1_IO30 |
| Touch I2C data | TSC_SDA | G13 | UART5_RXD / I2C2_SDA / GPIO1_IO31 |
| Touch interrupt | CT_INT | M15 | GPIO1_IO09 |
| Touch reset | CT_RST | R6 | SNVS_TAMPER9 / GPIO5_IO09 |
| LCD reset | RESET (pin 40) | — | **UM805RE POR IC output** (not tied to the SoC) |

### 1.1 SGM3157 Analog Switches

The RGB data lines `LCD_DATA7`, `LCD_DATA15` and `LCD_DATA23` (and the sync
group) are routed through **SGM3157** analog switches on the baseboard, shared
with the Ethernet/NAND bus. Consequences:

- **Drive strength must be lowered**: the LCDIF pinctrl pad values use
  **`0x49`** instead of the stock NXP `0x79`, otherwise the fast-switching LCD
  bus couples into the network bus (manual chapter 59 recommendation).
- The DTS defines distinct pinctrl groups (`pinctrl_lcdif_dat_atk` /
  `pinctrl_lcdif_ctrl_atk`) to avoid clashing with the stock EVK groups.

### 1.2 LCD Reset (UM805RE)

Pin 40 (RESET) is driven by a **UM805RE** power-on-reset supervisor IC — it
is not connected to any SoC GPIO. Therefore the LCDIF reset pinctrl entry is
omitted and no reset GPIO is requested.

### 1.3 Backlight (PWM1)

`BLT_PWM` → `GPIO1_IO08` → **PWM1_OUT**. The kernel exposes it through a
`pwm-backlight` node (`backlight-display`, supplied by the NXP dtsi):

```
pwms = <&pwm1 0 5000000>;                    /* 200 Hz */
brightness-levels = <0 4 8 16 32 64 128 255>; /* 8 levels */
default-brightness-level = <6>;
```

---

## 2. Panel Timing

From the display datasheet (RGB888, 24-bit):

| Parameter | Value |
|:---|:---|
| Pixel clock | 51.2 MHz |
| Active area | 1024 × 600 |
| H front porch / back porch / sync len | 160 / 140 / 20 |
| V front porch / back porch / sync len | 12 / 20 / 3 |
| hsync-active / vsync-active | 0 (low) |
| de-active | 1 (high) |
| pixelclk-active | 0 (falling) |

DTS binding: generic `panel-dpi` (panel-simple driver) with a `panel-timing`
node, connected to the mxsfb DRM driver through a graph port:

```
&lcdif → port → endpoint → remote-endpoint → panel-dpi.port
```

---

## 3. GT911 Touch Interface

| GT911 signal | SoC pin | i.MX6ULL ball | IOMUX |
|:---|:---|:---|:---|
| SCL (I2C) | TSC_SCL | F17 | UART5_TXD / I2C2_SCL / GPIO1_IO30 |
| SDA (I2C) | TSC_SDA | G13 | UART5_RXD / I2C2_SDA / GPIO1_IO31 |
| INT | CT_INT | M15 | GPIO1_IO09 |
| RST | CT_RST | R6 | SNVS_TAMPER9 / GPIO5_IO09 |

- Touch controller is on **I2C2** (21a4000.i2c), driven by the goodix driver
  (`CONFIG_TOUCHSCREEN_GOODIX=y`).
- **Interrupt:** `interrupts = <9 IRQ_TYPE_EDGE_FALLING>` on GPIO1.
  *Note:* do **not** combine `interrupts` with `irq-gpios` on the same GPIO —
  the IRQ lock makes the GPIO request fail with `-EBUSY` on this kernel.
- **Reset:** `reset-gpios = <&gpio5 9 GPIO_ACTIVE_LOW>` (CT_RST). GT911 has an
  internal POR; the reset GPIO is held as input after probe.

### 3.1 I2C Address Discovery

The GT911 answers at `0x14` or `0x5d` depending on the INT line state during
reset — probe the bus before writing the DTS:

```
$ i2cdetect -y -r 1            # i2c-1 = 21a4000.i2c = I2C2
10: -- -- -- -- 14 -- -- -- -- -- -- -- -- -- -- --
→ GT911 found at 0x14 → DTS: reg = <0x14>
```

### 3.2 GPIO Conflict Warning

The stock NXP EVK DTS uses `GPIO1_IO09` as **SD1 RESET** in
`pinctrl_usdhc1`. On this board the pin is **CT_INT**, so a custom
`pinctrl_usdhc1_atk` group (without GPIO1_IO09) is applied to `&usdhc1`.

### 3.3 Display Noise Fix (2026-08-03)

**Symptom:** colored dots (white/yellow) on image lines + text jittering
horizontally.

**Debug method (systematic exclusion):**

| Test | Result | Conclusion |
|------|--------|-----------|
| Solid red written to fb0 | clean | LCD/fb fine |
| BMP pixel analysis (isolated/yellow dots) | clean | image fine |
| 8-px checkerboard (high-contrast edges) | clean | block-level sampling OK |
| **fb0 screenshot captured → viewed on PC** | **clean** | **software rendering 100% fine** |

→ The framebuffer content is perfect but the physical screen shows dots:
corruption happens **between eLCDIF and the LCD driver IC** — PCLK sampling
edge / signal-integrity during rapid data transitions (crosstalk, slew).

**Fix (two-stage):**

| Attempt | Change | Result |
|---------|--------|--------|
| 1. Invert PCLK sampling edge | `pixelclk-active = <0>` → `<1>` | ~50% improvement; **jitter gone** |
| 2. Stronger pad drive + SRE | LCDIF dat/ctrl pinctrl `0x49` → `0x1b0b0` | **fully clean** |

Note: `0x49` is the manual's SGM3157-recommended low drive; combined with
`pixelclk-active=<1>` (sampling phase off the unstable transition zone) and
`0x1b0b0` (faster slew, stronger drive) the edges are sharp enough.

---

## 4. Verification Summary

```
$ dmesg | grep -i -e mxsfb -e panel
[1.69] [drm] Initialized mxsfb-drm 1.0.0 for 21c8000.lcdif
[1.71] mxsfb 21c8000.lcdif: [drm] fb0: mxsfb-drmdrmfb frame buffer device

$ dmesg | grep -i goodix
Goodix-TS 1-0014: ID 911, version: 1060
input: Goodix Capacitive TouchScreen ...

$ ls /dev/fb0 && cat /proc/fb
0 mxsfb-drmdrmfb

$ hexdump -C /dev/input/event1     # finger press → ABS_MT_POSITION_X/Y
```

Bootup Linux logo (penguin) is shown at top-left; backlight brightness is
adjustable via `/sys/class/backlight/backlight-display/brightness`; touch
reports correct coordinates.
