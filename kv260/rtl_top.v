// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2023 miya All rights reserved.

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

  localparam CORES = 144;
  localparam UART_CLK_HZ = 200000000;
  localparam UART_SCLK_HZ = 115200;
  localparam DEPTH_P_I = 8;
  localparam DEPTH_P_D = 5;
  localparam DEPTH_M2S = 4;

  localparam VRAM_BPP = 3;
  localparam PE_FIFO_RAM_TYPE = "xi_distributed";

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
      .PE_FIFO_RAM_TYPE (PE_FIFO_RAM_TYPE),
      .UART_CLK_HZ (UART_CLK_HZ),
      .UART_SCLK_HZ (UART_SCLK_HZ),
      .DEPTH_P_I (DEPTH_P_I),
      .DEPTH_P_D (DEPTH_P_D),
      .DEPTH_M2S (DEPTH_M2S),
      .VRAM_RAM_TYPE ("auto")
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
