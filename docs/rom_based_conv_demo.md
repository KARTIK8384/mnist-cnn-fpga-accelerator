# ROM-Based 5x5 Convolution Demo

## Purpose

This step moves the 5x5 image data and 3x3 kernel data out of the convolution module and into separate ROM-style memory modules.

The previous `conv5x5_demo.v` stored the image and kernel directly inside the convolution module.

This version separates:

- image storage,
- kernel storage,
- convolution control,
- ReLU activation.

This is an important step toward the final MNIST accelerator, where image pixels and trained CNN weights will come from memory rather than being hardcoded into the compute logic.

---

## Files

The main files used in this step are:

```text
rtl/image_rom_5x5_hex.v
rtl/kernel_rom_3x3_hex.v
rtl/conv5x5_rom_demo.v
rtl/relu.v

sim/tb_conv5x5_rom_demo.v

data/image_5x5.hex
data/kernel_3x3.hex