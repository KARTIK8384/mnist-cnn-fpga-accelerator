# AGENTS.md — Codex Instructions for MNIST CNN FPGA Accelerator

These instructions apply to the entire repository.

Read `AI_PLAN.md` before starting any non-trivial implementation task.

---

## 1. Project Identity

This repository implements a small fixed-point MNIST CNN inference accelerator for:

```text
Board:       Terasic DE0-Nano
FPGA family: Intel/Altera Cyclone IV
HDL:         Verilog-2001
Synthesis:   Quartus Prime Lite 18.1
Simulation:  ModelSim-Intel FPGA Edition
Reference:   Python
```

Do not silently retarget this project to Xilinx/AMD, Vivado, another FPGA family, or another HDL.

---

## 2. First Actions for Every Task

Before editing:

1. Read this file.
2. Read `AI_PLAN.md`.
3. Inspect the relevant RTL, testbench, and documentation.
4. Run `git status`.
5. Determine the current branch.
6. Verify whether the requested roadmap item is already implemented.
7. Preserve known-working behavior unless the task explicitly requires a change.

The current working tree is the source of truth. Do not assume it matches an earlier chat description.

---

## 3. Repository Roles

Use directories consistently:

```text
rtl/      synthesizable Verilog RTL
sim/      ModelSim testbenches
docs/     module/design documentation
data/     HEX/MIF/test-vector/model data
python/   Python training, quantization, export, and reference scripts
```

Do not put testbenches in `rtl/`.

Do not treat `sim/*.v` as Quartus synthesis sources.

---

## 4. Quartus Top-Level Rule

The board-level Quartus top is:

```text
cnn_top
```

Keep `cnn_top` as the board-facing wrapper unless the user explicitly changes this strategy.

Internal processing modules should be instantiated under `cnn_top`.

Do not make modules with large internal buses the FPGA top just to synthesize them. That can map internal data to hundreds of physical I/O pins.

The top level should expose only real board interfaces such as:

```text
CLOCK_50
KEY
SW
LED
```

or explicitly added board pins.

---

## 5. Simulation Top-Level Rule

For ModelSim, the testbench is the simulation top.

Examples:

```text
tb_conv3x3_serial
tb_relu
tb_maxpool2x2
tb_argmax
tb_conv_relu
tb_conv5x5_demo
```

Do not confuse Quartus synthesis top with ModelSim simulation top.

---

## 6. Verilog Style

Default to synthesizable Verilog-2001.

Do not introduce SystemVerilog-only syntax unless the user explicitly approves it.

Preferred style:

- one clear module per source file,
- descriptive signal names,
- explicit widths,
- explicit signed declarations,
- parameters for reusable widths,
- nonblocking assignments (`<=`) in clocked sequential blocks,
- blocking assignments (`=`) in combinational blocks,
- complete combinational assignments to avoid unintended latches,
- `localparam` state encodings,
- comments for non-obvious timing/arithmetic behavior.

Keep the code easy to learn from.

---

## 7. Arithmetic Rules

Current baseline:

```text
DATA_WIDTH = 8
ACC_WIDTH  = 32
```

When multiplying signed values, make the product signed and wide enough.

Example:

```verilog
wire signed [2*DATA_WIDTH-1:0] product;
```

Sign-extend before adding to a wider accumulator when needed.

Never rely on ambiguous signed/unsigned implicit conversions.

When changing arithmetic, verify:

- sign behavior,
- product width,
- accumulator width,
- overflow assumptions,
- bias width,
- ReLU behavior,
- quantization/scaling.

Do not change fixed-point scaling rules in RTL without updating the Python reference and documentation.

---

## 8. Verification Is Mandatory

A compile is not proof of correctness.

Every functional RTL feature should have a ModelSim testbench.

A task is not complete until the test checks actual values against independently established expected values.

Never make a failing test pass by changing the expected values merely to match current RTL output.

If an expected value is wrong:

1. independently recompute it,
2. explain why the previous value was wrong,
3. update the test/documentation,
4. rerun verification.

Prefer self-checking tests that clearly print:

```text
TEST PASSED
```

or:

```text
TEST FAILED
```

---

## 9. Known 5x5 Reference Case

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

Any storage-only refactor of this demo must preserve this result.

---

## 10. ModelSim Workflow

Prefer explicit compilation when debugging.

Typical flow from repository root:

```tcl
vlib work
vlog rtl/<dependency1>.v
vlog rtl/<dependency2>.v
vlog rtl/<module>.v
vlog sim/<testbench>.v
vsim <testbench>
run -all
```

Compile dependencies before modules that instantiate them.

For file-backed memories, run simulation from the repository root when RTL uses relative paths such as:

```verilog
$readmemh("data/image_5x5.hex", memory);
```

If ModelSim reports that a design unit was not found, first verify that all dependencies were compiled.

---

## 11. Quartus Workflow

Only synthesizable RTL belongs in the Quartus synthesis project.

Do not add:

```text
sim/*.v
```

After meaningful synthesizable changes:

1. run Analysis & Synthesis when available,
2. run full compilation when board-level integration is being checked,
3. inspect warnings,
4. distinguish RTL errors from fitter/pin errors.

Do not ignore a fitter error caused by accidentally exposing internal data as top-level I/O.

---

## 12. Memory Strategy

The project evolves through increasingly realistic storage:

```text
hardcoded demo values
        ↓
dedicated ROM modules
        ↓
HEX / MIF initialized memories
        ↓
Python-generated files
        ↓
full MNIST image + trained weights
```

Use `data/` for committed, reproducible memory content.

For simulation, `$readmemh` with HEX files is acceptable.

For Quartus, use supported inferred ROM/MIF or Intel memory structures only when appropriate.

Do not introduce vendor IP prematurely if simple inferred RTL is sufficient.

---

## 13. Python Responsibilities

Python is the golden software/reference side of the project.

Python should eventually:

- load MNIST,
- train/load the tiny CNN,
- quantize weights,
- quantize inputs/activations,
- export memory files,
- compute fixed-point reference outputs,
- generate RTL verification vectors.

Keep floating-point training behavior separate from fixed-point inference behavior.

Compare RTL against the fixed-point reference path.

---

## 14. Architecture Preference

Correctness and clarity come before speed.

Prefer a serial/resource-efficient implementation first:

```text
one multiplier / MAC datapath
        ↓
reused across kernel elements
        ↓
reused across output positions
        ↓
reused across filters where practical
```

Only add parallel multipliers, multiple PEs, pipelining, or systolic structures after the baseline complete CNN works.

---

## 15. FSM Guidelines

Keep controllers understandable.

Use named states with `localparam`.

Typical pattern:

```text
IDLE
INIT
SETUP / READ
MAC
STORE
NEXT
DONE
```

Be careful with nonblocking-assignment timing.

If a datapath consumes `pixel_in` and `weight_in` on a clock edge, values assigned with nonblocking assignments on that same edge are not already visible to the consumer.

When timing is ambiguous, add an explicit setup state.

---

## 16. Preserve Working Interfaces

Before changing a module interface:

- inspect every instantiation,
- inspect its testbench,
- understand why the change is necessary.

Prefer wrapping/extending a working block over unnecessary rewrites.

Do not delete completed primitive modules because a newer integration module exists.

---

## 17. Documentation Requirements

Every meaningful feature should have a matching file under `docs/`.

Documentation should include:

- purpose,
- inputs/outputs,
- architecture,
- working explanation,
- FSM/control flow,
- arithmetic,
- example calculation,
- expected output,
- simulation procedure,
- observed result,
- importance to the final CNN.

Update documentation in the same task whenever behavior changes.

Do not document unverified behavior as completed.

---

## 18. Git Rules

Use descriptive branches:

```text
feature/<task-name>
```

Examples:

```text
feature/serial-conv3x3
feature/relu-activation
feature/maxpool2x2
feature/argmax-classifier
feature/conv-relu-integration
feature/five-by-five-conv-demo
feature/rom-based-conv-demo
feature/file-based-rom-demo
```

Before changing branches:

```bash
git status
```

Do not:

- force-push,
- rewrite history,
- amend unrelated commits,
- merge to `main`,
- delete branches,
- push changes,

unless the user explicitly asks.

When asked to prepare a commit, include only relevant source, test, documentation, and reproducible data files.

---

## 19. Generated Files Stay Out of Git

Do not intentionally add temporary Quartus/ModelSim output such as:

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

If a generated file causes a permission or Git error, fix the ignore/workflow issue instead of committing the generated artifact.

---

## 20. Change Discipline

For each task:

1. identify the smallest coherent change,
2. explain the intended architecture,
3. implement it,
4. add/update the test,
5. run or provide the exact verification procedure,
6. inspect the result,
7. update docs,
8. summarize changed files.

Avoid unrelated cleanup.

Do not refactor the whole repository during a focused feature task.

---

## 21. Failure Handling

If simulation or compile fails:

- do not claim success,
- do not hide the failure,
- capture the exact error,
- classify it as syntax, elaboration, timing/control, arithmetic, memory-path, or fitting/pin related,
- make the smallest targeted fix,
- rerun the relevant verification.

If Quartus or ModelSim cannot be executed in the current environment, say so and provide exact local commands.

Never fabricate tool output.

---

## 22. Roadmap Source

`AI_PLAN.md` is the authoritative roadmap.

When the user says:

```text
continue
```

or:

```text
do the next step
```

first inspect the current repository and compare it with the **Immediate Next Task** section of `AI_PLAN.md`.

Do not blindly create something that already exists.

---

## 23. Definition of Done

Before calling a feature complete, verify all applicable items:

```text
[ ] RTL implemented
[ ] syntax/elaboration clean
[ ] dependencies correct
[ ] testbench created or updated
[ ] expected values independently verified
[ ] functional simulation passes
[ ] no accidental testbench synthesis
[ ] Quartus checked when appropriate
[ ] documentation updated
[ ] no unrelated generated files added
[ ] git diff is focused
```

---

## 24. Project Priorities

Use this priority order:

```text
1. mathematical correctness
2. deterministic verification
3. synthesizability
4. clarity / learnability
5. FPGA resource efficiency
6. performance
7. convenience
```

---

## 25. Final Reminder

This is a learning-oriented FPGA accelerator project, not a generic software repository.

Keep hardware behavior explicit.

Whenever possible, explain:

```text
what happens on each clock,
what is stored,
what address is being read,
what arithmetic is performed,
when the result becomes valid,
and how the test proves correctness.
```
