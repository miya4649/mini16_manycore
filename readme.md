# Mini16-ManyCore

FPGA many-core processor implementation written in Verilog HDL

Up to 501-core processors are implemented in a single FPGA


https://github.com/user-attachments/assets/b918324b-8c1b-45cb-a640-6a24a39ccb09


## Features:

- 32bit data/register width processor core version

33 cores implemented, Fmax: 140 MHz / Terasic DE0-CV

171 cores implemented, Fmax: 100 MHz / BeMicro-CVA9

145 cores implemented, Fmax: 200 MHz / Kria KV260

with UART, VGA interface

- 16bit data/register width processor core version

65 cores implemented, Fmax: 140 MHz / Terasic DE0-CV

501 cores implemented, Fmax: 100 MHz / BeMicro-CVA9

DE0-CV and BeMicro-CVA9 projects are included in the mini16cpu_core branch.

## Documents and Latest Version (Japanese):

http://cellspe.matrix.jp/zerofpga/mini16_manycore.html

## Demonstration Video:

An example of parallel processing of the Mandelbrot set

[![mini16 manycore mandelbrot demo](https://img.youtube.com/vi/qd9qpuM_cWg/0.jpg)](https://www.youtube.com/watch?v=qd9qpuM_cWg)
