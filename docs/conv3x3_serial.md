# Serial 3x3 Convolution Engine

## Goal

Implement and simulate a serial 3x3 convolution engine for the CNN-on-FPGA project.

## Module

rtl/conv3x3_serial.v

## Testbench

sim/tb_conv3x3_serial.v

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

Expected result:

-1

## Simulation Result

The ModelSim simulation produced:

Convolution result = -1  
Expected result = -1  
TEST PASSED

## Notes

The design uses one multiplier repeatedly over 9 clock cycles instead of using 9 parallel multipliers.