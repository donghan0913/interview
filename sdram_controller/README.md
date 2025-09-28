# Simple SDRAM Controller With UART
## Introduction
* Overview: Use Verilog and Design Compiler to design a simple SDRAM controller with UART interface including Initialize, Auto-Refresh, Read and Write functions from RTL to Synthesis.

  <img src="https://github.com/user-attachments/assets/b82b129f-8d2f-458c-b5b3-9959a897dedb" width="100%" height="100%">

  * Modules:
    1. SDRAM Model: Micron 32 Meg x 4 x16 SDRAM
        * Clock: 133 MHz (7.5 ns)
        * Row address: 12-bit; Column address: 9-bit
    2. UART TX/RX:
        * 11-bit data packet (1 start bit, 8-bit data frame, 2 stop bits)
        * Baud rate: 9600 bit/s
    3. Synchronous FIFO: For wFIFO & rFIFO
        * Width: 16-bit
        * Depth: 8-bit
    4. Command decoder: Decoding required commands & enable signals for SDRAM controller and wFIFO
    5. SDRAM_TOP: SDRAM controller with Initialize, Auto-Refresh, Read and Write function sub-modules


## Simulation Result
* UART TX/RX:

  <img src="https://github.com/user-attachments/assets/67daecf7-8ec4-4c11-8d6f-334035caad35" width="100%" height="100%">

* Command decoder:

  <img src="https://github.com/user-attachments/assets/80f9d69a-bc16-4584-a243-2769b5ff9308" width="50%" height="50%">

* Synchronous FIFO:

  <img src="https://github.com/user-attachments/assets/d27f359a-d0db-45a6-bad9-37ef46669d28" width="70%" height="70%">

* SDRAM Controller Initialize:
  * Timing diagram:

    <img src="https://github.com/user-attachments/assets/db2b1b46-7351-4ca8-9f64-bfbd4e338ffe" width="70%" height="70%">

  * Simulation result:

    <img src="https://github.com/user-attachments/assets/eca8fb4b-e8b5-4299-8fe1-e73ae8c044d4" width="45%" height="45%"><br /><br /><img src="https://github.com/user-attachments/assets/1db3f249-82ac-4f29-a2c6-19219be2c8f6" width="100%" height="100%">

* SDRAM Controller Auto-Refresh:
  * Timing diagram:

    <img src="https://github.com/user-attachments/assets/d95c07ee-4d4b-4f9f-a892-17cda9f6e847" width="60%" height="60%">

  * Simulation result:

    <img src="https://github.com/user-attachments/assets/3893c9bd-44a1-4e84-a572-b48a676c77a4" width="100%" height="100%">

    * Auto-Refresh every 15𝜇s (0x7d0 cycles)

* SDRAM Controller Write w/o Auto-Precharge:
  * Timing diagram:

    <img src="https://github.com/user-attachments/assets/f7d40897-85c1-4822-abda-177fabe960d6" width="70%" height="70%">


  * Simulation result:

    <img src="https://github.com/user-attachments/assets/79ec2d41-9f7c-41f5-949b-e7d9ee7eda22" width="80%" height="80%">

* SDRAM Controller Read w/o Auto-Precharge:
  * Timing diagram:

    <img src="https://github.com/user-attachments/assets/f10a3e93-d1c9-4eb7-bc6d-1b7185c4c3d7" width="70%" height="70%">

  * Simulation result:

    <img src="https://github.com/user-attachments/assets/42b390c0-c2ce-43cb-a923-ea5a49ff046d" width="80%" height="80%">

* Complete SDRAM Controller with UART interface:

  <img src="https://github.com/user-attachments/assets/756a06f0-2cb4-4f5b-b6e0-acbc8701766c" width="70%" height="70%"><br /><br /><img src="https://github.com/user-attachments/assets/4a615f04-1447-45e2-a81b-93dc49363144" width="100%" height="100%">

* Synthesis and gate-level simulation:

  <img src="https://github.com/user-attachments/assets/d85274e4-12a7-467f-be9b-5267a235587c" width="100%" height="100%">


## Reference
1. [基于FPGA的SDRAM控制器设计](https://www.bilibili.com/video/BV16t411H7iw/?spm_id_from=333.788.videopod.episodes&vd_source=30e4f5546b550834d2028229f591b817&p=8)
2. SDRAM 128Mb, x4, x8, x16 datasheet


