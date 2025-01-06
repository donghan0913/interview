# Accelerated Floating-Point Multiply & Addition Designs Applied to Machine Learning
## Introduction
* Overview: Use Verilog and Design Compiler to design a Machine Learning Perceptron algorithm Inference part model with IEEE 754 binary16 format floating-point calculation from RTL to Synthesis.

  <img src="https://github.com/user-attachments/assets/1225df8a-e176-4904-ac70-50420fd7bd0a" width="40%" height="40%">
  
  * Use Iris dataset 100 data of target label 0 & 1. Weights already done by using 80 data training in C language, do inference part with 20 data in Verilog.

* Try different techniques on floating-point net computation improvement
  * Different pipeline structure:
    1. 2-staged pipeline
    2. 4-stage pipeline
  * Different floating-point fast arithmetic unit:
    1. Fused-Multiply-Add Unit
    2. Leading-Zero Anticipator for Normalization


## Details
* FSM:

  <img src="https://github.com/user-attachments/assets/480ff6ca-8d5e-4fe2-995e-90ba92c71565" width="60%" height="60%">

  * For different pipeline structures:


* FMA Unit for single-cycle net computation structure
  
  <img src="https://github.com/user-attachments/assets/0311fa17-d23b-4bad-addd-7b864d3dfa78" width="30%" height="30%">

* Floating-Point multiplier:

  <img src="https://github.com/user-attachments/assets/dabebaa5-197f-4b3a-8e95-9804c6d5cd76" width="30%" height="30%">

* Floating-Point adder with leading-zero detector[1]:

  <img src="https://github.com/user-attachments/assets/2edb65c4-b393-4bda-9616-837c11a9c356" width="40%" height="40%">

* Floating-Point adder with leading-zero anticipator[2]:

  <img src="https://github.com/user-attachments/assets/2dbd7f2d-e486-426b-b04b-b385dfffd539" width="40%" height="40%">




## Result
* RTL simulation result for single cycle steucture:

  <img src="https://github.com/user-attachments/assets/df6f93c5-28a0-47a3-8b2f-a7521548c51b" width="100%" height="100%">

  * `ya` is actual label(output) calculated in design, `yd` is target label(output) of dataset.
  * `check_y` equals to 0 indicates (ya == yd) for a inference data computation

* Single-cycle vs. 2-stage pipeline: Including different floating-point fast arithmetic unit
  
  <img src="https://github.com/user-attachments/assets/d8c16f95-7557-4b6a-bed8-d38dab6471e4" width="75%" height="75%">

* 2-stage pipeline vs. 4-stage pipeline:

  <img src="https://github.com/user-attachments/assets/b41f7da6-32bf-4343-97dd-8ef9781fb81a" width="35%" height="35%">

## Reference
[1] Deb, S., & Chaudhury, S. (2012, November). High-speed comparator architectures for fast binary comparison. In 2012 Third International Conference on Emerging Applications of Information Technology (pp. 454-457). IEEE.

[2] Bruguera, J. D., & Lang, T. (1999). Leading-one prediction with concurrent position correction. IEEE Transactions on Computers, 48(10), 1083-1097.



