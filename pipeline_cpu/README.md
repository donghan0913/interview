# 32-bit 5-Staged Pipeline MIPS CPU with Multiplier
## Introduction
* Overview : Use Verilog and Design Compiler to design a simple 5-staged pipeline 32-bit Single-Cycle MIPS CPU from RTL to Synthesis. After that, adding multiplier and clock gating into CPU design
  * Same supported functions & test data as the single-cycle CPU project
  * Solving data hazard & control hazard

    <img src="https://github.com/user-attachments/assets/030c4893-e10a-481a-9ee4-19631d505aa1" width="30%" height="30%">


* Block diagram
  * Complete CPU:

    <img src="https://github.com/user-attachments/assets/ccd9c6e1-3b66-4fb2-991a-9fc2fdff4736" width="100%" height="100%">

  * Multiplier:

    <img src="https://github.com/user-attachments/assets/556511f8-91b7-43ea-a399-68bc9d17d454" width="55%" height="55%">


* Test data

  <img src="https://github.com/user-attachments/assets/31345cb5-49a0-48eb-ae9e-db0df7084e33" width="40%" height="40%">
  <img src="https://github.com/user-attachments/assets/2905f874-7b9e-4e09-a21b-433483f6d3af" width="35%" height="35%">


* Makefile guide :
  * `rsim` : RTL simulation for pipeline CPU with single stage multiplier
  * `rsim_multpip` : RTL simulation for pipeline CPU with two stage multiplier
  * `rsim_lp` : RTL simulation for pipeline CPU with two stage multiplier and data gating
  * `dc` : Synthesis for pipeline CPU with single stage multiplier
  * `dc_multpip` : Synthesis for pipeline CPU with two stage multiplier
  * `dc_lp` : Synthesis for pipeline CPU with two stage multiplier and data gating and clock gating
  * `dft_lp` , `atpg` : Unfinished, ignored


## Simulation Result
* Waveform of pipeline CPU w/o multiplier:

  <img src="https://github.com/user-attachments/assets/7084f57c-f644-4c41-b22b-22f8557938c7" width="100%" height="100%">

* Waveform of pipeline CPU w/ 2-stage multiplier:

  <img src="https://github.com/user-attachments/assets/284a9cc7-daf9-4054-82d2-a1e5535105d3" width="100%" height="100%">

* Waveform of pipeline CPU after data gating:

  <img src="https://github.com/user-attachments/assets/ebda27a3-f8dd-47fa-8db8-f8f60791acea" width="100%" height="100%">


## Synthesis result
* Pipeline CPU w/ multiplier synthesis report:

  <img src="https://github.com/user-attachments/assets/a3c69bf4-0d94-4527-9686-7790aacede10" width="50%" height="50%">

* Pipeline CPU after clock gating:

  <img src="https://github.com/user-attachments/assets/72b851a5-ff2c-4e17-803a-5f0fbd110a1e" width="40%" height="40%">
  &nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/d1fa90f7-1de4-41c9-8553-19fcdd232be6" width="50%" height="50%">



