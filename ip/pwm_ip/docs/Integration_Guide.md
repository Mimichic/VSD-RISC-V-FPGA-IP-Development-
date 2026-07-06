# Integration Guide — Single-Channel PWM IP

This guide explains how to plug the PWM IP into the VSDSquadron RISC-V SoC. The reader is assumed to be familiar with the VSDSquadron FPGA environment but not with the internals of this IP.

---

## 1. Required Files

Ensure the following file is present in your hardware synthesis or simulation source tree:

```
rtl/PWM_IP.v
```

No external dependencies or additional modules are required.

---

## 2. Address Decoding Expectations

The `basicRISCV` SoC architecture uses a **1-hot decoding scheme** on the word-aligned address bus (`mem_wordaddr = mem_addr[31:2]`). Each peripheral is assigned one bit of this bus as its chip-select.

This IP is assigned **Bit 4**, which maps to physical base address **`0x400040`**.

Internal register selection uses bits `[3:2]` of `mem_addr` as the 2-bit offset decoder (`reg_addr`):

| `reg_addr` | Offset | Register |
|------------|--------|----------|
| `2'b00` | `0x00` | `PWM_CTRL` |
| `2'b01` | `0x04` | `PWM_PERIOD` |
| `2'b10` | `0x08` | `PWM_DUTY` |
| `2'b11` | `0x0C` | `PWM_STATUS` |

---

## 3. SoC Instantiation (`riscv.v`)

Open your top-level SoC file (`riscv.v`) and make the following additions:

**Step 1 — Include the RTL file and define the address bit:**

```verilog
`include "PWM_IP.v"
localparam IO_PWM_bit = 4;  // Maps to physical address 0x400040
```

**Step 2 — Declare wires and instantiate the IP:**

```verilog
wire [31:0] pwm_rdata;
wire        pwm_out_signal;

PWM_IP pwm_ip_inst (
    .clk     (clk),
    .resetn  (resetn),
    .sel     (isIO & mem_wordaddr[IO_PWM_bit]),
    .reg_addr(mem_addr[3:2]),
    .wstrb   (mem_wstrb),
    .wdata   (mem_wdata),
    .rdata   (pwm_rdata),
    .pwm_out (pwm_out_signal)
);
```

**Step 3 — Update the CPU read multiplexer:**

```verilog
wire [31:0] IO_rdata =
    mem_wordaddr[IO_UART_CNTL_bit] ? {22'b0, !uart_ready, 9'b0} :
    mem_wordaddr[IO_PWM_bit]       ? pwm_rdata                   :
                                     32'b0;
```

---

## 4. Signals Exposed to Top-Level

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `clk` | Input | 1-bit | System clock |
| `resetn` | Input | 1-bit | Active-low synchronous reset |
| `sel` | Input | 1-bit | Chip-select from 1-hot address decoder |
| `reg_addr` | Input | 2-bit | Register offset (`mem_addr[3:2]`) |
| `wstrb` | Input | 1-bit | Write strobe from CPU |
| `wdata` | Input | 32-bit | Write data from CPU |
| `rdata` | Output | 32-bit | Read data to CPU |
| `pwm_out` | Output | 1-bit | PWM signal to FPGA pin or LED |

---

## 5. Board-Level Usage (VSDSquadron FPGA)

To observe the PWM signal physically on the VSDSquadron board:

1. Expose `pwm_out_signal` through the top-level `SOC` module ports.
2. In your `.pcf` constraint file, assign the exposed PWM port to an onboard LED pin:

```
set_io pwm_out LED0
```

3. As `PWM_DUTY` increases relative to `PWM_PERIOD` in software, the physical LED will appear progressively brighter due to the increased duty cycle.

---

## 6. Simulation Setup

To simulate without an FPGA board, use the existing `SOC_sim_top.v` testbench from the `basicRISCV` environment unchanged:

```bash
iverilog -DBENCH -DSIM -g2012 -o SOC_sim.vvp SOC_sim_top.v riscv.v
vvp SOC_sim.vvp
```

The `pwm_out` signal will be observable in the generated `.vcd` file via GTKWave.
