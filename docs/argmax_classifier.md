# Argmax Classifier

## Purpose

The argmax block selects the predicted digit from the CNN output scores.

## Function

The fully connected layer produces 10 class scores, one for each MNIST digit from 0 to 9.

The argmax module compares all 10 scores and returns the index of the largest score.

## Example

Scores:

- class 0: -5
- class 1: 12
- class 2: 3
- class 3: 40
- class 4: 7
- class 5: 9
- class 6: 1
- class 7: 2
- class 8: 15
- class 9: 6

Largest score: 40  
Predicted class: 3

## Hardware Design

This module is combinational and does not require a clock.

It starts with class 0 as the current maximum, then compares classes 1 through 9.

## Files

- rtl/argmax.v
- sim/tb_argmax.v

## Test Cases

| Test | Expected Class |
|---|---:|
| Class 3 has largest score | 3 |
| Class 0 has largest score | 0 |
| Class 9 has largest score among negative scores | 9 |
| Tie case between class 1 and 2 | 1 |

## Simulation Result

The testbench should print TEST PASSED.