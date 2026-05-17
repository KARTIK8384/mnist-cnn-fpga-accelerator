# ReLU Activation

## Purpose

The ReLU activation function is used after convolution in the CNN pipeline.

## Function

If the input is negative, the output becomes 0.  
If the input is zero or positive, the output stays the same.

## Formula

ReLU(x) = max(0, x)

## Hardware Design

The module is combinational and does not require a clock.

## Files

- rtl/relu.v
- sim/tb_relu.v

## Test Cases

| Input | Expected Output |
|---:|---:|
| -10 | 0 |
| 0 | 0 |
| 25 | 25 |
| -1 | 0 |
| 100 | 100 |

## Simulation Result

The testbench should print TEST PASSED.