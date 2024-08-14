// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2016 miya All rights reserved.

// ver. 2024/04/21

module sprite
  #(
    parameter SPRITE_WIDTH_BITS = 6,
    parameter SPRITE_HEIGHT_BITS = 7,
    parameter BPP = 8,
    parameter RAM_TYPE = "auto"
    )
  (
   input wire                 clk,
   input wire                 reset,

   output wire [32-1:0]       bitmap_length,
   input wire [32-1:0]        bitmap_address,
   input wire [BPP-1:0]       bitmap_din,
   output wire [BPP-1:0]      bitmap_dout,
   input wire                 bitmap_we,
   input wire                 bitmap_oe,

   input wire signed [32-1:0] x,
   input wire signed [32-1:0] y,
   input wire signed [32-1:0] scale,

   input wire                 ext_clkv,
   input wire                 ext_resetv,
   output reg [BPP-1:0]       ext_color,
   input wire signed [32-1:0] ext_count_h,
   input wire signed [32-1:0] ext_count_v
   );

  localparam OFFSET_BITS = 16;
  localparam ADDR_BITS = (SPRITE_WIDTH_BITS + SPRITE_HEIGHT_BITS);
  localparam SCALE_BITS_BITS = 4;
  localparam SCALE_BITS = (1 << SCALE_BITS_BITS);
  localparam SCALE_DIV_BITS = 8;
  localparam SPRITE_WIDTH = (1 << SPRITE_WIDTH_BITS);
  localparam SPRITE_HEIGHT = (1 << SPRITE_HEIGHT_BITS);

  // return const value
  assign bitmap_length = 1 << ADDR_BITS;
  assign bitmap_dout = 1'd0;

  // inside the sprite
  wire                       vp_sprite_inside_d2;
  wire                       vp_sprite_inside_d7;
  assign vp_sprite_inside_d2 = ((dx1_d2 >= 0) &&
                                (dx1_d2 < SPRITE_WIDTH) &&
                                (dy1_d2 >= 0) &&
                                (dy1_d2 < SPRITE_HEIGHT));

  // sprite logic
  reg [BPP-1:0]                           color;
  reg signed [OFFSET_BITS+SCALE_BITS-1:0] dx0_d1;
  reg signed [OFFSET_BITS+SCALE_BITS-1:0] dy0_d1;
  reg signed [OFFSET_BITS+SCALE_BITS-1:0] dx1_d2;
  reg signed [OFFSET_BITS+SCALE_BITS-1:0] dy1_d2;
  reg [ADDR_BITS-1:0]                     bitmap_raddr_d3;
  wire [BPP-1:0]                          bitmap_color_d5;
  wire signed [OFFSET_BITS-1:0]           x_sync;
  wire signed [OFFSET_BITS-1:0]           y_sync;
  wire [SCALE_BITS_BITS-1:0]              scale_sync;
  reg [SCALE_BITS_BITS-1:0]               scale_sync_d1;
  reg [BPP-1:0]                           color_d6;
  reg [BPP-1:0]                           color_d7;
  reg [BPP-1:0]                           color_d8;

  always @(posedge ext_clkv)
    begin
      dx0_d1 <= ext_count_h - x_sync;
      dy0_d1 <= ext_count_v - y_sync;
      scale_sync_d1 <= scale_sync;
      dx1_d2 <= (dx0_d1 << scale_sync_d1) >> SCALE_DIV_BITS;
      dy1_d2 <= (dy0_d1 << scale_sync_d1) >> SCALE_DIV_BITS;
      bitmap_raddr_d3 <= {dy1_d2[SPRITE_HEIGHT_BITS-1:0], {SPRITE_WIDTH_BITS{1'b0}}} + dx1_d2[SPRITE_WIDTH_BITS-1:0];
      color_d6 <= bitmap_color_d5;
      color_d7 <= color_d6;
      color_d8 <= vp_sprite_inside_d7 ? color_d7: 1'd0;
      ext_color <= color_d8; // ext_color: delay 9
    end

  // bitmap
  dual_clk_ram
    #(
      .DATA_WIDTH (BPP),
      .ADDR_WIDTH (ADDR_BITS),
      .RAM_TYPE (RAM_TYPE)
      )
  dual_clk_ram_0
    (
     .data_in (bitmap_din),
     .read_addr (bitmap_raddr_d3),
     .write_addr (bitmap_address[SPRITE_WIDTH_BITS+SPRITE_HEIGHT_BITS-1:0]),
     .we (bitmap_we),
     .read_clock (ext_clkv),
     .write_clock (clk),
     .data_out (bitmap_color_d5)
     );

  cdc_synchronizer
    #(
      .DATA_WIDTH (OFFSET_BITS)
      )
  cdc_synchronizer_x
    (
     .clk (ext_clkv),
     .data_in (x[OFFSET_BITS-1:0]),
     .data_out (x_sync)
     );

  cdc_synchronizer
    #(
      .DATA_WIDTH (OFFSET_BITS)
      )
  cdc_synchronizer_y
    (
     .clk (ext_clkv),
     .data_in (y[OFFSET_BITS-1:0]),
     .data_out (y_sync)
     );

  cdc_synchronizer
    #(
      .DATA_WIDTH (SCALE_BITS_BITS)
      )
  cdc_synchronizer_scale
    (
     .clk (ext_clkv),
     .data_in (scale[SCALE_BITS_BITS-1:0]),
     .data_out (scale_sync)
     );

  shift_register
    #(
      .DELAY (5)
      )
  shift_register_vp_sprite_inside_d7
    (
     .clk (ext_clkv),
     .din (vp_sprite_inside_d2),
     .dout (vp_sprite_inside_d7)
     );

endmodule
