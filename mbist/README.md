# Memory BIST
## Introduction
* Overview: Use Verilog and Design Compiler to design a Memory BIST controller for Checkerboard, March X and March C- algorithm specifically. Then design low power LFSR to replace binary counter for Address Generator. From RTL to Synthesis.

  <img src="https://github.com/user-attachments/assets/05651d2b-60d0-4c7e-9475-b3797b23a083" width="40%" height="40%">

* Fault models:
  * Stuck-at-0 fault:
    * <1/0> at address 6’b000_100
  * Idempotent coupling fault: All four types
    * <↑, 1/0> , <↓, 1/0> : Aggressor cell at 6’b010_001 ; Victim cell at 6’b010_010
    * <↑, 0/1> , <↓, 0/1> : Aggressor cell at 6’b000_110 ; Victim cell at 6’b000_111

* Low power LFSR design[1]:

  <img src="https://github.com/user-attachments/assets/526f4f79-db71-4802-9b8a-cb14c96a679d" width="100%" height="100%">


## Simulation Result
* Checkerboard:

  <img src="https://github.com/user-attachments/assets/4cb327b0-b13a-42c4-b227-0b2716e165c4" width="100%" height="100%">
  <img src="https://github.com/user-attachments/assets/e78fbc29-6f58-4c85-ab58-a03b4c83e0c2" width="30%" height="30%">

* March X:

  <img src="https://github.com/user-attachments/assets/e5e81c6b-9f54-4e47-8f96-5ef0d89942de" width="100%" height="100%">
  <img src="https://github.com/user-attachments/assets/12a80827-37f5-47da-a6eb-6236a9f37a3a" width="30%" height="30%">

* March C-:

  <img src="https://github.com/user-attachments/assets/5fb9de69-e599-4397-bb92-b91f19608ef5" width="100%" height="100%">
  <img src="https://github.com/user-attachments/assets/44375036-35a0-475b-9c1e-3d0d75cec0ce" width="30%" height="30%">

* Low power LFSR address generator MBIST:
  * Address generation:

    <img src="https://github.com/user-attachments/assets/ffff90d9-7336-47c6-a34f-3a8107d271f4" width="100%" height="100%">

  
  * Low power March X MBIST:

    <img src="https://github.com/user-attachments/assets/cfe323a1-d037-4ffc-9b92-a34f3656610c" width="100%" height="100%">


  * Low power March C- MBIST:

    <img src="https://github.com/user-attachments/assets/5a8c65f3-5dc3-43a1-9c89-b2c9894d8f2a" width="100%" height="100%">

* Result comparison:

  <img src="https://github.com/user-attachments/assets/0770924b-acca-4849-a172-cf6e23d832fe" width="50%" height="50%">

  <img src="https://github.com/user-attachments/assets/bd682566-0c50-4721-990c-f7dbd2bbf8cf" width="60%" height="60%">


## Reference
[1] Krishna, K. M., & Sailaja, M. (2014). Low power memory built in self test address generator using clock controlled linear feedback shift registers. Journal of Electronic Testing, 30, 77-85.


