# 5x5 Sliding-Window Convolution Demo

## Purpose

This step demonstrates a small CNN-style convolution operation using a 5x5 input image, a 3x3 kernel, and ReLU activation.

This is the first design step where the project moves from computing only one 3x3 convolution result to sliding a 3x3 kernel across a small image and producing a full output feature map.

This demo represents a small version of what will later happen in the MNIST CNN.

---

## Input Image

The module uses the following hardcoded 5x5 image:

```text
1 2 0 1 1
0 1 2 2 0
1 0 1 0 1
2 1 0 1 0
1 2 1 0 1
```

The image is stored internally as a 1D array.

A 2D pixel location is converted to a 1D memory index using:

```text
image_index = row * 5 + column
```

---

## Kernel

The 3x3 kernel used in this demo is:

```text
 1  0 -1
 1  0 -1
 1  0 -1
```

This kernel compares the left side of each 3x3 image window against the right side.

---

## Output Size

The input image is 5x5 and the kernel is 3x3.

Using valid convolution:

```text
output_size = input_size - kernel_size + 1
output_size = 5 - 3 + 1
output_size = 3
```

So the output feature map is:

```text
3x3
```

The module produces nine output values:

```text
out0 out1 out2
out3 out4 out5
out6 out7 out8
```

---

## Sliding Window Movement

The 3x3 kernel slides across the 5x5 image in valid positions only.

The window positions are:

```text
Window 0: row 0, col 0
Window 1: row 0, col 1
Window 2: row 0, col 2

Window 3: row 1, col 0
Window 4: row 1, col 1
Window 5: row 1, col 2

Window 6: row 2, col 0
Window 7: row 2, col 1
Window 8: row 2, col 2
```

Each window produces one output value.

---

## Example Calculation: out0

For `out0`, the 3x3 window starts at row 0, column 0.

The selected image window is:

```text
1 2 0
0 1 2
1 0 1
```

The kernel is:

```text
 1  0 -1
 1  0 -1
 1  0 -1
```

Element-by-element multiplication:

```text
1*1  + 2*0  + 0*(-1)
0*1  + 1*0  + 2*(-1)
1*1  + 0*0  + 1*(-1)
```

Result:

```text
1 + 0 + 0 + 0 + 0 - 2 + 1 + 0 - 1 = -1
```

Raw convolution output:

```text
out0_raw = -1
```

After ReLU:

```text
ReLU(-1) = 0
```

Final output:

```text
out0 = 0
```

---

## Full Raw Convolution Output

Before ReLU, the full 3x3 convolution output is:

```text
-1  0  1
 0 -1  2
 2  2  0
```

---

## ReLU Activation

ReLU is applied after convolution.

Formula:

```text
ReLU(x) = max(0, x)
```

So negative values become 0, and zero/positive values remain unchanged.

Applying ReLU to the raw convolution output:

```text
Raw:
-1  0  1
 0 -1  2
 2  2  0

After ReLU:
 0  0  1
 0  0  2
 2  2  0
```

---

## Expected Output

The expected final ReLU output feature map is:

```text
0 0 1
0 0 2
2 2 0
```

The testbench checks that the Verilog output matches this expected feature map.

---

## Module Working

The module works as a small finite state machine.

The main states are:

```text
IDLE
INIT_MAC
MAC
STORE
NEXT
DONE_STATE
```

### IDLE

The module waits for the `start` signal.

When `start = 1`, the module begins processing the 5x5 image.

### INIT_MAC

The accumulator is cleared before processing a new 3x3 window.

```verilog
acc <= 0;
kernel_index <= 0;
```

### MAC

The module performs multiply-accumulate operations for one 3x3 window.

For each kernel index from 0 to 8:

```text
acc = acc + image_pixel * kernel_weight
```

This computes one raw convolution result.

### STORE

The raw convolution result is passed through ReLU.

The ReLU output is stored into one of the output registers:

```text
out0, out1, out2, ..., out8
```

### NEXT

The module moves to the next 3x3 window position.

It updates:

```text
out_col
out_row
output_index
```

### DONE_STATE

After all nine output values have been computed, the module sets:

```text
done = 1
busy = 0
```

At this point, the full 3x3 output feature map is ready.

---

## Control Signals

### start

Starts the 5x5 convolution operation.

### busy

Indicates that the module is currently processing.

```text
busy = 1 -> module is working
busy = 0 -> module is idle
```

### done

Indicates that all nine output values are ready.

```text
done = 1 -> output feature map is complete
```

The testbench waits for `done` before checking the output values.

---

## Files

```text
rtl/conv5x5_demo.v
sim/tb_conv5x5_demo.v
docs/five_by_five_conv_demo.md
```

---

## Simulation Command

The simulation can be run in ModelSim using:

```tcl
vlib work
vlog rtl/conv5x5_demo.v
vlog rtl/relu.v
vlog sim/tb_conv5x5_demo.v
vsim tb_conv5x5_demo
run -all
```

---

## Simulation Result

ModelSim output:

```text
5x5 Conv + ReLU Demo Test

Output feature map:
0 0 1
0 0 2
2 2 0

Expected ReLU output:
0 0 1
0 0 2
2 2 0

TEST PASSED
```

---

## Importance of This Step

This step proves that the design can perform a real sliding-window convolution operation.

Previous step:

```text
one 3x3 window -> one output
```

Current step:

```text
5x5 image -> sliding 3x3 kernel -> 3x3 output feature map
```

This is the same core idea that will later be used for MNIST:

```text
28x28 image -> sliding 3x3 kernel -> 26x26 feature map
```

So this module is a small-scale version of the CNN convolution layer.
