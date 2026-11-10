Pipelined MIPS Processor (VHDL)

This project is a simplified 32-bit MIPS processor implemented in VHDL. It uses a five-stage pipeline to execute instructions, allowing different stages of multiple instructions to be processed at the same time.
The main goal was to understand how pipelining works and how the different components of a processor communicate with each other

 How It Work
The processor is divided into five stages:

- Instruction Fetch (IF) – fetches instructions from memory.
- Instruction Decode (ID) – decodes instructions and reads the required registers.
- Execute (EX) – performs arithmetic and logical operations using the ALU.
- Memory (MEM) – handles reading and writing data.
- Write Back (WB) – writes the results back into the registers.

Pipeline registers are used between these stages to pass data and control signals from one stage to the next.

 Features

- 32-bit MIPS-like architecture
- Five-stage instruction pipeline
- Arithmetic and logical operations
- Register file and ALU
- Memory read and write operations
- Branch and jump instructions
- Control unit for instruction execution
- 7-segment display for showing values

The instruction memory also contains a program designed to count the number of set bits (bits equal to 1) in a binary number.

 Technologies Used

- VHDL
- Xilinx Vivado
- MIPS Architecture
- Digital Logic Design


 About the Project

I worked on this project to better understand computer architecture and the way processors execute instructions.
It helped me learn how pipelining works, how instructions move between different stages and how the control unit, ALU, registers and memory work together.
Compared to a single-cycle processor, this design was more challenging because of the additional pipeline registers and the need to manage data between stages.
