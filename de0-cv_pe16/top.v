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

  localparam TRUE = 1'b1;
  localparam FALSE = 1'b0;
  localparam CORES = 64;
  localparam WIDTH_P_D = 16;
  localparam DEPTH_P_I = 9;
  localparam DEPTH_M2S = 4;
  localparam DEPTH_FIFO = 3;
  localparam VRAM_WIDTH_BITS = 6;
  localparam VRAM_HEIGHT_BITS = 7;
  localparam PE_REGFILE_RAM_TYPE = "al_mlab";
  localparam PE_FIFO_RAM_TYPE = "al_mlab";
  localparam PE_M2S_RAM_TYPE = "al_mlab";
  localparam PE_DEPTH_REG = 4;
  localparam PE_ENABLE_MVIL = TRUE;
  localparam PE_ENABLE_MUL = FALSE;
  localparam PE_ENABLE_MULTI_BIT_SHIFT = FALSE;
  localparam PE_ENABLE_MVC = FALSE;
  localparam PE_ENABLE_WA = FALSE;
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
  wire [2:0] VGA_COLOR_in;
  assign VGA_R = {4{VGA_COLOR_in[2]}};
  assign VGA_G = {4{VGA_COLOR_in[1]}};
  assign VGA_B = {4{VGA_COLOR_in[0]}};

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
      .UART_SCLK_HZ (UART_SCLK_HZ),
      .WIDTH_P_D (WIDTH_P_D),
      .DEPTH_P_I (DEPTH_P_I),
      .DEPTH_M2S (DEPTH_M2S),
      .DEPTH_FIFO (DEPTH_FIFO),
      .VRAM_WIDTH_BITS (VRAM_WIDTH_BITS),
      .VRAM_HEIGHT_BITS (VRAM_HEIGHT_BITS),
      .PE_REGFILE_RAM_TYPE (PE_REGFILE_RAM_TYPE),
      .PE_FIFO_RAM_TYPE (PE_FIFO_RAM_TYPE),
      .PE_M2S_RAM_TYPE (PE_M2S_RAM_TYPE),
      .PE_DEPTH_REG (PE_DEPTH_REG),
      .PE_ENABLE_MVIL (PE_ENABLE_MVIL),
      .PE_ENABLE_MUL (PE_ENABLE_MUL),
      .PE_ENABLE_MULTI_BIT_SHIFT (PE_ENABLE_MULTI_BIT_SHIFT),
      .PE_ENABLE_MVC (PE_ENABLE_MVC),
      .PE_ENABLE_WA (PE_ENABLE_WA)
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
     .vga_color (VGA_COLOR_in),
`endif
     .led (led)
     );

endmodule
