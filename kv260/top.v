/*
  Copyright (c) 2023, miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

`include "global_include.v"

module top
  (
`ifdef USE_UART
   output uart_txd,
   input  uart_rxd
`endif
   );

  localparam CORES = 96;
  localparam UART_CLK_HZ = 200000000;
  localparam UART_SCLK_HZ = 115200;

  wire    clk;
  wire    resetn;
  reg     reset;

  always @(posedge clk)
    begin
      reset <= ~resetn;
    end

`ifdef USE_VGA
  wire    clkv;
  wire    resetvn;
  reg     resetv;
  // VGA port
  wire [35:0] video_color;
  wire        video_de;
  wire        video_vsync;
  wire        video_hsync;
  wire        video_r;
  wire        video_g;
  wire        video_b;
  assign video_color = {{12{video_b}}, {12{video_r}}, {12{video_g}}};

  always @(posedge clkv)
    begin
      resetv <= ~resetvn;
    end
`endif

  mini16_soc
    #(
      .CORES (CORES),
      .UART_CLK_HZ (UART_CLK_HZ),
      .UART_SCLK_HZ (UART_SCLK_HZ)
      )
  mini16_soc_0
    (
`ifdef USE_VGA
     .clkv (clkv),
     .resetv (resetv),
     .vga_hs (video_hsync),
     .vga_vs (video_vsync),
     .vga_de (video_de),
     .vga_r (video_r),
     .vga_g (video_g),
     .vga_b (video_b),
`endif
`ifdef USE_UART
     .uart_rxd (uart_rxd),
     .uart_txd (uart_txd),
`endif
     .clk (clk),
     .reset (reset)
     );

  design_1 design_1_i
    (
`ifdef USE_VGA
     .dp_live_video_in_vsync_0 (~video_vsync),
     .dp_live_video_in_hsync_0 (~video_hsync),
     .dp_live_video_in_de_0 (video_de),
     .dp_live_video_in_pixel1_0 (video_color),
     .clk_out1_1 (clkv),
     .locked_1 (resetvn),
`endif
     .clk_out1_0 (clk),
     .locked_0 (resetn)
     );

endmodule
