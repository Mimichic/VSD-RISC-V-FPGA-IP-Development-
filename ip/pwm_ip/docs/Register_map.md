# Register Map — Single-Channel PWM IP

**Base Address:** `0x400040` (`IO_PWM_bit = 4`, 1-hot decoded)

The PWM IP occupies a 16-byte memory footprint with four 32-bit word-aligned registers.

---

## Register Summary

| Offset | Register Name | R/W | Reset Value | Description |
|--------|--------------|-----|-------------|-------------|
| `0x00` | `PWM_CTRL` | R/W | `0x00000000` | Control register for Enable and Polarity |
| `0x04` | `PWM_PERIOD` | R/W | `0x00000064` | Total PWM period in system clock ticks |
| `0x08` | `PWM_DUTY` | R/W | `0x00000000` | High-time of the PWM cycle in clock ticks |
| `0x0C` | `PWM_STATUS` | R | `0x00000000` | Read-only status flag and current counter value |

---

## Register Definitions

### PWM_CTRL (Offset `0x00`)

Controls the fundamental operation of the PWM engine.

| Bit(s) | Name | R/W | Reset | Description |
|--------|------|-----|-------|-------------|
| 31:2 | RESERVED | R | `0` | Reserved. Reads as 0. Write ignored. |
| 1 | POL | R/W | `0` | Polarity. `0` = Active-High (output HIGH when `counter < duty`). `1` = Active-Low (output LOW when `counter < duty`). |
| 0 | EN | R/W | `0` | Enable. `1` = PWM engine running. `0` = engine stopped, output forced to inactive state. |

---

### PWM_PERIOD (Offset `0x04`)

Defines the total length of one PWM cycle in system clock ticks.

| Bit(s) | Name | R/W | Reset | Description |
|--------|------|-----|-------|-------------|
| 31:0 | PERIOD | R/W | `0x64` (100) | Internal counter counts from `0` to `PERIOD - 1`. Must be `>= 1`. Setting to `0` produces undefined behaviour. |

**PWM Frequency Formula:**
```
PWM_Frequency = System_Clock / PERIOD
```

---

### PWM_DUTY (Offset `0x08`)

Defines the active threshold of the PWM cycle.

| Bit(s) | Name | R/W | Reset | Description |
|--------|------|-----|-------|-------------|
| 31:0 | DUTY | R/W | `0x00` | Number of clock ticks the output is active per period. |

**Boundary Conditions:**

| Condition | Behaviour |
|-----------|-----------|
| `DUTY == 0` | Output always inactive (0% duty cycle) |
| `DUTY >= PERIOD` | Output always active (100% duty cycle) |
| `0 < DUTY < PERIOD` | Normal PWM operation |

**Duty Cycle Formula:**
```
Duty_Cycle (%) = (DUTY / PERIOD) × 100
```

---

### PWM_STATUS (Offset `0x0C`)

Read-only register. Allows software to poll the current state of the IP.

| Bit(s) | Name | R/W | Reset | Description |
|--------|------|-----|-------|-------------|
| 31:16 | COUNTER | R | `0` | Lower 16 bits of the current internal PWM counter value |
| 15:1 | RESERVED | R | `0` | Reserved. Reads as 0. |
| 0 | RUNNING | R | `0` | Reflects the EN bit in `PWM_CTRL`. `1` = engine running. |

> **Note:** Writes to `PWM_STATUS` are silently ignored.
