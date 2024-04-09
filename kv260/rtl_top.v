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

// ver.5

module rtl_top
  (
   input wire         clk,
`ifdef USE_VGA
   input wire         clkv,
   output wire        video_de,
   output wire        video_hsyncn,
   output wire        video_vsyncn,
   output wire [35:0] video_color,
`endif
`ifdef USE_UART
   input wire         uart_rxd,
   output wire        uart_txd,
`endif
   input wire         resetn
   );

  localparam CORES = 96;
  localparam UART_CLK_HZ = 200000000;
  localparam UART_SCLK_HZ = 115200;
  localparam WIDTH_D = 32;
  localparam DEPTH_I = 12;
  localparam DEPTH_D = 12;
  localparam VRAM_BPP = 3;

  localparam ZERO = 1'd0;
  localparam ONE = 1'd1;
  localparam TRUE = 1'b1;
  localparam FALSE = 1'b0;

`ifdef USE_VGA
  wire [VRAM_BPP-1:0] vga_color;
  wire                vga_hs;
  wire                vga_vs;
  wire [7:0]          vga_color_out;
  wire                resetv;
`endif

  // reset
  wire reset;
  wire resetp;

  assign resetp = ~resetn;

  shift_register
    #(
      .DELAY (3)
      )
  shift_register_reset
    (
     .clk (clk),
     .din (resetp),
     .dout (reset)
     );

`ifdef USE_VGA
  shift_register
    #(
      .DELAY (3)
      )
  shift_register_resetv
    (
     .clk (clkv),
     .din (resetp),
     .dout (resetv)
     );
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
     .vga_hs (vga_hs),
     .vga_vs (vga_vs),
     .vga_de (video_de),
     .vga_color (vga_color),
`endif
`ifdef USE_UART
     .uart_rxd (uart_rxd),
     .uart_txd (uart_txd),
`endif
     .clk (clk),
     .reset (reset)
     );

`ifdef USE_VGA
  assign video_hsyncn = ~vga_hs;
  assign video_vsyncn = ~vga_vs;
  assign video_color = {{12{vga_color[0]}}, {12{vga_color[2]}}, {12{vga_color[1]}}};
`endif

endmodule
