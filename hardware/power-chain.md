# ATK-IMX6U Power Chain (Discrete Power Solution)

**Scope:** Understand the core-board power architecture, the power-on
sequencing, and what the software (U-Boot / Linux) can and cannot control.

---

## 1. Overview

The ATK-IMX6U core board does **not** use an I2C-controlled PMIC. Every rail is
produced by a standalone regulator. This has a direct consequence for the BSP:
**U-Boot has no PMIC to configure** — `CONFIG_DM_PMIC` stays disabled and the
DDR DCD (imximage.cfg) only touches the MMDC controller.

```
[DC5V input]
   ├── U7 (ME6209A33M3G LDO) ──► VDD_SNVS_3V3 ──► SoC SNVS domain (RTC / low-power)
   │                                    │
   │                        SoC asserts PMIC_ON_REQ in hardware
   │                                    ▼
   ├── U8 (TMI3113 DCDC) ◄── EN pin  ──► DCDC_3V3 (main 3.3V)
   │                                    │
   │                        DCDC_3V3_PG (Power Good)
   │                                    ▼
   ├── U6 (MT3420B) ──► SOC_IN (1.2V, ARM core)
   ├── U11 (MT3420B) ──► DRAM_1V35 (1.35V, DDR3L)
   ├── U9 (TMI6050) ──► VCC_SD (3.3V)
   └── U12 (XC6206P282MR) ──► NVCC_CSI (2.8V)
```

## 2. Power-On Sequence

1. DC5V applied → U7 (LDO) powers the **SNVS domain** first.
2. The SNVS hardware state machine asserts **`PMIC_ON_REQ`** — pure hardware,
   no CPU code involved (solves the "chicken-and-egg" problem: the SoC cannot
   run before the rails exist).
3. U8 (TMI3113 DCDC) is enabled via its EN pin → **DCDC_3V3** (main 3.3V).
4. DCDC_3V3_PG (power good) enables the downstream regulators via their EN
   pins:
   - U6 → **SOC_IN** (1.2V core)
   - U11 → **DRAM_1V35** (DDR3L)
   - U9 → **VCC_SD** (3.3V)
   - U12 → **NVCC_CSI** (2.8V)
5. **MAX809R** (reset supervisor) monitors 3.3V; after it is stable it releases
   `POR_B` with ~140 ms delay → SoC starts reset release.

## 3. Regulator Summary

| Ref | Part | Type | Output | Enable Source | I2C? |
|-----|------|------|--------|---------------|:----:|
| U7  | ME6209A33M3G | LDO | VDD_SNVS_3V3 | — | no |
| U8  | TMI3113 | DCDC | DCDC_3V3 (3.3V) | `PMIC_ON_REQ` | no |
| U6  | MT3420B | DCDC | SOC_IN (1.2V) | DCDC_3V3_PG | no |
| U11 | MT3420B | DCDC | DRAM_1V35 (1.35V) | DCDC_3V3_PG | no |
| U9  | TMI6050 | DCDC | VCC_SD (3.3V) | DCDC_3V3_PG | no |
| U12 | XC6206P282MR | LDO | NVCC_CSI (2.8V) | DCDC_3V3_PG | no |

## 4. Software Power-Off

To shut down the main power domain in software, the CPU writes
`SNVS_LPCR` to **deassert `PMIC_ON_REQ`**. Only the SNVS domain (RTC, tamper
monitoring) remains powered.

## 5. Notes for the BSP

- **U-Boot:** `CONFIG_DM_PMIC` not needed. Flashing a U-Boot with a different
  DDR DCD is safe — it only changes MMDC initialization data.
- **Linux:** the regulators are not exposed to the kernel (no regulator
  framework binding needed); the DTS uses fixed regulators only.
- **MT3420B** is a pure analog buck (SOT23-6, no register interface). It is
  controlled solely by its EN pin (hardwired to `DCDC_3V3_PG`);
  `VOUT = 0.6V × (1 + R1/R2)`.
