# IP User Guide — Single-Channel PWM IP

---

## 1. IP Overview

This IP provides a highly configurable, single-channel Pulse Width Modulation (PWM) generator. By mapping to the RISC-V memory space, it allows the host CPU to dynamically adjust the frequency and duty cycle of a digital output signal.

**Typical Use Cases:**

- **LED Dimming:** Adjusting the perceived brightness of LEDs on the VSDSquadron board.
- **Servo/Motor Control:** Generating precise control pulses for external hardware.
- **Audio/Tone Generation:** Creating simple square waves at varying frequencies.

---

## 2. Feature Summary

| Feature | Detail |
|---------|--------|
| Architecture | 32-bit, fully compatible with standard RISC-V memory buses |
| Channels | Single-channel output |
| Dynamic Configuration | Period and Duty Cycle can be updated while the PWM engine is running |
| Polarity | Selectable Active-High or Active-Low via software |
| Clock | Synchronous on the main system clock |
| Prescaler | None — frequency determined by `System_Clock / PERIOD` |
| Interrupts | Not supported |
| Reset Behaviour | Safely disables output and clears counter on active-low reset |

---

## 3. Block Diagram

```
       RISC-V CPU BUS (32-bit)
=====================================
         |       |         |
      [sel]  [wdata]   [reg_addr]
         |       |         |
+-----------------------------------+
|          REGISTER DECODE          |
| 0x00: CTRL     0x04: PERIOD       |
| 0x08: DUTY     0x0C: STATUS       |
+-----------------------------------+
         |       |         |
         v       v         v
+-----------------------------------+
|        PWM LOGIC & COUNTER        |
|  [ 32-bit Synchronous Counter ]   |
|                                   |
|   Comparator: (Counter < DUTY)    |
+-----------------------------------+
                  |
             [Polarity Mux]
                  |
                  v
            ( pwm_out ) ---> To FPGA Pin / LED
```

---

## 4. Known Limitations and Notes

- **Single-Channel:** This IP generates exactly one PWM output. Multiple channels require instantiating multiple copies of the IP at different base addresses.
- **No Dedicated Prescaler:** PWM frequency is determined purely by `System_Clock / PERIOD`. The 32-bit `PERIOD` register provides ample range for very low frequencies without a hardware prescaler.
- **No Interrupts:** The IP does not generate CPU interrupts upon period wrapping.
- **Clock Assumption:** The IP assumes a synchronous single-phase system clock. No clock domain crossing support is included.
