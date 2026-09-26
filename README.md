
# AI-Accelerator

> **Design and Performance Evaluation of an Energy-Efficient AI Inference Accelerator for Sustainable Data Center Computing**

FPGA-based AI inference accelerator using a **4×4 pipelined INT8 systolic array** for accelerating CNN matrix multiplication (GEMM), with emphasis on parallel processing, on-chip memory utilization, performance, and power efficiency.

---

## 📌 Overview

Artificial Intelligence workloads in modern data centers require large amounts of computational resources, particularly for operations such as matrix multiplication and convolution.

This project presents an **FPGA-based AI inference accelerator** designed to improve the computational efficiency of CNN workloads using a **4×4 pipelined INT8 systolic array**.

The selected **MobileNetV2 1×1 convolution** is converted into an **INT8 GEMM workload** and mapped onto a systolic-array architecture containing **16 Processing Elements (PEs)**.

The accelerator uses:

- INT8 arithmetic
- INT32 accumulation
- 4×4 systolic array
- 16 parallel Processing Elements
- BRAM-based input and weight storage
- Dedicated systolic controller
- Pipelined computation
- Verilog HDL
- AMD/Xilinx Vivado

The design is evaluated in terms of **FPGA resource utilization, clock frequency, power consumption, and implementation characteristics**.

---

## 🎯 Objectives

- Design an energy-efficient AI inference accelerator using FPGA technology.
- Implement parallel INT8 multiply-accumulate operations.
- Accelerate CNN matrix multiplication using a systolic-array architecture.
- Reduce data movement using on-chip BRAM.
- Develop and verify the accelerator using Verilog HDL.
- Analyze FPGA resource utilization.
- Evaluate power consumption and implementation characteristics.
- Investigate FPGA-based acceleration for sustainable AI computing.

---

## 🧠 Target AI Workload

The accelerator targets a **MobileNetV2 1×1 convolution layer**.

The convolution operation is transformed into a matrix multiplication workload:

```text
MobileNetV2
     │
     ▼
1×1 Convolution
     │
     ▼
    GEMM
     │
     ▼
INT8 Quantization
     │
     ▼
4×4 Systolic Array
     │
     ▼
INT32 Accumulation
     │
     ▼
Output
````

---

## 🏗️ System Architecture

```text
                 ┌─────────────────────┐
                 │    Input Data       │
                 │      INT8           │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │     Input Memory    │
                 │        BRAM         │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ Systolic Controller │
                 └──────────┬──────────┘
                            │
                            ▼
          ┌─────────────────────────────────┐
          │        4 × 4 Systolic Array     │
          │                                 │
          │  ┌────┐ ┌────┐ ┌────┐ ┌────┐  │
          │  │ PE │ │ PE │ │ PE │ │ PE │  │
          │  ├────┤ ├────┤ ├────┤ ├────┤  │
          │  │ PE │ │ PE │ │ PE │ │ PE │  │
          │  ├────┤ ├────┤ ├────┤ ├────┤  │
          │  │ PE │ │ PE │ │ PE │ │ PE │  │
          │  ├────┤ ├────┤ ├────┤ ├────┤  │
          │  │ PE │ │ PE │ │ PE │ │ PE │  │
          │  └────┘ └────┘ └────┘ └────┘  │
          │                                 │
          │        16 Processing Elements   │
          └────────────────┬────────────────┘
                           │
                           ▼
                 ┌─────────────────────┐
                 │  INT32 Accumulation  │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │       Output        │
                 └─────────────────────┘
```

---

## ⚙️ Accelerator Configuration

| Parameter           | Configuration           |
| ------------------- | ----------------------- |
| AI Model            | MobileNetV2             |
| Target Operation    | 1×1 Convolution         |
| Computation         | GEMM                    |
| Architecture        | 4×4 Systolic Array      |
| Processing Elements | 16                      |
| Input Precision     | INT8                    |
| Weight Precision    | INT8                    |
| Accumulator         | INT32                   |
| Memory              | FPGA BRAM               |
| HDL                 | Verilog                 |
| Simulation          | Xilinx Vivado Simulator |
| FPGA                | Artix-7 XC7A100T        |
| Clock Frequency     | 100 MHz                 |

---

## 🔢 Processing Element

Each Processing Element performs the fundamental multiply-accumulate operation:

```text
ACC = ACC + (A × B)
```

The 4×4 array contains **16 Processing Elements**, allowing multiple INT8 MAC operations to execute in parallel.

```text
        Activation
            │
            ▼
       ┌─────────┐
Weight ─►   PE    │
       │         │
       │ INT8 MAC│
       └────┬────┘
            │
            ▼
        INT32 ACC
```

Data is propagated through the systolic array to achieve data reuse and parallel computation.

---

## 💾 Memory Architecture

The design uses on-chip **BRAM** for input and weight storage.

```text
        ┌──────────────┐
        │ Input Memory │
        │    BRAM      │
        └──────┬───────┘
               │
               ▼
        ┌──────────────┐
        │   Controller │
        └──────┬───────┘
               │
               ▼
        ┌──────────────┐
        │ 4×4 Systolic │
        │    Array     │
        └──────┬───────┘
               │
               ▼
        ┌──────────────┐
        │    Output    │
        └──────────────┘
```

On-chip memory enables localized data storage and reduces unnecessary data movement during computation.

---

## 📁 Repository Structure

The current repository is organized as follows:

```text
AI-Accelerator/
│
├── Design Sources/
│   ├── accelerator_top.v
│   ├── input1.v
│   ├── input_memory.v
│   ├── pe_int8.v
│   ├── systolic_4x4.v
│   ├── systolic_controller.v
│   ├── weight1.v
│   └── weight_memory.v
│
├── Simulation sources/
│   ├── accelerator_top_tb.v
│   ├── systolic_4x4_pipe_tb.v
│   └── systolic_4x4_tb.v
│
└── README.md
```

---

## 🧩 Design Sources

### `accelerator_top.v`

Top-level module that integrates the major accelerator components.

### `pe_int8.v`

Implements the INT8 Processing Element responsible for the multiply-accumulate computation.

### `systolic_4x4.v`

Implements the 4×4 systolic-array architecture.

### `systolic_controller.v`

Controls the data movement and operation of the systolic array.

### `input_memory.v`

Provides storage for input/activation data.

### `weight_memory.v`

Provides storage for weight data.

### `input1.v`

Contains input data used by the accelerator.

### `weight1.v`

Contains weight data used by the accelerator.

---

## 🧪 Simulation Sources

The repository contains dedicated testbenches for functional verification.

### `accelerator_top_tb.v`

Top-level accelerator verification.

### `systolic_4x4_tb.v`

Verification of the 4×4 systolic-array architecture.

### `systolic_4x4_pipe_tb.v`

Verification of the pipelined systolic-array implementation.

---

## 🔬 Verification Flow

```text
Verilog RTL
     │
     ▼
Testbench
     │
     ▼
Behavioral Simulation
     │
     ▼
Waveform Analysis
     │
     ▼
Functional Verification
     │
     ▼
Synthesis
     │
     ▼
Implementation
     │
     ▼
Timing & Power Analysis
```

The simulation verifies the functionality of the Processing Elements, systolic array, controller, memory modules, and top-level accelerator.

---

## 📊 FPGA Implementation Results

The accelerator was evaluated on an **Artix-7 XC7A100T FPGA** at a **100 MHz clock frequency**.

### Resource Utilization

| FPGA Resource   | Utilization |
| --------------- | ----------: |
| LUT             |   **3.79%** |
| Flip-Flops      |   **1.19%** |
| BRAM            |  **77.41%** |
| I/O             |  **17.14%** |
| Clock Frequency | **100 MHz** |

The implementation shows low LUT and Flip-Flop utilization, while BRAM is the major utilized FPGA resource due to the on-chip input and weight memory architecture.

---

## ⚡ Power Analysis

| Power Metric         |      Result |
| -------------------- | ----------: |
| Total Power          | **0.184 W** |
| Dynamic Power        | **0.088 W** |
| Static Power         | **0.096 W** |
| Systolic Array Power | **0.024 W** |
| Controller Power     | **0.013 W** |
| Input Memory Power   | **0.019 W** |
| Junction Temperature |  **25.8°C** |
| Power Confidence     |  **Medium** |

---

## 📈 Evaluation Metrics

The accelerator is evaluated using:

* Clock frequency
* FPGA resource utilization
* Power consumption
* Dynamic power
* Static power
* Memory utilization
* Systolic-array power
* Controller power
* Input-memory power
* Junction temperature

### Summary

```text
                    AI Workload
                         │
                         ▼
                  INT8 Quantization
                         │
                         ▼
                 4×4 Systolic Array
                         │
                         ▼
                  Parallel INT8 MAC
                         │
                         ▼
                   INT32 Output
                         │
             ┌───────────┴───────────┐
             ▼                       ▼
       Performance               Power
        Analysis                Analysis
```

---

## 🔧 Development Tools

| Category         | Tool / Technology       |
| ---------------- | ----------------------- |
| HDL              | Verilog HDL             |
| FPGA Development | AMD/Xilinx Vivado       |
| Simulation       | Xilinx Vivado Simulator |
| AI Model         | MobileNetV2             |
| Deep Learning    | PyTorch                 |
| FPGA Device      | Artix-7 XC7A100T        |
| Arithmetic       | INT8 / INT32            |
| Architecture     | 4×4 Systolic Array      |
| Memory           | BRAM                    |

---

## 🚀 How to Use

### 1. Clone the Repository

```bash
git clone https://github.com/dineshraja-dr/AI-Accelerator.git
```

### 2. Open the Project in Vivado

Open AMD/Xilinx Vivado and create/configure the FPGA project for the target Artix-7 device.

### 3. Add Design Sources

Add all files from:

```text
Design Sources/
```

### 4. Add Simulation Sources

Add the required testbench from:

```text
Simulation sources/
```

### 5. Set the Top Module

For the complete accelerator:

```text
accelerator_top
```

For individual verification, use the corresponding testbench.

### 6. Run Simulation

Run:

```text
Simulation → Run Behavioral Simulation
```

Verify the waveform and output values.

### 7. Run Synthesis

Run:

```text
Synthesis → Run Synthesis
```

### 8. Run Implementation

Run:

```text
Implementation → Run Implementation
```

### 9. Generate Reports

Analyze:

```text
Utilization Report
Timing Report
Power Report
```

---

## 🔄 Complete Project Flow

```text
          MobileNetV2
              │
              ▼
       1×1 Convolution
              │
              ▼
             GEMM
              │
              ▼
       INT8 Quantization
              │
              ▼
        Input / Weight
            Memory
              │
              ▼
      Systolic Controller
              │
              ▼
       4×4 Systolic Array
              │
              ▼
        16 Processing
           Elements
              │
              ▼
       INT32 Accumulation
              │
              ▼
           Output
              │
              ▼
     FPGA Evaluation
              │
       ┌──────┴──────┐
       ▼             ▼
   Resource        Power
   Analysis       Analysis
```

---

## ⭐ Key Features

* 4×4 pipelined systolic array
* 16 parallel Processing Elements
* INT8 multiply-accumulate computation
* INT32 accumulation
* MobileNetV2 1×1 convolution mapping
* GEMM-based CNN acceleration
* BRAM-based input and weight storage
* Dedicated systolic controller
* 100 MHz operating frequency
* FPGA resource analysis
* Power analysis
* Hardware-oriented AI inference architecture

---

## 🔮 Future Work

Future development includes:

* [ ] Scale the systolic array to 8×8
* [ ] Explore 16×16 systolic-array architectures
* [ ] Support additional CNN models
* [ ] Evaluate ResNet and VGG workloads
* [ ] Explore weight-stationary dataflow
* [ ] Explore output-stationary dataflow
* [ ] Improve BRAM utilization
* [ ] Optimize DSP utilization
* [ ] Investigate INT4/INT8 quantization
* [ ] Explore pruning techniques
* [ ] Investigate clock gating
* [ ] Explore dynamic voltage/frequency scaling
* [ ] Evaluate energy per inference
* [ ] Improve performance-per-watt

---

## 🌱 Sustainable AI Computing

The project focuses on energy-efficient AI inference and FPGA-based computing for sustainable data-center infrastructure.

It is aligned with:

**SDG 9 – Industry, Innovation and Infrastructure**

The project investigates efficient hardware architecture, parallel processing, and localized memory access for AI inference workloads.

---




## 📌 Project Status

**🚧 Under Development**

Current implementation includes the RTL design of the **4×4 INT8 systolic-array accelerator**, Processing Elements, memories, controller, and simulation testbenches.

The project is being further developed toward comprehensive FPGA performance, timing, power, and energy-efficiency evaluation.


