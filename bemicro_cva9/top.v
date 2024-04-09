/*
  Copyright (c) 2019, miya
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
   input        CLK_24MHZ,
`ifdef USE_UART
   output       LVDS_TX_O_N2,
   input        LVDS_TX_O_N1,
`endif
`ifdef USE_VGA
   output       GPIO2,
   output       GPIO4,
   output       GPIO6,
   output       GPIO8,
   output       GPIO_D,
   output       DIFF_TX_N9,
   output       LVDS_TX_O_P3,
   output       LVDS_TX_O_P0,
`endif
   input [1:0]  TACT,
   output [7:0] USER_LED
   );

  localparam CORES = 170;
  localparam UART_CLK_HZ = 100800000;
  localparam UART_SCLK_HZ = 115200;

  wire [15:0]   led;
  assign USER_LED = ~led;

  // generate reset signal (push button 1)
  reg  reset;
  reg  reset1;
  reg  resetpll;
  reg  resetpll1;

  always @(posedge CLK_24MHZ)
    begin
      resetpll1 <= ~TACT[0];
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
  assign LVDS_TX_O_N2 = uart_txd;
  assign uart_rxd = LVDS_TX_O_N1;
`endif

`ifdef USE_VGA
  wire   clkv;
  reg    resetv;
  reg    resetv1;
  // VGA port
  wire [2:0] VGA_COLOR_in;
  wire       VGA_HS;
  wire       VGA_VS;
  assign GPIO2 = VGA_COLOR_in[2];
  assign GPIO4 = VGA_COLOR_in[2];
  assign GPIO6 = VGA_COLOR_in[1];
  assign GPIO8 = VGA_COLOR_in[1];
  assign GPIO_D = VGA_COLOR_in[0];
  assign DIFF_TX_N9 = VGA_COLOR_in[0];
  assign LVDS_TX_O_P3 = VGA_HS;
  assign LVDS_TX_O_P0 = VGA_VS;
  always @(posedge clkv)
    begin
      resetv1 <= ~pll_locked;
      resetv <= resetv1;
    end
`endif

  av_pll2_0002 av_pll2_0002_0
    (
     .refclk (CLK_24MHZ),
     .rst (resetpll),
     .outclk_0 (clk),
`ifdef USE_VGA
     .outclk_1 (clkv),
`endif
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
     .vga_color (VGA_COLOR_in),
`endif
     .led (led)
     );

endmodule
