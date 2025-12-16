# Simple SDRAM Controller With UART
## Introduction
* Overview: Use Verilog and Design Compiler to design a simple SDRAM controller with UART interface including Initialize, Auto-Refresh, Read and Write functions from RTL to Synthesis.

  <img src="https://github.com/user-attachments/assets/d6bed02f-83f0-4be1-bbee-7be64dbefce1" width="100%" height="100%">

  * Spec. and external circuits:
    1. System clock: 200 MHz (5ns)
    2. SDRAM Model: Micron 32 Meg x 4 x16 SDRAM
        * Sdram clock: 133 MHz (7.5 ns)
        * Row address: 12-bit; Column address: 9-bit
    3. UART TX/RX:
        * 11-bit data packet w/o parity bit (1 start bit, 8-bit data frame, 2 stop bits)
        * Baud rate: 9600 bit/s
    4. R/W/CMD asynchronous FIFO:
        * Depth: 8-bit
    6. Command decoder: Decoding required commands & enable signals for SDRAM controller and wFIFO and cmdFIFO
    7. SDRAM_TOP: SDRAM controller with Initialize, Auto-Refresh, Read and Write function sub-modules
    8. Reset synchronizer


## Simulation Result
* UART RX:

  <img src="https://github.com/user-attachments/assets/f6133cf4-e84d-48bb-8d4c-148e3359dfdc" width="100%" height="100%">

* Command decoder:

  <img src="https://github.com/user-attachments/assets/f0897521-b97c-4827-a29a-b613ebd0795e" width="100%" height="100%">

* CMD/W FIFO:

  <img src="https://github.com/user-attachments/assets/cd06d1e6-d25b-47a3-8850-0e82ff809902" width="80%" height="80%">
  <br><br>
  <img src="https://github.com/user-attachments/assets/37a98163-82d0-4193-9a4a-688b024a63d8" width="80%" height="80%">

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
    <br><br>
    <img src="https://github.com/user-attachments/assets/7fd6f4d4-dde1-43a5-a858-8e9189aed2e8" width="90%" height="90%">

* SDRAM Controller Read w/o Auto-Precharge:
  * Timing diagram:

    <img src="https://github.com/user-attachments/assets/f10a3e93-d1c9-4eb7-bc6d-1b7185c4c3d7" width="70%" height="70%">

  * Simulation result:

    <img src="https://github.com/user-attachments/assets/42b390c0-c2ce-43cb-a923-ea5a49ff046d" width="80%" height="80%">
    <br><br>
    <img src="https://github.com/user-attachments/assets/eafe4d6b-4ed4-4a1d-af9d-9181f500961d" width=90%" height="90%">

* R FIFO:

  <img src="https://github.com/user-attachments/assets/f8b1c26b-2818-4357-b5d6-8cb7f70f7d19" width="80%" height="80%">

* UART TX:

  <img src="https://github.com/user-attachments/assets/9c9fe9d3-525e-48f6-9dac-b3bb7d92774f" width="70%" height="70%">

* Complete SDRAM Controller with UART interface:

  <img src="https://github.com/user-attachments/assets/756a06f0-2cb4-4f5b-b6e0-acbc8701766c" width="70%" height="70%">
  <br /><br />
  <img src="https://github.com/user-attachments/assets/96902f5b-508d-4af7-a93e-24eb7d573a8f" width="100%" height="100%">

* Synthesis and gate-level simulation:

  <img src="https://github.com/user-attachments/assets/fc199b8a-57ef-4070-b0b9-0a4552854134" width="30%" height="30%">
  <br><br>
  <img src="https://github.com/user-attachments/assets/23cde526-1370-4f67-96d0-a3ab9754c75c" width="100%" height="100%">



## Reference
1. [基于FPGA的SDRAM控制器设计](https://www.bilibili.com/video/BV16t411H7iw/?spm_id_from=333.788.videopod.episodes&vd_source=30e4f5546b550834d2028229f591b817&p=8)
2. SDRAM 128Mb, x4, x8, x16 datasheet


