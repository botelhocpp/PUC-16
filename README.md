# PUC-16 💻
## A simple 16-bit processor made for teaching purposes, using VHDL and the Xilinx Zybo board.

## Datapath

The CPU has 16 simple 16-bit instructions that operate on 16-bit data. It also have several memory mapped I/O peripherals at disposal (LEDs, buttons, LCD, PS/2 keyboard, a pair of seven segment displays).

![image](https://github.com/botelhocpp/PUC-16/blob/main/Docs/Datapath.PNG)

# More about

This processor was made based in the specifications given in this [document](https://github.com/botelhocpp/PUC-16/blob/main/Docs/Specs.pdf). A compiler and assembler is provided by the professor who designed the CPU (I merely implemented it in VHDL). You can find the assembler and compiler, along with others useful informations on the processor in this [repository](https://github.com/wcaarls/puc16).
