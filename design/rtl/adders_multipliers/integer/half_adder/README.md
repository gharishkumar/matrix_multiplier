# Half Adder AXI Master-Slave Verilog Project

This repository contains a Verilog implementation of a half adder with AXI4-Stream master-slave interfaces. The project includes the RTL design and a testbench for simulation and verification.

---

## Table of Contents
1. [Overview](#overview)
2. [Repository Structure](#repository-structure)
3. [Diagram](#diagram)
4. [Ports](#ports)
5. [Internal reg](#internal-reg)
6. [State Machines](#state-machines)
7. [Prerequisites](#prerequisites)
8. [Simulation Steps](#simulation-steps)
9. [Expected Results](#expected-results)
10. [Contributing](#contributing)
11. [License](#license)

---

## Overview

The `half_adder_axi_master_slave` module implements a half adder with AXI4-Stream interfaces for communication between a master and a slave. The module takes two 1-bit inputs (`s_a_tdata` and `s_b_tdata`) and produces two 1-bit outputs (`m_sum_tdata` and `m_carry_tdata`). The design is verified using a Verilog testbench.  
I tried to be compliant with Advanced eXtensible Interface 4 stream (AXI4 - stream) protocol, yeah I really tried.

---

## Repository Structure  

half_adder_axi_master_slave/  
├── fsm/ # RTL design files  
│&emsp;&emsp; └── half_adder_axi_stream_state_machine.png  
│&emsp;&emsp; └── half_adder_axi_stream_state_machine.svg  
├── ports/ # RTL design files  
│&emsp;&emsp; └── half_adder_axi_master_slave.svg  
├── rtl/ # RTL design files  
│&emsp;&emsp; └── half_adder_axi_master_slave.v  
├── tb/ # Testbench files  
│&emsp;&emsp; └── tb_half_adder_axi_master_slave.v  
├── waveform/ # Waveform files  
│&emsp;&emsp; └── screenshot.png  
│&emsp;&emsp; └── waveform.vcd  
├── README.md # This file  
└── .gitignore # Git ignore file  

---

## Diagram
![Diagram](https://github.com/gharishkumar/half_adder/raw/refs/heads/main/half_adder_axi_master_slave/ports/half_adder_axi_master_slave.svg "Diagram")

---

## Ports

| Port name      | Direction | Type | Description |
| -------------- | --------- | ---- | ----------- |
| clk            | input     | wire | clock       |
| reset          | input     | wire | reset       |
| s_a_tvalid     | input     | wire | denotes `s_a_tdata` is valid |
| s_a_tdata      | input     | wire | `a` data    |
| s_a_tready     | output    | reg  | ack that `s_a_tdata` in received |
| s_b_tvalid     | input     | wire | denotes `s_b_tdata` is valid |
| s_b_tdata      | input     | wire | `b` data    |
| s_b_tready     | output    | reg  | ack that `s_b_tdata` in received |
| m_sum_tvalid   | output    | reg  | denotes `m_sum_tdata` is valid |
| m_sum_tdata    | output    | reg  | `sum` data  |
| m_sum_tready   | input     | wire | ack that `m_sum_tdata` in received |
| m_carry_tvalid | output    | reg  | denotes `m_carry_tdata` is valid |
| m_carry_tdata  | output    | reg  | `carry` data |
| m_carry_tready | input     | wire | ack that `m_carry_tdata` in received |

---

## Internal reg

| Name          | Type      | Description |
| ------------- | --------- | ----------- |
| a_reg         | reg       | to store `s_a_tdata` |
| b_reg         | reg       | to store `s_b_tdata` |

---

## State machines

![half_adder_axi_stream_state_machine]( https://github.com/gharishkumar/half_adder/raw/refs/heads/main/half_adder_axi_master_slave/fsm/half_adder_axi_stream_state_machine.svg "State Diagram")

---

## Prerequisites

To simulate and test the Verilog code, you need the following tools:

1. **Verilog Simulator**:
   - [Icarus Verilog](http://iverilog.icarus.com/) (Open-source)
   - [ModelSim](https://www.mentor.com/products/fpga/modelSim/) (Commercial)
   - [Xilinx Vivado](https://www.xilinx.com/products/design-tools/vivado.html) (Commercial)
   - [Verilator](https://www.veripool.org/wiki/verilator) (Open-source)

2. **Waveform Viewer** (Optional):
   - [GTKWave](http://gtkwave.sourceforge.net/) (Open-source)

3. **Git** (Optional):
   - To clone this repository.

---

## Simulation Steps

Follow these steps to simulate and verify the design:

### Step 1: Clone the Repository
Clone this repository to your local machine:
```bash
git clone https://github.com/ghrishkumar/half_adder.git
cd half_adder_axi_master_slave
```

### Step 2: Create work library, Compile the Design and Testbench
Using QuestaSim:
```bash
vlib work
vlog -work work rtl/half_adder_axi_master_slave.v tb/tb_half_adder_axi_master_slave.v
```

### Step 3: Run the Simulation
Execute the compiled simulation:
```bash
vsim -voptargs=+acc work.tb_half_adder_axi_master_slave
```
```tcl
add_wave
run -all
```
#### QuestaSim
![screenshot](https://github.com/gharishkumar/half_adder/blob/main/half_adder_axi_master_slave/waveform/questasim.png?raw=true)
#### Vivado
![screenshot](https://github.com/gharishkumar/half_adder/blob/main/half_adder_axi_master_slave/waveform/vivado.png?raw=true)
### Step 4: View the Results
The simulation will print the test results in the terminal. If using a waveform viewer like GTKWave, you can generate a VCD file and view the waveforms:

Modify the testbench to include $dumpfile("waveform.vcd"); and $dumpvars; at the beginning of the initial block.

Recompile and run the simulation.

Open the waveform.vcd file in GTKWave:

```bash
gtkwave waveform.vcd
```

#### Expected Results
The testbench runs four test cases:

A = 0, B = 0: Sum = 0, Carry = 0

A = 1, B = 0: Sum = 1, Carry = 0

A = 0, B = 1: Sum = 1, Carry = 0

A = 1, B = 1: Sum = 0, Carry = 1

#### The simulation output should display:

Test case 1 passed: Sum = 0, Carry = 0  
Test case 2 passed: Sum = 1, Carry = 0  
Test case 3 passed: Sum = 1, Carry = 0  
Test case 4 passed: Sum = 0, Carry = 1  
Simulation completed.  

---

## Contributing
Contributions are welcome! If you find any issues or have suggestions for improvement, please open an issue or submit a pull request.

- Fork the repository.

- Create a new branch for your feature or bugfix.

- Commit your changes.

- Push to the branch.

- Submit a pull request.

---

## License
This project is licensed under the MIT License. See the LICENSE file for details.

Happy coding! 🚀
