# 2x2 MaxPool Module

## Purpose

The 2x2 max pooling block reduces the spatial size of a feature map by selecting the maximum value from each 2x2 window.

## Function

Given four inputs:

a b  
c d  

The module outputs:

max(a, b, c, d)

## Hardware Design

The design is combinational and uses two comparison stages:

1. Compare a and b
2. Compare c and d
3. Compare the two intermediate maximum values

## Files

- rtl/maxpool2x2.v
- sim/tb_maxpool2x2.v

## Test Cases

| a | b | c | d | Expected |
|---:|---:|---:|---:|---:|
| 3 | 7 | 2 | 5 | 7 |
| 10 | 4 | 6 | 1 | 10 |
| -3 | -7 | -2 | -5 | -2 |
| 0 | 0 | 0 | 0 | 0 |
| 8 | 8 | 4 | 1 | 8 |

## Simulation Result

The testbench should print TEST PASSED.