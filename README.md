# RISC-V Single-Cycle Processor 

This repository contains a **Verilog implementation** of a single-cycle RISC-V processor. The design focuses on a modular architecture, specifically highlighting the implementation of the **Control Unit**, **Immediate Generation** , and **B-type (BEQ) branching logic**.

---

## 🏗️ Architecture Overview

The processor is divided into several functional modules, each handling a specific stage of the RISC-V datapath:

* **Instruction Fetch**: `pc_module.v` handles the program counter , and `instr_mem.v` serves as the instruction ROM.
* **Decode**: `decoder.v` extracts the opcode, register addresses, and function codes from the 32-bit instruction.
* **Control Unit**: `control.v` generates essential signals such as `RegWrite`, `ALUSrc`, `MemRead`, and `Branch` based on the instruction opcode.
* **Execution (ALU)**: `alu.v` performs arithmetic/logic operations , guided by `alu_control.v` which decodes the specific operation type.
* **Register File**: `regfile.v` manages thirty-two 32-bit registers, with `x0` hardwired to zero.
* **Memory**: `data_mem.v` (integrated into the top module) handles data storage and retrieval.



---

## 🛠️ Instruction Support

The current implementation supports a core subset of the RISC-V RV32I ISA:

| Type | Instruction | Opcode | Function |
| :--- | :--- | :--- | :--- |
| **R-Type** | `ADD`, `SUB` | `7'b0110011` | Register-Register operations  |
| **I-Type** | `ADDI` | `7'b0010011` | Register-Immediate addition  |
| **I-Type** | `LW` | `7'b0000011` | Load word from memory |
| **S-Type** | `SW` | `7'b0100011` | Store word to memory  |
| **B-Type** | `BEQ` | `7'b1100011` | Branch if equal  |

---

## 🚦 Branch Logic Implementation

The branching mechanism is determined by the `Branch` control signal and the ALU `Zero` flag:

1.  **ALU Calculation**: For a `BEQ` instruction, the ALU is commanded to perform a **subtraction** (`4'b0001`).
2.  **Zero Flag**: If the result is zero (meaning `rs1 == rs2`), the `zero_flag` is asserted.
3.  **Target Calculation**: The PC branch target is calculated as `PC + Immediate`.
4.  **Next PC Selection**: The hardware selects the next address using the following logic:
    `pc_next = (Branch & Zero) ? pc_branch : pc_plus4`

---

## 🚀 Getting Started

### Prerequisites
* **Icarus Verilog**: For compilation and simulation.
* **GTKWave**: For viewing `.vcd` waveform files.

### Simulation Instructions
1.  **Compile all source files**:
    ```bash
    iverilog -o riscv_sim tb_riscv.v riscv_top.v pc_module.v instr_mem.v decoder.v control.v regfile.v imm_gen.v alu_control.v alu.v data_mem.v
    ```
2.  **Run the simulation**:
    ```bash
    vvp riscv_sim
    ```
3.  **Analyze Waveforms**:
    ```bash
    gtkwave riscv_day3.vcd
    ```

---

## 📊 Test Verification
The included testbench (`tb_riscv.v`) verifies the branching logic using a specific code sequence:
* It initializes `x1 = 5` and `x2 = 5`.
* It executes `BEQ x1, x2, +8`.
* **Expected Result**: Since `x1 == x2`, the processor skips the `ADDI x3, x0, 1` instruction and jumps directly to `ADDI x3, x0, 9`.
