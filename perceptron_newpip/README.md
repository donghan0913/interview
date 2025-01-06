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





## Result
* RTL simulation result for single cycle steucture:

  <img src="https://github.com/user-attachments/assets/df6f93c5-28a0-47a3-8b2f-a7521548c51b" width="100%" height="100%">

* Single-cycle vs. 2-stage pipeline: Including different floating-point fast arithmetic unit
  
  <img src="https://github.com/user-attachments/assets/d8c16f95-7557-4b6a-bed8-d38dab6471e4" width="75%" height="75%">

* 2-stage pipeline vs. 4-stage pipeline:

  <img src="https://github.com/user-attachments/assets/b41f7da6-32bf-4343-97dd-8ef9781fb81a" width="35%" height="35%">


