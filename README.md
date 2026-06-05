# FPGA IP Design Internship — Task 1

**VSD (VLSI System Design) FPGA IP Internship**

---

## Objective

Write a C program, compile it using standard GCC, then cross-compile it for the RISC-V architecture using `riscv64-linux-musl-gcc`. Disassemble the object file using `objdump` and observe the generated RISC-V assembly instructions. Compare instruction counts under normal and `-Ofast` optimization.

---

## Tools Used

| Tool | Purpose |
|------|---------|
| `gcc` | Native C compilation on host machine |
| `riscv64-linux-musl-gcc` | Cross-compiler for RISC-V 64-bit target |
| `riscv64-linux-musl-objdump` | Disassembler to view RISC-V assembly |
| `leafpad` | Text editor used to write C source |
| VDI (Virtual Disk Image) | Pre-configured environment with RISC-V toolchain |

---

## C Program — `sum_to_n.c`

A simple C program that computes the sum of integers from 1 to N using a `for` loop.

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

## Compilation Steps

### Step 1 — Native GCC Compilation and Execution

```bash
gcc sum_to_n.c
./a.out
```

**Output:**
```
The sum of numbers is: 15        # for n=5
The sum of numbers from 1 to 100 is: 5050   # for n=100
```

---

### Step 2 — RISC-V Cross-Compilation (Default)

```bash
riscv64-linux-musl-gcc -mabi=lp64d -march=rv64g -o sum_to_n.o sum_to_n.c
riscv64-linux-musl-objdump -d sum_to_n.o
```

The disassembly reveals the `.plt`, `_start`, `_start_c`, and `main` sections with the full loop structure intact in the generated assembly.

---

### Step 3 — RISC-V Cross-Compilation with `-Ofast`

```bash
riscv64-linux-musl-gcc -Ofast -mabi=lp64d -march=rv64g -o sum_to_n.o sum_to_n.c
riscv64-linux-musl-objdump -d sum_to_n.o
```

---

## Observation — Instruction Count Comparison

| Compilation Mode | Instructions in `main` |
|-----------------|------------------------|
| Default (no optimization) | ~15 instructions |
| `-Ofast` optimization | ~12 instructions |

The `-Ofast` flag reduces the instruction count in the `main` section from approximately **15 to 12**, demonstrating how aggressive compiler optimization generates more compact and efficient RISC-V assembly code.

---

## Snapshots

### C Source File
![C Source File](./snapshots/sum_c_file.png)

### Native GCC Compilation & Output (n=5)
![GCC Compilation Result](./snapshots/sum_result.png)

### Native GCC Compilation & Output (n=100)
![GCC Compilation Result n=100](./snapshots/sum_c_100_result.png)

### RISC-V Cross-Compilation Command (`-Ofast`)
![Ofast Compile Command](./snapshots/Ofast_instruction.png)

### RISC-V Objdump — Default Compilation (main section, ~15 instructions)
![Main 15 instructions](./snapshots/main_command_w_fifteen_instructions.png)

### RISC-V Objdump — With `-Ofast` (main section, ~12 instructions)
![Ofast 12 instructions](./snapshots/ofast_12_instructions_only.png)

### Full Objdump Output — Default
![RISC-V Instructions](./snapshots/riscv-instructions.png)

### Full Objdump Output — `-Ofast`
![Ofast full objdump](./snapshots/ofast_command_objdump.png)

---

## Repository Structure

```
fpga-ip-internship/
│
├── README.md
├── sum_to_n.c
└── snapshots/
    ├── creation_c_file.png
    ├── sum_c_file.png
    ├── sum_result.png
    ├── sum_c_100.png
    ├── sum_c_100_result.png
    ├── Ofast_instruction.png
    ├── riscv-instructions.png
    ├── larger_riscv_instructions.png
    ├── main_command_w_fifteen_instructions.png
    ├── pipeless_command.png
    ├── ofast_12_instructions_only.png
    └── ofast_command_objdump.png
```

---


## Author

**Amishi Singh**
VSD FPGA IP Design Internship Participant
