# AI Plan — MNIST CNN FPGA Accelerator

**Repository:** `KARTIK8384/mnist-cnn-fpga-accelerator`  
**Target board:** Terasic DE0-Nano  
**FPGA:** Intel/Altera Cyclone IV  
**Primary HDL:** Verilog-2001  
**Synthesis:** Quartus Prime Lite 18.1  
**Simulation:** ModelSim-Intel FPGA Edition  
**Reference/software flow:** Python

> This file is the master project roadmap. `AGENTS.md` contains the working rules for Codex/AI agents.

---

## 1. Project Goal

Build a small fixed-point CNN accelerator that classifies 28x28 MNIST handwritten digits on the DE0-Nano FPGA.

Development path:

```text
basic RTL blocks
    ↓
CNN primitives
    ↓
small convolution demos
    ↓
memory-backed data
    ↓
Python-generated fixed-point vectors
    ↓
28x28 convolution
    ↓
multiple filters
    ↓
max pooling
    ↓
fully connected classifier
    ↓
argmax
    ↓
complete CNN
    ↓
DE0-Nano hardware demo
```

Priorities:

1. mathematical correctness,
2. deterministic verification,
3. synthesizable RTL,
4. clear architecture,
5. resource efficiency,
6. performance optimization.

---

## 2. Repository Organization

```text
mnist-cnn-fpga-accelerator/
├── AGENTS.md
├── AI_PLAN.md
├── README.md
├── LICENSE
├── cnn_on_fpga.qpf
├── cnn_top.qsf
├── rtl/
├── sim/
├── docs/
├── data/      # memory images, weights, vectors
└── python/    # later: training, quantization, export, reference model
```

### `rtl/`
Synthesizable Verilog RTL.

Current core modules:

```text
argmax.v
cnn_top.v
conv3x3_serial.v
conv5x5_demo.v
conv_relu.v
maxpool2x2.v
relu.v
```

### `sim/`
ModelSim testbenches only. These must not be synthesized by Quartus.

### `docs/`
Working explanations and verification notes for completed modules.

### `data/`
HEX/MIF files for images, kernels, weights, biases, and test vectors.

### `python/`
Future training, quantization, export, and golden-reference scripts.

---

## 3. Hardware and Toolchain Rules

Target:

```text
Board:        DE0-Nano
FPGA family:  Cyclone IV
Quartus:      Prime Lite 18.1
Simulation:   ModelSim-Intel FPGA Edition
HDL:          Verilog-2001
```

For FPGA synthesis, the board-level top module remains:

```text
cnn_top
```

Internal modules are instantiated below `cnn_top`.

For ModelSim, the simulation top is the relevant testbench.

Do not expose large internal feature maps as physical board I/O merely to synthesize a module.

---

## 4. Arithmetic Strategy

Current baseline:

```text
pixel width:       8-bit signed
weight width:      8-bit signed
accumulator width: 32-bit signed
```

Rules:

- preserve signed multiplication,
- sign-extend products before wider accumulation,
- use wide accumulators,
- apply ReLU after convolution,
- define fixed-point scaling in Python and match it exactly in RTL,
- document any saturation, truncation, rounding, or rescaling rule.

---

# 5. Completed Work

## 5.1 Serial 3x3 Convolution

File:

```text
rtl/conv3x3_serial.v
```

Purpose:

- compute one 3x3 convolution,
- reuse a single multiplier over nine pixel/weight pairs,
- accumulate the products,
- add bias,
- use `start`, `busy`, `done`, and an index counter.

Concept:

```text
9 pixel/weight pairs
        ↓
serial multiply-accumulate
        ↓
one convolution result
```

Verified in ModelSim.

---

## 5.2 ReLU

File:

```text
rtl/relu.v
```

Function:

```text
ReLU(x) = max(0, x)
```

Verified in ModelSim.

---

## 5.3 2x2 Max Pool

File:

```text
rtl/maxpool2x2.v
```

Function:

```text
a b
c d

→ max(a,b,c,d)
```

Verified with positive, negative, zero, and duplicate-maximum cases.

---

## 5.4 Argmax Classifier

File:

```text
rtl/argmax.v
```

Compares ten class scores and returns the index of the largest score:

```text
predicted_class = 0..9
```

Verified in ModelSim, including negative scores and ties.

---

## 5.5 Convolution + ReLU Integration

File:

```text
rtl/conv_relu.v
```

Pipeline:

```text
pixel/weight stream
        ↓
3x3 convolution
        ↓
raw result
        ↓
ReLU
        ↓
non-negative output
```

Verified in ModelSim.

---

## 5.6 5x5 Sliding-Window Convolution Demo

Files:

```text
rtl/conv5x5_demo.v
sim/tb_conv5x5_demo.v
docs/5x5_conv_demo.md
```

Input image:

```text
1 2 0 1 1
0 1 2 2 0
1 0 1 0 1
2 1 0 1 0
1 2 1 0 1
```

Kernel:

```text
 1  0 -1
 1  0 -1
 1  0 -1
```

Raw valid-convolution output:

```text
-1  0  1
 0 -1  2
 2  2  0
```

After ReLU:

```text
0 0 1
0 0 2
2 2 0
```

ModelSim result:

```text
TEST PASSED
```

This proves sliding-window addressing, MAC operation, ReLU application, and generation of a complete feature map.

---

# 6. Current Stage — Memory-Backed Convolution

The next architecture step is to separate storage from compute.

Current small demo:

```text
conv5x5_demo
├── image values
├── kernel values
└── convolution controller
```

Target:

```text
image ROM ───────┐
                 ├──> convolution controller/MAC ──> ReLU
kernel ROM ──────┘
```

This prepares the project for MNIST images and trained CNN weights.

---

## 6.1 Immediate Next Task — ROM-Based 5x5 Demo

Branch:

```text
feature/rom-based-conv-demo
```

Planned files:

```text
rtl/image_rom_5x5.v
rtl/kernel_rom_3x3.v
rtl/conv5x5_rom_demo.v
sim/tb_conv5x5_rom_demo.v
docs/rom_based_conv_demo.md
```

Required mathematical result must remain:

```text
0 0 1
0 0 2
2 2 0
```

This task changes storage architecture, not the convolution math.

---

## 6.2 File-Initialized ROM

After the ROM module version passes, move image/kernel values into files.

Planned files:

```text
data/image_5x5.hex
data/kernel_3x3.hex
rtl/image_rom_5x5_hex.v
rtl/kernel_rom_3x3_hex.v
rtl/conv5x5_hex_demo.v
sim/tb_conv5x5_hex_demo.v
docs/file_based_rom_demo.md
```

Simulation can use `$readmemh`.

Quartus initialization can later use an FPGA-supported ROM/MIF flow where appropriate.

Goal:

```text
external data file
        ↓
ROM
        ↓
RTL accelerator
```

The RTL should not need manual source edits each time data changes.

---

# 7. Python Reference and Data Pipeline

After file-backed ROM works, add Python.

Suggested files:

```text
python/generate_test_vectors.py
python/train_mnist.py
python/quantize_model.py
python/export_weights.py
python/reference_inference.py
```

Python responsibilities:

1. load MNIST,
2. train or load a tiny CNN,
3. quantize weights and biases,
4. quantize input images/activations,
5. export HEX/MIF-compatible files,
6. compute fixed-point reference outputs,
7. generate self-checking RTL test vectors.

**Python fixed-point inference becomes the golden functional reference.**

Do not compare RTL only against unconstrained floating-point inference.

---

# 8. Proposed Tiny CNN Architecture

Initial target:

```text
28x28x1 image
      ↓
3x3 convolution, 4 filters
      ↓
26x26x4
      ↓
ReLU
      ↓
2x2 max pool
      ↓
13x13x4
      ↓
flatten
      ↓
676 features
      ↓
fully connected
      ↓
10 class scores
      ↓
argmax
      ↓
digit 0–9
```

This architecture may be adjusted after accuracy, resource, and timing measurements.

The first goal is a clean working hardware CNN, not maximum neural-network accuracy.

---

# 9. Full 28x28 Convolution Stage

Input:

```text
28x28
```

Kernel:

```text
3x3
```

Valid convolution output per filter:

```text
26x26 = 676 output positions
```

Serial MAC work per filter:

```text
676 × 9 = 6084 multiply-accumulate steps
```

At this stage, begin measuring cycle counts and latency.

---

# 10. Multiple Filters

Initial target:

```text
4 convolution filters
```

Each filter contains:

```text
9 weights + 1 bias
```

Four filters produce:

```text
26x26x4
```

The first implementation should favor resource reuse. One serial MAC may be reused across filters.

---

# 11. Feature-Map Storage

Large feature maps must use internal memory rather than top-level wires.

Target structure:

```text
Convolution Core
      ↓
Feature RAM
      ↓
Max Pool
      ↓
Pooled Feature RAM
```

Use addresses, counters, and control handshakes.

---

# 12. Max-Pool Integration

Existing primitive:

```text
maxpool2x2.v
```

System behavior:

```text
26x26 feature map
        ↓
2x2 max pooling
        ↓
13x13 feature map
```

For four filters:

```text
13 × 13 × 4 = 676 pooled values
```

---

# 13. Fully Connected Layer

Input:

```text
676 pooled values
```

Output:

```text
10 class scores
```

Equation:

```text
score[class] = bias[class] + Σ feature[i] × weight[class][i]
```

Approximate weight count:

```text
676 × 10 = 6760 weights
```

Start with a serial MAC architecture.

---

# 14. Final Argmax

Reuse the existing argmax block.

Input:

```text
10 signed class scores
```

Output:

```text
predicted_digit[3:0]
```

---

# 15. Target Final Architecture

```text
                    +----------------------+
MNIST image ------> | Image ROM / RAM      |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    | CNN Controller FSM   |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    | Serial Conv MAC Core |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    | ReLU                 |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    | Feature Memory       |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    | 2x2 Max Pool         |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    | Pooled Feature RAM   |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    | Fully Connected MAC  |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    | 10 Class Scores      |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    | Argmax               |
                    +----------+-----------+
                               |
                               v
                         Predicted digit
```

---

# 16. Controller FSM

The final controller should sequence the CNN stages.

High-level flow:

```text
IDLE
  ↓
LOAD / READ IMAGE
  ↓
CONVOLUTION
  ↓
RELU / STORE
  ↓
POOL
  ↓
FULLY CONNECTED
  ↓
ARGMAX
  ↓
DONE
```

Important counters may include:

```text
filter_index
output_row
output_col
kernel_index
pool_row
pool_col
feature_index
class_index
weight_index
```

Prefer multiple clear subcontrollers/states over one unreadable monolithic FSM.

---

# 17. Verification Strategy

## Level 1 — Primitive Modules

```text
conv3x3_serial
relu
maxpool2x2
argmax
```

Status: completed.

## Level 2 — Small Integration

```text
conv + ReLU
5x5 sliding-window convolution
ROM-backed 5x5 convolution
file-backed 5x5 convolution
```

Status: first two completed; memory-backed work is next.

## Level 3 — Python Cross-Check

```text
same input
   ↓
Python fixed-point reference
   ↓
expected output

same input
   ↓
Verilog RTL
   ↓
actual output
```

Require exact equality unless a documented numerical tolerance is intentionally introduced.

## Level 4 — Full CNN Simulation

```text
MNIST image
   ↓
RTL CNN
   ↓
predicted digit
```

Compare against Python fixed-point inference.

## Level 5 — FPGA Hardware Validation

Program the DE0-Nano and provide a practical way to:

- select/load an image,
- start inference,
- observe `busy`,
- observe `done`,
- display the predicted digit.

---

# 18. ModelSim Workflow

Testbenches belong only in `sim/`.

Typical manual flow:

```tcl
vlib work
vlog rtl/<dependencies>.v
vlog rtl/<module_under_test>.v
vlog sim/<testbench>.v
vsim <testbench_module>
run -all
```

For the working 5x5 demo:

```tcl
vlib work
vlog rtl/relu.v
vlog rtl/conv5x5_demo.v
vlog sim/tb_conv5x5_demo.v
vsim tb_conv5x5_demo
run -all
```

---

# 19. Quartus Workflow

Quartus top-level:

```text
cnn_top
```

Only synthesizable RTL belongs in the synthesis file set.

Never add:

```text
sim/*.v
```

When an internal module needs board synthesis, instantiate it under `cnn_top` and expose only useful board-visible signals.

---

# 20. Git Workflow

`main` is the stable branch.

Use descriptive feature branches:

```text
feature/serial-conv3x3
feature/relu-activation
feature/maxpool2x2
feature/argmax-classifier
feature/conv-relu-integration
feature/five-by-five-conv-demo
feature/rom-based-conv-demo
feature/file-based-rom-demo
feature/python-test-vector-generation
feature/mnist-conv
feature/multi-filter-conv
feature/maxpool-integration
feature/fully-connected
feature/full-cnn
feature/de0-hardware-demo
```

Flow:

```text
main
 ↓
feature branch
 ↓
implement
 ↓
simulate
 ↓
verify
 ↓
document
 ↓
review diff
 ↓
commit / push / PR
 ↓
merge
```

---

# 21. Generated Files

Do not commit temporary Quartus/ModelSim output.

Typical ignored content:

```text
db/
incremental_db/
output_files/
simulation/
work/
rtl_work/
transcript
vsim.wlf
*.wlf
*.rpt
*.summary
*.done
*.smsg
*.pin
*.sof
*.pof
*.jdi
*.flock
```

Commit source and reproducible input data, not build artifacts.

---

# 22. Documentation Standard

Every meaningful module or integration step should have a matching file under `docs/`.

Documentation should explain:

1. purpose,
2. inputs and outputs,
3. architecture,
4. control/FSM flow,
5. arithmetic,
6. an example calculation,
7. expected output,
8. ModelSim procedure,
9. observed result,
10. why the module matters to the final CNN.

Documentation should teach the design rather than merely repeat the Verilog source.

---

# 23. Performance Measurements

Once the 28x28 design exists, record:

```text
cycles per convolution output
cycles per filter
cycles per image
inference latency
maximum clock frequency
logic elements
registers
memory bits
DSP / multiplier usage
```

Approximate latency:

```text
inference_time = total_cycles / clock_frequency
```

---

# 24. Optimization Roadmap

Correctness first.

Only after a complete serial CNN works, investigate:

- pipelined MAC,
- multiple multipliers,
- multiple processing elements,
- line buffers,
- sliding-window data reuse,
- dual-port RAM,
- concurrent memory and compute,
- parallel filters,
- systolic/semi-systolic architectures.

Do not optimize a design whose full reference behavior is not yet verified.

---

# 25. Definition of Done

A feature is complete only when all applicable items are satisfied:

```text
[ ] RTL implemented
[ ] no unexplained syntax/elaboration errors
[ ] dedicated testbench exists
[ ] expected values independently established
[ ] ModelSim output matches expected output
[ ] edge cases checked where appropriate
[ ] no accidental testbench synthesis
[ ] Quartus checked when synthesis is part of the step
[ ] documentation updated
[ ] git diff reviewed
[ ] feature branch is ready for PR
```

Compiling alone does not mean a feature is complete.

---

# 26. Next Three Tasks

### Task 1 — ROM-Based 5x5 Demo

```text
feature/rom-based-conv-demo
```

### Task 2 — File-Based ROM Demo

```text
feature/file-based-rom-demo
```

### Task 3 — Python Test-Vector Generation

```text
feature/python-test-vector-generation
```

The third step establishes the software-to-hardware data pipeline used for real MNIST images and trained model parameters.

---

# 27. Suggested Codex Prompt

```text
Read AGENTS.md and AI_PLAN.md first.

Inspect the current repository and git status. Do not assume roadmap items are
already implemented unless the current files/tests prove it.

Continue the immediate next task from AI_PLAN.md. Make the smallest clean
incremental change, add or update the ModelSim testbench and documentation,
and show me exactly what changed and how to verify it. Do not merge or push
anything unless I explicitly ask.
```

---

# 28. Final Success Criteria

The project is complete when:

```text
1. Python produces a quantized tiny CNN and FPGA memory files.
2. Verilog performs the same fixed-point inference.
3. RTL and Python match on known MNIST examples.
4. Quartus successfully synthesizes and fits the design for the DE0-Nano.
5. The FPGA performs inference on a 28x28 MNIST image.
6. The predicted digit is observable on hardware.
7. Resource usage, timing, and inference latency are documented.
8. The repository contains reproducible simulation and implementation instructions.
```

---

## Project Principle

> Build the simplest correct hardware first. Verify every layer. Make data movement explicit. Optimize only after the complete reference design works.
