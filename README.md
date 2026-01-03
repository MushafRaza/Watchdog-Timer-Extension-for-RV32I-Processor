# Design and Verification of a Watchdog Timer Extension for RV32I Processor

## Course
**Course:** EE-321 – Computer Architecture and Organization  


## Team Members
- Ibraheem Hasnain (412444)  
- Aneeq ur Rehman (418794)  
- Agha Mushaf Raza (423074)

---

## Project Overview
This project focuses on enhancing the **reliability and fault tolerance** of an **RV32I RISC-V processor** by designing and integrating a **hardware watchdog timer**.  
The watchdog detects software hangs and recovers the system automatically using **interrupts and resets**.

---

## Motivation
Modern processors used in embedded and safety-critical systems must handle:
- Software hangs
- Infinite loops
- Deadlocks  

A hardware watchdog timer provides an **automatic recovery mechanism** without human intervention.

---

## Project Objectives
- Design an **independent watchdog timer hardware module**
- Integrate watchdog safely into the **RV32I 5-stage pipeline**
- Provide **early fault detection** via watchdog interrupt
- Ensure **safe processor recovery** using watchdog reset
- Verify functionality using **RTL simulation**

---

## RV32I Architecture Overview
- **ISA:** RV32I (RISC-V)
- **Pipeline Stages:**
  - IF – Instruction Fetch
  - ID – Instruction Decode
  - EX – Execute
  - MEM – Memory Access
  - WB – Write Back
- Modular and extensible design

---

## Watchdog Timer Design
- Independent hardware module
- Internal counter increments every clock cycle
- **Feed signal** resets counter during normal execution
- **Timeout → Watchdog Interrupt (WDT_IRQ)**
- **Extended timeout → Watchdog Reset (WDT_RST)**

---

## Pipeline Integration
- No interference with normal instruction flow
- Reset safely clears pipeline registers
- Watchdog reset integrated with:
  - Program Counter
  - Pipeline registers
- Interrupt provides early warning before reset

---

## Testbench & Verification
- Custom RTL testbench for:
  - RV32I pipeline
  - Watchdog module
- Cycle-by-cycle monitoring of all pipeline stages
- Verification of:
  - Watchdog interrupt
  - Watchdog reset
  - Pipeline recovery after reset

---

## Simulation Results
- **WDT = 1:** Normal execution with periodic feed
- **WDT = 0:** Software hang detected → interrupt → reset
- Confirms correct watchdog behavior and pipeline safety

---

## Key Takeaways
✔ Successful integration of watchdog with RV32I  
✔ Early fault detection via interrupt  
✔ Safe processor recovery using reset  
✔ Improved reliability and fault tolerance  
✔ Fully verified through RTL simulation  

---

## 🛠 Tools & Technologies
- Verilog / SystemVerilog
- RTL Simulation
- RISC-V RV32I Architecture

---


