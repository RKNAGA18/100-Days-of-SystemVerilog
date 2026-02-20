# 🚀 100 Days of SystemVerilog for SoC Design

This repository tracks my 100-day intensive sprint to master production-grade SystemVerilog and RTL architecture. 

As a VLSI Design & Technology student, the goal of this challenge is to bridge the gap between academic digital logic and industry-standard silicon design. The roadmap is specifically tailored toward processor architecture, robust Clock Domain Crossing (CDC), and open-source verification methodologies. 

A major focus of the later phases involves implementing delta compression and backpressure handling logic to support my GSoC 2026 proposal for the BlackParrot RISC-V Trace Encoder (ZynqParrot).

## 🛠️ Tech Stack & Toolchain
* **Hardware Description Language:** SystemVerilog (IEEE 1800-2012)
* **Simulation & Verification:** Icarus Verilog (`iverilog`), Verilator
* **Waveform Analysis:** GTKWave
* **Synthesis Targets:** ASIC Standard Cell / FPGA (OpenLane / Vivado)

## 📅 Roadmap & Progress

- [x] **Day 1:** Combinational Logic & Data Routing (ALUs, Priority Encoders, Structs/Enums)
- [x] **Day 2:** Arithmetic & DSP Foundations
- [ ] **Day 3:** Sequential Core & Registers
- [ ] **Day 4:** Advanced Timing & Real-World Control
- [ ] **Day 5:** FSM Architecture & Sequence Logic
- [ ] **Day 6:** Memory Structures & Buffering
- [ ] **Day 7:** Clock Domain Crossing (CDC) & Arbitration
- [ ] **Day 8:** Standard Bus Protocols (AXI4-Stream, APB)
- [ ] **Day 9:** Pipelining & RISC-V Datapath
- [ ] **Day 10:** Trace Encoding & System Integration (ZynqParrot Custom Logic)

## 🏃‍♂️ How to Run the Simulations
Each daily folder contains a standalone environment. To run Day 1:
```bash
cd Day01_Combinational_Logic
iverilog -g2012 -o sim_out src/*.sv tb/*.sv
vvp sim_out
gtkwave day1_sim.vcd

