# FPGA IP Design Internship

**VSD (VLSI System Design) FPGA IP Internship**

---

## Overview

This repository documents the hands-on tasks completed as part of the VSD FPGA IP Design Internship. Each task involves writing C programs, cross-compiling them for the RISC-V architecture, disassembling the binaries using `objdump`, simulating execution using the Spike RISC-V ISA simulator, and analysing the effect of compiler optimisation flags on instruction count and code structure.

---

## Tools Used

| Tool | Purpose |
|------|---------|
| `gcc` | Native C compilation on host machine |
| `riscv64-linux-musl-gcc` | Cross-compiler targeting RISC-V 64-bit (musl libc) |
| `riscv64-unknown-linux-gnu-gcc` | Cross-compiler targeting RISC-V 64-bit (GNU libc, static) |
| `riscv64-linux-musl-objdump` | Disassembler for musl-compiled RISC-V binaries |
| `spike` | RISC-V ISA simulator for functional verification |
| `pk` | Proxy kernel used alongside Spike for syscall handling |
| `leafpad` | Text editor used to write C source files |
| VDI (Virtual Disk Image) | Pre-configured internship environment with full RISC-V toolchain |

---

## Optimisation Flags — Definitions

| Flag | Full Name | Description |
|------|-----------|-------------|
| `-O1` | Optimisation Level 1 | Enables basic optimisations that reduce code size and improve speed without significantly increasing compilation time. Includes dead code elimination, simple inlining, and basic loop optimisations. |
| `-Ofast` | Fast Math Optimisation | Enables all `-O3` optimisations plus aggressive floating-point transformations that may violate strict IEEE 754 compliance. Allows the compiler to reorder and vectorise floating-point operations freely, often increasing instruction count for compute-heavy code due to loop unrolling. |

---

## Commands Reference

### Native Compilation
```bash
gcc <source>.c
./a.out
```

### RISC-V Cross-Compilation (musl libc)
```bash
riscv64-linux-musl-gcc -mabi=lp64d -march=rv64g -o <output>.o <source>.c
riscv64-linux-musl-objdump -d <output>.o
```

### RISC-V Cross-Compilation with Optimisation (musl libc)
```bash
riscv64-linux-musl-gcc -O1 -mabi=lp64d -march=rv64g -o <output>.o <source>.c
riscv64-linux-musl-gcc -Ofast -mabi=lp64d -march=rv64g -o <output>.o <source>.c
```

### RISC-V Cross-Compilation with Spike Simulation (GNU libc, static)
```bash
riscv64-unknown-linux-gnu-gcc -O1 -march=rv64g -mabi=lp64d -static -o <output>.o <source>.c
spike $(which pk) <output>.o

# Debug mode — step through instructions
spike -d $(which pk) <output>.o
(spike) until pc 0 <address>
(spike) reg 0 <register>
(spike) q
```

---

---

# Task 1 — C Program Compilation and RISC-V Assembly Analysis (`sum_to_n`)

## Objective

Write a C program that computes the sum of integers from 1 to N. Compile it natively using GCC, then cross-compile for RISC-V and disassemble using `objdump`. Compare instruction counts in the `main` section under default compilation and `-Ofast` optimisation. Simulate execution using Spike.

---

## C Program — `sum_to_n.c`

A simple C program computing the sum of integers from 1 to N using a `for` loop.

**Version 1 — Sum from 1 to 5:**
```c
#include<stdio.h>

int main(){
    int i, sum=0, n=5;
    for (i = 1; i <= n; i++)
    {
        sum += i;
    }
    printf("The sum of numbers is: %d \n", sum);
    return 0;
}
```

**Version 2 — Sum from 1 to 100:**
```c
#include<stdio.h>

int main(){
    int i, sum=0, n=100;
    for (i = 1; i <= n; i++)
    {
        sum += i;
    }
    printf("The sum of numbers from 1 to %d is: %d \n", n, sum);
    return 0;
}
```

---

## Step-by-Step Walkthrough

### Step 1 — Working Directory and File Creation

Working directory confirmed and `leafpad` editor launched to create `sum_to_n.c`.

![Creating C File](./task1/creation_c_file.png)

---

### Step 2 — C Source Code (n=5)

Initial version of the program summing integers from 1 to 5, written in `leafpad`.

![C Source n=5](./task1/sum_c_file.png)

---

### Step 3 — Native GCC Compilation and Output (n=5)

```bash
gcc sum_to_n.c
./a.out
```

**Output:** `The sum of numbers is: 15`

![GCC Result n=5](./task1/sum_result.png)

---

### Step 4 — C Source Code Updated (n=100)

Program updated to sum from 1 to 100 with improved `printf` format.

![C Source n=100](./task1/sum_c_100.png)

---

### Step 5 — Native GCC Compilation and Output (n=100)

```bash
gcc sum_to_n.c
./a.out
```

**Output:** `The sum of numbers from 1 to 100 is: 5050`

![GCC Result n=100](./task1/sum_c_100_result.png)

---

### Step 6 — RISC-V Cross-Compilation (Default, No Optimisation)

```bash
riscv64-linux-musl-gcc -mabi=lp64d -march=rv64g -o sum_to_n.o sum_to_n.c
riscv64-linux-musl-objdump -d sum_to_n.o
```

Full disassembly output showing `.plt`, `_start`, `_start_c`, and `main` sections.

![RISC-V Objdump Default](./task1/riscv-instructions.png)

---

### Step 7 — Full RISC-V Objdump Output (Default)

Larger view of the complete disassembly output for the default compilation.

![RISC-V Objdump Larger View](./task1/larger_riscv_instructions.png)

---

### Step 8 — Objdump Without Pipe (Default)

Alternate view of the objdump output without piping, showing raw terminal output.

![Objdump Pipeless](./task1/pipeless_command.png)

---

### Step 9 — `main` Section — Default Compilation (~15 Instructions)

The `main` function in default mode contains approximately **15 instructions**, with the full loop structure present in the assembly.

![Main 15 Instructions](./task1/main_command_w_fifteen_instructions.png)

---

### Step 10 — RISC-V Cross-Compilation with `-Ofast`

```bash
riscv64-linux-musl-gcc -Ofast -mabi=lp64d -march=rv64g -o sum_to_n.o sum_to_n.c
```

![Ofast Compile Command](./task1/Ofast_instruction.png)

---

### Step 11 — Full Objdump Output with `-Ofast`

Complete disassembly after `-Ofast` compilation showing optimised sections.

![Ofast Full Objdump](./task1/ofast_command_objdump.png)

---

### Step 12 — `main` Section — `-Ofast` Compilation (~12 Instructions)

With `-Ofast`, the `main` function is reduced to approximately **12 instructions**.

![Ofast 12 Instructions](./task1/ofast_12_instructions_only.png)

---

### Step 13 — Spike Simulation (`sum_to_n`)

```bash
riscv64-unknown-linux-gnu-gcc -O1 -march=rv64g -mabi=lp64d -static -o sum_to_n.o sum_to_n.c
spike $(which pk) sum_to_n.o
spike -d $(which pk) sum_to_n.o
```

Spike confirms correct execution and allows stepping through individual RISC-V instructions with register inspection.

![Spike Simulation sum_to_n](./task1/sum_to_n_instructions_spike.png)

---

### Step 14 — Objdump `main` with `-O1`

```bash
riscv64-linux-musl-gcc -O1 -mabi=lp64d -march=rv64g -o sum_to_n.o sum_to_n.c
riscv64-linux-musl-objdump -d sum_to_n.o
```

With `-O1`, the `main` section is visibly reduced in instruction count.

![Objdump O1 main](./task1/objdump_for_sum_to_n.png)

---

### Step 15 — Native GCC Compilation (n=100, final run)

```bash
gcc sum_to_n.c
./a.out
```

![GCC Final Run](./task1/sum_to_n_gcc.png)

---

### Step 16 — `main` Section — No Optimisation (full view)

The `main` function with no optimisation, showing full loop body in assembly (~28 instructions).

![Main No Opt](./task1/main_file_sum_to_n.png)

---

## Instruction Count Comparison — `sum_to_n`

| Compilation Mode | Instructions in `main` |
|-----------------|------------------------|
| Default (no optimisation) | ~28 instructions |
| `-O1` | ~15 instructions |
| `-Ofast` | ~12 instructions |

The `-Ofast` flag reduces the instruction count in `main` from approximately **28 (default) to 12**, with `-O1` providing an intermediate reduction to ~15. This demonstrates how progressive compiler optimisation generates increasingly compact RISC-V assembly.

---

---

# Task 2 — Perceptron (XOR Gate) Compilation and RISC-V Analysis

## Objective

Write a C program implementing a single-layer perceptron trained to replicate an XOR logic gate. Compile natively and verify output. Cross-compile for RISC-V, disassemble under `-O1` and `-Ofast` flags, count instructions in `main`, and simulate execution using Spike to verify functional correctness on the RISC-V architecture.

---

## What We Are Achieving

A perceptron is the foundational unit of a neural network — a mathematical model of a biological neuron. In this task, we train a perceptron to learn the XOR logic function using a step activation function and a simple weight-update learning rule. The goal from a hardware perspective is to understand how a floating-point compute-intensive C program maps to RISC-V assembly under different compiler optimisation strategies, and how Spike can be used to verify functional correctness at the ISA level.

---

## C Program — `perceptron.c`

A single-layer perceptron with 3 inputs (x1, x2, x1 AND x2) trained to replicate XOR behaviour using a step activation function.

```c
#include <stdio.h>

// Training Data for an XOR Gate
// Inputs: x1, x2, and a feature engineered third input (x1 AND x2)
// Target Output: y (x1 XOR x2)
float inputs[4][3] = {
    {0.0, 0.0, 0.0},  // 0 XOR 0 = 0
    {0.0, 1.0, 0.0},  // 0 XOR 1 = 1
    {1.0, 0.0, 0.0},  // 1 XOR 0 = 1
    {1.0, 1.0, 1.0}   // 1 XOR 1 = 0
};
float targets[4] = {0.0, 1.0, 1.0, 0.0};

// Step Activation Function (Digital High/Low Logic Trigger)
int activate(float sum) {
    return (sum >= 0.5) ? 1 : 0;
}

int main() {
    float w1 = 0.0, w2 = 0.0, w3 = 0.0;
    float bias = 0.0;
    float learning_rate = 0.2;
    int trained = 0;

    printf("Training Perceptron to replicate an XOR Gate...\n");

    // Training Loop
    for (int epoch = 0; epoch < 100; epoch++) {
        // ... weight update logic ...
    }
    // ... print weights and test results ...
    return 0;
}
```

![Perceptron Source Code](./task2/perceptron_code.png)

---

## Step-by-Step Walkthrough

### Step 1 — Native GCC Compilation and Output

```bash
leafpad perceptron.c
gcc perceptron.c
./a.out
```

The perceptron trains successfully and stabilises at **Epoch 7**, correctly replicating XOR behaviour for all four input combinations.

![ML Commands](./task2/ml_commands.png)

---

### Step 2 — Perceptron Output (Detailed)

```
Training Perceptron to replicate an XOR Gate...
Stabilized at Epoch 7!

--- Trained Hardware Network Parameters ---
Weight 1 (x1): 0.20
Weight 2 (x2): 0.20
Weight 3 (x1 AND x2): -0.60
Bias Line Voltage: 0.40

--- Testing Virtual Logic Network ---
Input Logic: [0, 0] -> Expected Output: 0 -> Neural Circuit Logic: 0
Input Logic: [0, 1] -> Expected Output: 1 -> Neural Circuit Logic: 1
Input Logic: [1, 0] -> Expected Output: 1 -> Neural Circuit Logic: 1
Input Logic: [1, 1] -> Expected Output: 0 -> Neural Circuit Logic: 0
```

![Perceptron Output](./task2/output_for_perceptron_code.png)

---

### Step 3 — RISC-V Cross-Compilation with `-O1` and Objdump

```bash
riscv64-linux-musl-gcc -O1 -mabi=lp64d -march=rv64g -o perceptron.o perceptron.c
riscv64-linux-musl-objdump -d perceptron.o
```

![O1 Compile and Objdump Command](./task2/commands_objdump_O1.png)

---

### Step 4 — Objdump `main` Section — `-O1`

The `main` function with `-O1` starts at address `0x10448` and ends at `0x10674`.

**Instruction count:** (0x10674 − 0x10448) / 4 = **139 instructions**

![Objdump Perceptron O1](./task2/objdump_perceptron_O1.png)

![Main Instructions O1](./task2/main_instructions_perceptron_O1.png)

---

### Step 5 — Spike Simulation — `-O1`

```bash
riscv64-unknown-linux-gnu-gcc -O1 -march=rv64g -mabi=lp64d -static -o perceptron.o perceptron.c
spike $(which pk) perceptron.o
spike -d $(which pk) perceptron.o
```

Spike confirms correct execution of the perceptron on the RISC-V ISA under `-O1`.

![Spike Simulation O1](./task2/spike_simulation_o1.png)

---

### Step 6 — RISC-V Cross-Compilation with `-Ofast` and Objdump

```bash
riscv64-unknown-linux-gnu-gcc -Ofast -march=rv64g -mabi=lp64d -static -o perceptron.o perceptron.c
riscv64-unknown-linux-gnu-objdump -d $(which pk) perceptron.o
```

The `main` function with `-Ofast` starts at address `0x10340` and ends at `0x10628`.

**Instruction count:** (0x10628 − 0x10340) / 4 = **186 instructions**

![Objdump Perceptron Ofast main](./task2/objdump_main_Ofast.png)

---

### Step 7 — Spike Simulation — `-Ofast`

```bash
riscv64-unknown-linux-gnu-gcc -Ofast -march=rv64g -mabi=lp64d -static -o perceptron.o perceptron.c
spike -d $(which pk) perceptron.o
```

![Spike Simulation Ofast](./task2/spike_simulation_Ofast.png)

---

## Instruction Count Comparison — `perceptron`

| Compilation Mode | `main` Start Address | `main` End Address | Instructions in `main` |
|-----------------|---------------------|-------------------|------------------------|
| `-O1` | `0x10448` | `0x10674` | **139** |
| `-Ofast` | `0x10340` | `0x10628` | **186** |

### Key Observation

Contrary to what might be expected, **`-Ofast` generates significantly more instructions (186) than `-O1` (139)** for the perceptron program. This is because `-Ofast` enables aggressive floating-point loop unrolling and vectorisation — the compiler replicates loop body instructions multiple times to reduce branch overhead and exploit instruction-level parallelism. The perceptron's training loop, which involves repeated floating-point multiply-accumulate operations (`fmul.s`, `fmadd.s`, `fadd.s`), is a prime candidate for this transformation. The result is a larger but potentially faster binary when run on hardware that supports out-of-order or pipelined execution.

This is in contrast to the integer-only `sum_to_n` program, where `-Ofast` reduced instruction count because there were no floating-point operations to unroll.

---

## Repository Structure

```
fpga-ip-internship/
│
├── README.md
├── sum_to_n.c
├── perceptron.c
│
├── task1/
│   ├── creation_c_file.png
│   ├── sum_c_file.png
│   ├── sum_result.png
│   ├── sum_c_100.png
│   ├── sum_c_100_result.png
│   ├── riscv-instructions.png
│   ├── larger_riscv_instructions.png
│   ├── pipeless_command.png
│   ├── main_command_w_fifteen_instructions.png
│   ├── Ofast_instruction.png
│   ├── ofast_command_objdump.png
│   ├── ofast_12_instructions_only.png
│   ├── sum_to_n_gcc.png
│   ├── main_file_sum_to_n.png
│   ├── objdump_for_sum_to_n.png
│   └── sum_to_n_instructions_spike.png
│
└── task2/
    ├── perceptron_code.png
    ├── ml_commands.png
    ├── output_for_perceptron_code.png
    ├── commands_objdump_O1.png
    ├── objdump_perceptron_O1.png
    ├── main_instructions_perceptron_O1.png
    ├── end_of_main_O1__to_calculate_instructions_.png
    ├── spike_simulation_o1.png
    ├── objdump_main_Ofast.png
    ├── end_of_main_Ofast__to_calculate_instructions_.png
    └── spike_simulation_Ofast.png
```


## Author

**Amishi Singh**
VSD FPGA IP Design Internship Participant
