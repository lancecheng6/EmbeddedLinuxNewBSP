# ATK-IMX6U Pin Function Table

## Ethernet (ENET2 = fec2 = eth1)

Uses SR8201F PHY in RMII mode.

### Data & Control Signals

| i.MX6ULL Signal | Ball (14x14) | Dir | SR8201F Pin | Pin Name |
|----------------|-------------|-----|-------------|----------|
| ENET2_TX_CLK   | D17         | ←   | 15          | REF_CLK  |
| ENET2_TX_EN    | B15         | →   | 20          | TXEN     |
| ENET2_TX_DATA0 | A15         | →   | 16          | TXD[0]   |
| ENET2_TX_DATA1 | A16         | →   | 17          | TXD[1]   |
| ENET2_RX_DATA0 | C17         | ←   | 9           | RXD[0]   |
| ENET2_RX_DATA1 | C16         | ←   | 10          | RXD[1]   |
| ENET2_RX_EN    | B17         | ←   | 26          | CRS_DV   |
| ENET2_RX_ER    | D16         | ←   | 28          | RX_ER    |

### Management Interface

| i.MX6ULL Signal | Ball (14x14) | Dir | SR8201F Pin | Description |
|----------------|-------------|-----|-------------|-------------|
| GPIO1_IO06     | K17         | ↔   | 23          | MDIO        |
| GPIO1_IO07     | L16         | →   | 22          | MDC         |

### Control Signals

| i.MX6ULL Signal | Ball (14x14) | Dir | SR8201F Pin | Description |
|----------------|-------------|-----|-------------|-------------|
| GPIO5_IO06 (SNVS_TAMPER6) | N11 | ← | 11 | INTB (PHY interrupt) |
| GPIO5_IO08 (SNVS_TAMPER8) | N9  | → | 21 | PHYRSTB (PHY reset)   |

## Ethernet (ENET1 = fec1 = eth0)

| i.MX6ULL Signal | Ball (14x14) | Dir | SR8201F Pin | Pin Name |
|----------------|-------------|-----|-------------|----------|
| ENET1_TX_CLK   | F14         | ←   | 15          | REF_CLK  |
| ENET1_TX_EN    | F15         | →   | 20          | TXEN     |
| ENET1_TX_DATA0 | E15         | →   | 16          | TXD[0]   |
| ENET1_TX_DATA1 | E14         | →   | 17          | TXD[1]   |
| ENET1_RX_DATA0 | F16         | ←   | 9           | RXD[0]   |
| ENET1_RX_DATA1 | E17         | ←   | 10          | RXD[1]   |
| ENET1_RX_EN    | E16         | ←   | 26          | CRS_DV   |
| ENET1_RX_ER    | D15         | ←   | 28          | RX_ER    |

### Control Signals

| i.MX6ULL Signal | Ball (14x14) | Dir | SR8201F Pin | Description |
|----------------|-------------|-----|-------------|-------------|
| GPIO5_IO07 (SNVS_TAMPER7) | N10 | → | 21 | PHYRSTB (PHY reset) |
| GPIO5_IO05 (SNVS_TAMPER5) | N8  | ← | 11 | INTB (PHY interrupt) |

## PHY Address Configuration

Both SR8201F PHYs share the same MDC/MDIO bus (GPIO1_IO06/IO07).
Each PHY's address is set by hardware straps on pins 24-25.

| PHY   | MAC   | PHYAD[2] | PHYAD[1] | PHYAD[0] | Address | Pin24 Strap | Pin25 Strap |
|-------|-------|----------|----------|----------|---------|-------------|-------------|
| PHY1  | ENET2 | 0        | **0**    | **1**    | **0x01**| Pull-high (R23) | Pull-low (R61)  |
| PHY2  | ENET1 | 0        | **1**    | **0**    | **0x02**| Pull-low (R13)  | Pull-high (R60) |

## Serial Console (UART1 = ttymxc0)

| i.MX6ULL Signal | Ball | Dir |
|----------------|------|-----|
| UART1_TXD      | J15  | →   |
| UART1_RXD      | J16  | ←   |

## eMMC

| i.MX6ULL Signal | Description |
|----------------|-------------|
| usdhc2         | eMMC (mmcblk1), 8-bit, non-removable |

## Boot Config

| Signal | Setting |
|--------|---------|
| BOOT_MODE[1:0] | 10 (Serial Downloader → eMMC) |
| BOOT_CFG1[3:0] | 0010 (MMC/eMMC) |
| BOOT_CFG2[3:0] | 1000 (MMC port 2 = usdhc2) |
