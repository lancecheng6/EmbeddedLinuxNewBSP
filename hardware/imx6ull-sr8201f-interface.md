# i.MX6ULL ENET2 ↔ SR8201F QFN-32 Interface Design

**Documents Reference:**
- i.MX6ULL: `IMX6ULLIEC.pdf` (Rev. 1.2, 11/2017)
- SR8201F: `SR8201F_VB Datasheet` (Ver 1.1, 2017-11-28)

---

## 1. i.MX6ULL Packages

| Package | Size | Pitch | Suffix |
|---|---|---|---|
| MAPBGA | 14×14 mm | 0.8 mm | VM |
| MAPBGA | 9×9 mm | 0.5 mm | VK |

---

## 2. i.MX6ULL ENET2 Ball Assignments (14×14 mm MAPBGA)

| Signal Name | Ball (14×14) | Power Group | Default Mode | Note |
|---|---|---|---|---|
| ENET2_RX_DATA0 | C17 | NVCC_ENET | ALT5 (GPIO) | RMII: RXD[0] input |
| ENET2_RX_DATA1 | C16 | NVCC_ENET | ALT5 (GPIO) | RMII: RXD[1] input |
| ENET2_RX_EN | B17 | NVCC_ENET | ALT5 (GPIO) | RMII: CRS_DV input |
| ENET2_RX_ER | D16 | NVCC_ENET | ALT5 (GPIO) | RMII: RX_ER input |
| ENET2_TX_CLK | D17 | NVCC_ENET | ALT5 (GPIO) | RMII: REF_CLK (50MHz) input |
| ENET2_TX_DATA0 | A15 | NVCC_ENET | ALT5 (GPIO) | RMII: TXD[0] output |
| ENET2_TX_DATA1 | A16 | NVCC_ENET | ALT5 (GPIO) | RMII: TXD[1] output |
| ENET2_TX_EN | B15 | NVCC_ENET | ALT5 (GPIO) | RMII: TX_EN output |
| NVCC_ENET | J13 | — | — | ENET I/O power supply |

**Other ENET2-related pins:**

| Signal Name | Ball (14×14) | Power Group | Default Mode | Note |
|---|---|---|---|---|
| GPIO1_IO06 | K17 | NVCC_ENET | ALT5 (GPIO) | ALT mode → ENET2_MDIO |
| GPIO1_IO07 | L16 | NVCC_ENET | ALT5 (GPIO) | ALT mode → ENET2_MDC |
| SNVS_TAMPER6 / GPIO5_IO06 | N11 | VDD_SNVS_IN | Keeper | INTB interrupt input from PHY |
| SNVS_TAMPER8 / GPIO5_IO08 | N9 | VDD_SNVS_IN | Keeper | PHYRSTB reset output to PHY |

> **Note:** All ENET2 data pins default to ALT5 (GPIO) at reset. IOMUX must be configured to the appropriate ENET ALT mode before use.

---

## 3. SR8201F QFN-32 Pin Assignments (Verified)

### 3.1 MII / RMII Interface

| Pin | MII Symbol | RMII Symbol | Type | Description |
|:---:|---|---|---|---|
| 1 | RSET | RSET | I | 2.49KΩ ±1% → GND (transmit bias) |
| 2 | AVDD10OUT | AVDD10OUT | O | 1.1V analog output → 0.1µF→GND |
| 3 | MDI+[0] | MDI+[0] | IO | Differential TX+ → RJ45 transformer |
| 4 | MDI-[0] | MDI-[0] | IO | Differential TX- → RJ45 transformer |
| 5 | MDI+[1] | MDI+[1] | IO | Differential RX+ ← RJ45 transformer |
| 6 | MDI-[1] | MDI-[1] | IO | Differential RX- ← RJ45 transformer |
| 7 | AVDD33 | AVDD33 | P | 3.3V analog power |
| 8 | RXDV | RXDV (strap) | LI/O/PD | MII: RXDV output; **Power-on strap: 0=MII, 1=RMII** |
| 9 | RXD[0] | RXD[0] | O/PD | Receive data bit 0 |
| 10 | RXD[1] | RXD[1] | LI/O/PD | Receive data bit 1; also WOL/LED strap |
| 11 | RXD[2] | **INTB** | O/PD | MII: RXD[2]; **RMII: Interrupt output (open-drain)** |
| 12 | RXD[3]/CLK_CTL | CLK_CTL (strap) | LI/O/PD | MII: RXD[3]; **Power-on strap: 0=REF_CLK out, 1=REF_CLK in** |
| 13 | RXC | — | O/PD | MII: Receive clock output; RMII: unused |
| 14 | DVDD33 | DVDD33 | P | 3.3V digital power |
| 15 | TXC | **REF_CLK** | O/PD / IO/PD | MII: TXC output; **RMII: 50MHz REF_CLK (bi-dir)** |
| 16 | TXD[0] | TXD[0] | I/PD | Transmit data bit 0 |
| 17 | TXD[1] | TXD[1] | I/PD | Transmit data bit 1 |
| 18 | TXD[2] | — | I/PD | MII only: transmit data bit 2 |
| 19 | TXD[3] | — | I/PD | MII only: transmit data bit 3 |
| 20 | TXEN | TXEN | I/PD | Transmit enable |
| 21 | **PHYRSTB** | **PHYRSTB** | I/HZ | **Reset (active low), hold ≥10ms** |
| 22 | MDC | MDC | I/PU | Management data clock |
| 23 | MDIO | MDIO | IO/PU | Management data I/O |
| 24 | LED0/PHYAD[0]/PMEB | LED0/PHYAD[0]/PMEB | LI/O/PD | LED / PHY address bit 0 / PMEB |
| 25 | LED1/PHYAD[1] | LED1/PHYAD[1] | LI/O/PD | LED / PHY address bit 1 |
| 26 | CRS/CRS_DV | **CRS_DV** | O/PD | **RMII: Carrier sense / RX data valid** |
| 27 | COL | — | O/PD | MII only: collision detect |
| 28 | RXER/FXEN | **RX_ER** | LI/O/PD | MII: RX_ER; **RMII: RX_ER; Strap: 0=UTP, 1=Fiber** |
| 29 | DVDD10OUT | DVDD10OUT | O | 1.1V digital output → 0.1µF→GND |
| 30 | AVDD33 | AVDD33 | P | 3.3V analog power |
| 31 | CKXTAL1 | CKXTAL1 | I | 25MHz crystal input (GND if external OSC) |
| 32 | CKXTAL2 | CKXTAL2 | IO | 25MHz crystal output / external OSC input |
| E-PAD | GND | GND | P | Exposed pad → GND plane |

---

## 4. Complete Connection Table (RMII Mode)

### 4.1 SR8201F (PHY1 — ENET2) Hardware Strap Configuration

| Pin | Connection | Effect |
|:---:|---|---|
| 8 (RXDV) | 4.7KΩ **pull-high → 3.3V** | Select **RMII mode** |
| 12 (CLK_CTL) | 10KΩ **pull-high → 3.3V** | POR latch = 1 → TXC = **input mode** (no 50MHz output) |
| 24 (LED0/PHYAD[0]) | 4.7KΩ **pull-high → 3.3V** (R23) | PHYAD[0] = **1** |
| 25 (LED1/PHYAD[1]) | 4.7KΩ **pull-low → GND** (R61) | PHYAD[1] = **0** |

**→ PHY Address = (PHYAD[2]=0)(PHYAD[1]=0)(PHYAD[0]=1) = 001 = 0x01**

### 4.2 Data & Control Signals

| i.MX6ULL Signal | Ball (14×14) | I/O Dir | SR8201F Signal | Pin | Description |
|---|---|---|---|---|---|
| ENET2_TX_CLK | D17 | ← input | REF_CLK (TXC) | 15 | 50MHz ±50ppm reference clock |
| ENET2_TX_EN | B15 | → output | TXEN | 20 | Transmit enable |
| ENET2_TX_DATA0 | A15 | → output | TXD[0] | 16 | Transmit data bit 0 |
| ENET2_TX_DATA1 | A16 | → output | TXD[1] | 17 | Transmit data bit 1 |
| ENET2_RX_DATA0 | C17 | ← input | RXD[0] | 9 | Receive data bit 0 |
| ENET2_RX_DATA1 | C16 | ← input | RXD[1] | 10 | Receive data bit 1 |
| ENET2_RX_EN | B17 | ← input | CRS/CRS_DV | 26 | Carrier sense / RX data valid |
| ENET2_RX_ER | D16 | ← input | RXER/FXEN | 28 | Receive error |
| GPIO1_IO07 → **ENET2_MDC** | L16 | → output | MDC | 22 | Management clock |
| GPIO1_IO06 → **ENET2_MDIO** | K17 | ↔ bidir | MDIO | 23 | Management data |

### 4.3 Control & Auxiliary Signals

| i.MX6ULL Signal | Ball (14×14) | I/O Dir | SR8201F Signal | Pin | Description |
|---|---|---|---|---|---|
| GPIO5_IO06 (SNVS_TAMPER6) | N11 | ← input | INTB (RXD[2]) | 11 | PHY interrupt (open-drain, 4.7KΩ pull-up) |
| GPIO5_IO08 (SNVS_TAMPER8) | N9 | → output | PHYRSTB | 21 | PHY reset (active low, hold ≥10ms) |

### 4.4 Power & Passives

| Function | SR8201F Pin | Connection |
|---|---|---|
| Transmit bias | 1 (RSET) | 2.49KΩ ±1% → GND |
| Analog 3.3V | 7, 30 (AVDD33) | 3.3V + decoupling caps |
| Digital 3.3V | 14 (DVDD33) | 3.3V + decoupling cap |
| 1.1V analog out | 2 (AVDD10OUT) | 0.1µF ceramic → GND |
| 1.1V digital out | 29 (DVDD10OUT) | 0.1µF ceramic → GND |
| 25MHz crystal | 31, 32 (CKXTAL1/2) | 25MHz crystal + load caps |
| Ground | E-PAD | GND plane |

### 4.5 RJ45 Interface

| SR8201F Pin | Signal | To RJ45 |
|:---:|---|---|
| 3 | MDI+[0] | TX+ (transformer center tap) |
| 4 | MDI-[0] | TX- (transformer center tap) |
| 5 | MDI+[1] | RX+ (transformer center tap) |
| 6 | MDI-[1] | RX- (transformer center tap) |

---

## 5. Second SR8201F QFN-32 ↔ i.MX6ULL ENET1 (RMII)

### 5.1 Hardware Strap Configuration

| Pin | Connection | Effect |
|:---:|---|---|
| 8 (RXDV) | 4.7KΩ **pull-high → 3.3V** | Select **RMII mode** |
| 12 (CLK_CTL) | 10KΩ **pull-high → 3.3V** | POR latch = 1 → TXC = **input mode** (no 50MHz output) |
| 24 (LED0/PHYAD[0]) | 4.7KΩ **pull-low → GND** (R13) | PHYAD[0] = **0** |
| 25 (LED1/PHYAD[1]) | 4.7KΩ **pull-high → 3.3V** (R60) | PHYAD[1] = **1** |

**→ PHY Address = (PHYAD[2]=0)(PHYAD[1]=1)(PHYAD[0]=0) = 010 = 0x02**

### 5.2 Data & Control Signals

| i.MX6ULL Signal | Ball (14×14) | I/O Dir | SR8201F Signal | Pin | Description |
|---|---|---|---|---|---|
| ENET1_TX_CLK | F14 | ← input | REF_CLK (TXC) | 15 | 50MHz ±50ppm reference clock |
| ENET1_TX_EN | F15 | → output | TXEN | 20 | Transmit enable |
| ENET1_TX_DATA0 | E15 | → output | TXD[0] | 16 | Transmit data bit 0 |
| ENET1_TX_DATA1 | E14 | → output | TXD[1] | 17 | Transmit data bit 1 |
| ENET1_RX_DATA0 | F16 | ← input | RXD[0] | 9 | Receive data bit 0 |
| ENET1_RX_DATA1 | E17 | ← input | RXD[1] | 10 | Receive data bit 1 |
| ENET1_RX_EN | E16 | ← input | CRS/CRS_DV | 26 | Carrier sense / RX data valid |
| ENET1_RX_ER | D15 | ← input | RXER/FXEN | 28 | Receive error |
| GPIO1_IO07 → **ENET_MDC** | **L16** (shared) | → output | MDC | 22 | Management clock (shared with PHY1) |
| GPIO1_IO06 → **ENET_MDIO** | **K17** (shared) | ↔ bidir | MDIO | 23 | Management data (shared with PHY1) |

### 5.3 Control & Auxiliary Signals

| i.MX6ULL Signal | Ball (14×14) | I/O Dir | SR8201F Signal | Pin | Description |
|---|---|---|---|---|---|
| GPIO5_IO07 (SNVS_TAMPER7) | N10 | → output | PHYRSTB | 21 | PHY reset (active low, hold ≥10ms) |
| GPIO5_IO05 (SNVS_TAMPER5) | N8 | ← input | INTB (RXD[2]) | 11 | PHY interrupt (open-drain, 4.7KΩ pull-up) |

### 5.4 Power & Passives

Identical to PHY1 (Section 4.4).

### 5.5 PHY Address Reference

| PHY | MAC | PHYAD[2] | PHYAD[1] | PHYAD[0] | Address | Pin24 Strap | Pin25 Strap |
|---|---|---|---|---|---|---|---|
| **PHY1** | ENET2 | 0 | **0** | **1** | **0x01** | Pull-high (R23) | Pull-low (R61) |
| **PHY2** | ENET1 | 0 | **1** | **0** | **0x02** | Pull-low (R13) | Pull-high (R60) |

---

## 6. Key Discussion Points

### 6.1 RMII vs MII Mode

SR8201F QFN-32 has no TXER pin, making MII less functional. RMII is the recommended mode, using only 2 data bits each direction (TXD[1:0], RXD[1:0]) with a shared 50MHz reference clock.

### 6.2 50MHz REF_CLK Direction

- **Pin 12 (CLK_CTL)** is latched at POR to determine TXC direction:
  - Floating / Low → TXC = **output** (PHY generates 50MHz)
  - High → TXC = **input** (external 50MHz needed)
- On this board: CLK_CTL is pull-high, so TXC is **input** by default
- Software can override via **P7R16 bit12 (Rg_rmii_clkdir)**: write 0 after boot to switch TXC to output

### 6.3 SR8201F P7R16 (RMII Mode Setting Register)

| Bit | Name | Description | Default |
|:---:|---|---|---|
| 12 | Rg_rmii_clkdir | **0** = TXC output, **1** = TXC input (latched from CLK_CTL) | 0 |
| 11:8 | Rg_rmii_tx_offset | Adjust RMII TX timing | 1111 |
| 7:4 | Rg_rmii_rx_offset | Adjust RMII RX timing | 1111 |
| 2 | Rg_rmii_rxdv_sel | **0** = CRS_DV signal, **1** = RXDV signal | 0 |
| 1 | Rg_rmii_rxdsel | **0** = RMII data only, **1** = RMII data with SSD error | 1 |

**Access sequence:**
```
1. MDIO Write Reg 31 = 0x07    // Select Page 7
2. MDIO Read/Write Reg 16      // Access RMSR
3. MDIO Write Reg 31 = 0x00    // Restore Page 0
```

### 6.4 Pin 11 (INTB) — PHY Interrupt

- In RMII mode, pin 11 functions as **INTB** (open-drain, active low)
- Trigger events (Register 30):
  - **Bit 15**: Auto-Negotiation error
  - **Bit 14**: Speed change (10M↔100M)
  - **Bit 13**: Duplex change (Half↔Full)
  - **Bit 11**: Link status change (UP↔DOWN)
- Mask control: P7R19 bits [13:11]
- Connected to SoC N11 (SNVS_TAMPER6 / GPIO5_IO06) — a VDD_SNVS_IN domain GPIO suitable for wakeup

### 6.5 Pin 21 (PHYRSTB) — PHY Reset

- Active low, hold **≥10ms** for valid reset
- Connected to SoC N9 (SNVS_TAMPER8 / GPIO5_IO08)
- Using SNVS domain GPIO ensures reset capability even in low-power modes

### 6.6 Default Pin State at Reset (i.MX6ULL)

All ENET2 pins default to **ALT5 (GPIO)** mode. The following IOMUX configuration is required:

| Pin | ALT Mode | Function |
|---|---|---|
| D17, B15, A15, A16 | ENET ALT | ENET2 TX signals |
| C17, C16, B17, D16 | ENET ALT | ENET2 RX signals |
| K17 (GPIO1_IO06) | ENET ALT | ENET2_MDIO |
| L16 (GPIO1_IO07) | ENET ALT | ENET2_MDC |

### 6.7 SR8201F Startup Sequence

```
Power-On Reset
├─ Pin 12 = High → Rg_rmii_clkdir latch = 1 → TXC = Input (no clock output)
├─ Pin 8 = High → RMII mode selected
│
├─ SoC boots
│  ├─ IOMUX: configure ENET2 pins to ENET ALT mode
│  ├─ PHY reset: N9 → PHYRSTB low ≥10ms → release
│  │
│  ├─ MDC/MDIO: initialize management interface
│  ├─ MDIO: Write Reg31=0x07 → Write Reg16 bit12=0 → TXC=Output (50MHz)
│  ├─ MDIO: Write Reg31=0x00 (restore Page 0)
│  │
│  └─ 50MHz REF_CLK flows: SR8201F Pin15 → i.MX6ULL D17
│
└─ ENET2 operational
```

### 6.8 Power Supply Notes

- The i.MX6ULL ENET I/O operates in the **NVCC_ENET** domain (ball J13)
- All ENET2 data pins (C17, C16, B17, D16, D17, A15, A16, B15) plus GPIO1_IO06/IO07 share NVCC_ENET
- SNVS_TAMPER pins (N9, N11) are in the **VDD_SNVS_IN** domain, independently powered

---

## 7. Reference Diagrams

### 7.1 RMII Mode Timing (Figure 48 from IMX6ULLIEC)

```
      ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐
REF_CLK  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──
50MHz  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑

CRS_DV ──────────────────────────────────────
       ╰─────────── receiving frame ─────────╯

RXD[1:0] ══════╗  ╔═[DATA]═╗  ╔══════════════
                ╙──╜        ╙──╜
```

### 7.2 System Block Diagram

```
┌─────────────────────┐         ┌──────────────────┐
│   i.MX6ULL (SoC)    │         │ SR8201F (PHY)    │
│                     │         │ QFN-32            │
│  ENET2_TX_CLK (D17) │◄───────│ TXC (15)          │
│  ENET2_TX_EN (B15)  │────────│ TXEN (20)         │
│  ENET2_TXD0 (A15)   │────────│ TXD[0] (16)       │
│  ENET2_TXD1 (A16)   │────────│ TXD[1] (17)       │
│  ENET2_RXD0 (C17)   │◄───────│ RXD[0] (9)        │
│  ENET2_RXD1 (C16)   │◄───────│ RXD[1] (10)       │
│  ENET2_RX_EN (B17)  │◄───────│ CRS_DV (26)       │
│  ENET2_RX_ER (D16)  │◄───────│ RXER (28)         │
│                     │         │                    │
│  GPIO1_IO07 (L16)   │────────│ MDC (22)           │
│  GPIO1_IO06 (K17)   │◄──────►│ MDIO (23)          │
│                     │         │                    │
│  GPIO5_IO08 (N9)    │────────│ PHYRSTB (21)       │
│  GPIO5_IO06 (N11)   │◄───────│ INTB (11)          │
└─────────────────────┘         └────────┬──────────┘
                                         │
                                    ┌────┴────┐
                                    │  RJ45   │
                                    │ + Magn. │
                                    └─────────┘
```

---

## 5. PHY Identifier (Verified on Hardware)

**SR8201F PHY ID = `0x001C_C816`** — measured over MDIO and confirmed against
the datasheet (SR8201F_VB, Table 13/14):

| Register | Field | Datasheet Default | Measured |
|----------|-------|:-----------------:|:--------:|
| reg2 (PHYID1) | OUI[21:6] | `0x001C` | `0x001C` ✅ |
| reg3 (PHYID2) | OUI_LSB + Model + Rev | `110010_000001_0110` | `0xC816` ✅ |

> **Note:** the Linux FEC driver reports `0x00110140`, which does NOT match the
> datasheet value. Functionality is unaffected (generic PHY driver is used),
> but the datasheet is the authoritative reference.

## 6. MDIO / MDC IOMUX PAD Configuration (Verified)

| Pad | SW_PAD_CTL Register | Value | Meaning |
|-----|---------------------|-------|---------|
| GPIO1_IO06 (MDIO) | `0x020E0300` | `0x1b0b0` | SPEED=3, **ODE=1 (open-drain)**, DSE=2, PUS=3 |
| GPIO1_IO07 (MDC) | `0x020E0304` | `0x1b0b0` | SPEED=3, DSE=2, PUS=3 |

MDIO is an **open-drain bidirectional** line: `ODE=1` is required so the MAC
releases the line and the PHY can pull it low during the read turnaround and
data phase. (In U-Boot, the default pin-mux is already `ALT1 = ENET2_MDIO/MDC`
at reset, but the PAD must be configured with `0x1b0b0` — the pinctrl group in
the official dtsi already does this.)
