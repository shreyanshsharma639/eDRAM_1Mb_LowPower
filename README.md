# eDRAM_1Mb_LowPower
A fully verified, 1-megabyte Embedded DRAM (eDRAM) design with a hybrid core and low-power management unit, written in SystemVerilog.

**1-Megabyte Low-Power Embedded DRAM (eDRAM) Design**

**Project Overview**

This project is a complete digital design and verification of a 1-Megabyte Low-Power Embedded DRAM (eDRAM).
The core innovation of this design is a hybrid architecture that combines the high density of a DRAM core with the ease-of-use of an SRAM interface. It features a novel, tightly-coupled Dual-FSM Control System that intelligently manages power consumption versus latency, making it ideal for modern, energy-efficient SoCs.

**Key Features**

1.High Density: 1Mb capacity organized as 16 independent 64Kb banks.

2.SRAM-Compatible Interface: Standard ce_n, we_n, addr, data interface. No complex DRAM timing required for the user.

3.Low-Power Architecture:

  1.Per-bank power gating.

  2.Three distinct power states: ACTIVE, STANDBY (Retention), and DEEP_SLEEP (Power Off).

4.Intelligent Latency Management: A unique "Predictive Power-Down Abort" mechanism prevents unnecessary wake-up latency during high-traffic bursts.

**System Architecture**

The design is built using a modular, bottom-up approach with four hierarchical tiers.

**1. The Operations Controller (controller.v)**

The "brain" of the operation. This Finite State Machine (FSM) acts as an automatic transmission for the memory.

1.Function: Automatically handles the complex Precharge -> Decode -> Sense -> Write-back sequence required by the DRAM core.

2.Protocol: It pauses operations and requests power-up from the PMU before accessing a bank, ensuring seamless operation.

**2. The Energy Manager (power_management_unit.v)**

1.The "heart" of the low-power system. This module runs 16 parallel FSMs (one for each bank).

2.State Machine: Transitions banks between DEEP_SLEEP, STANDBY, and ACTIVE.

Smart Feature: It uses an idle_timer to detect inactivity. If a new request arrives during the idle countdown, it aborts the power-down sequence, keeping the bank active and eliminating wake-up latency.

**3. The Memory Core (memory_bank.v)**

1.A structural wrapper containing the verified peripheral circuits:

2.1T1C Bitcell Array (Behaviorally modeled for simulation speed)

3.Row Decoders & Column Muxes

4.Sense Amplifier Banks

5.Write Driver Banks

**Simulation & Verification**

The project was verified using a rigorous, bottom-up methodology in ModelSim.

**Verification Strategy**

1.Unit Testing: Each module (row_decoder, precharge_circuit, memory_cell) was individually verified with dedicated testbenches.

2.Integration Testing: The memory_bank was tested to ensure the data path (Write Driver -> Cell -> Sense Amp) functioned correctly.

3.System-Level Testing: The top-level sram_top was simulated to verify the interaction between the Controller, PMU, and Memory Banks.

**Final Simulation Result**

The design successfully passes a full Read/Write cycle with power management verification.

Fig 1: Waveform showing a successful Write cycle (address 0x1BCD) followed by a successful Read cycle, verifying correct data retrieval.


**How to Run**

This project is designed to be simulated using Mentor Graphics ModelSim or Siemens QuestaSim.

Prerequisites

1.ModelSim / QuestaSim installed.

2.Git installed (optional, for cloning).

Step-by-Step Guide

Clone the Repository:

1.git clone [https://github.com/YOUR_USERNAME/eDRAM_1Mb_LowPower.git](https://github.com/YOUR_USERNAME/eDRAM_1Mb_LowPower.git)

2.cd eDRAM_1Mb_LowPower


**Launch ModelSim:**
Open ModelSim and navigate to the repository directory in the internal file browser.

**Run the Automated Script:**
In the ModelSim transcript window, type:

1.cd {link of the local project file}

2.do sim/run_sram_sim.do

**Observe Results:**
The script will automatically:

1.Compile all design and testbench files.

2.Launch the simulation.

3.Add relevant signals to the wave window.

4.Run the test scenario.

5.Display PASSED or FAILED messages in the console.

**Contributing**

Contributions are welcome! If you find a bug or want to add a feature (like a burst mode controller), please follow these steps:

1.Fork the repository.

2.Create a new branch (git checkout -b feature/AmazingFeature).

3.Commit your changes (git commit -m 'Add some AmazingFeature').

4.Push to the branch (git push origin feature/AmazingFeature).

Open a Pull Request.

**Future Work**

1.Synthesis: Prepare the design for synthesis targeting an FPGA block RAM or ASIC standard cells.

2.Burst Mode: Implement a burst access mode to further utilize the high bandwidth.

3.Refresh Controller: Add a background refresh counter to the main controller to handle data retention over long periods.

Author: shreyansh sharma
License: MIT
