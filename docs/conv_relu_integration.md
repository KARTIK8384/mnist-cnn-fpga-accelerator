# Conv + ReLU Integration

## Purpose

This step integrates the serial 3x3 convolution engine with the ReLU activation block.

## Pipeline

3x3 input window  
↓  
Serial 3x3 convolution  
↓  
ReLU activation  
↓  
Activated output  

## Files

- rtl/conv_relu.v
- sim/tb_conv_relu.v

## Test Case

Input window:

1 2 0  
0 1 2  
1 0 1  

Kernel:

1  0 -1  
1  0 -1  
1  0 -1  

Bias:

0

## Expected Results

Convolution output:

-1

ReLU output:

0

## Simulation Result

The testbench should print TEST PASSED.

## Notes

This integration proves that a negative convolution result is correctly clipped to zero by ReLU.