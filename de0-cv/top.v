/*
  Copyright (c) 2018-2019, miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

`define USE_UART
`define USE_VGA
`define RAM_TYPE_DISTRIBUTED "MLAB"

module top
  (
   input        CLOCK_50,
   input        RESET_N,
   output [9:0] LEDR,
`ifdef USE_VGA
   output       VGA_HS,
   output       VGA_VS,
   output [3:0] VGA_R,
   output [3:0] VGA_G,
   output [3:0] VGA_B,
`endif
   inout [35:0] GPIO_0,
   inout [35:0] GPIO_1
   );

  localparam CORES = 32;
  localparam UART_CLK_HZ = 140000000;
  localparam UART_SCLK_HZ = 115200;

  // unused GPIO
  assign GPIO_0[29:0] = 30'bz;
  assign GPIO_0[31] = 1'bz;
  assign GPIO_0[35:33] = 3'bz;
  assign GPIO_1[35:0] = 36'bz;

`ifndef USE_UART
  assign GPIO_0[30] = 1'bz;
  assign GPIO_0[32] = 1'bz;
`endif

  wire [15:0]   led;
  assign LEDR = led;

  // generate reset signal (push button 1)
  reg  reset;
  reg  reset1;
  reg  resetpll;
  reg  resetpll1;

  always @(posedge CLOCK_50)
    begin
      resetpll1 <= ~RESET_N;
      resetpll <= resetpll1;
    end

  always @(posedge clk)
    begin
      reset1 <= ~pll_locked;
      reset <= reset1;
    end

  // pll
  wire clk;
  wire pll_locked;

`ifdef USE_UART
  // uart
  wire uart_txd;
  wire uart_rxd;
  assign GPIO_0[30] = uart_txd;
  assign uart_rxd = GPIO_0[32];
  // input only
  assign GPIO_0[32] = 1'bz;
`endif

`ifdef USE_VGA
  wire clkv;
  reg  resetv;
  reg  resetv1;
  // truncate RGB data
  wire VGA_R_in;
  wire VGA_G_in;
  wire VGA_B_in;
  assign VGA_R = {4{VGA_R_in}};
  assign VGA_G = {4{VGA_G_in}};
  assign VGA_B = {4{VGA_B_in}};

  always @(posedge clkv)
    begin
      resetv1 <= ~pll_locked;
      resetv <= resetv1;
    end
`endif

  av_pll2_0002 av_pll2_0002_0
    (
     .refclk (CLOCK_50),
     .rst (resetpll),
     .outclk_0 (clk),
`ifdef USE_VGA
     .outclk_1 (clkv),
`endif
     .outclk_2 (),
     .locked (pll_locked)
     );

  mini16_soc
    #(
      .CORES (CORES),
      .UART_CLK_HZ (UART_CLK_HZ),
      .UART_SCLK_HZ (UART_SCLK_HZ)
      )
  mini16_soc_0
    (
     .clk (clk),
     .reset (reset),
`ifdef USE_UART
     .uart_rxd (uart_rxd),
     .uart_txd (uart_txd),
`endif
`ifdef USE_VGA
     .clkv (clkv),
     .resetv (resetv),
     .vga_hs (VGA_HS),
     .vga_vs (VGA_VS),
     .vga_r (VGA_R_in),
     .vga_g (VGA_G_in),
     .vga_b (VGA_B_in),
`endif
     .led (led)
     );

endmodule
