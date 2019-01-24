/*
  Copyright (c) 2016, 2019 miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

module sprite
  #(
    parameter SPRITE_WIDTH_BITS = 6,
    parameter SPRITE_HEIGHT_BITS = 7,
    parameter BPP = 8
    )
  (
   input                       clk,
   input                       reset,

   output signed [32-1:0]      bitmap_length,
   input signed [32-1:0]       bitmap_address,
   input signed [BPP-1:0]      bitmap_din,
   output signed [BPP-1:0]     bitmap_dout,
   input                       bitmap_we,
   input                       bitmap_oe,

   input signed [32-1:0]       x,
   input signed [32-1:0]       y,
   input signed [32-1:0]       scale,

   input                       ext_clkv,
   input                       ext_resetv,
   output reg signed [BPP-1:0] ext_color,
   input signed [32-1:0]       ext_count_h,
   input signed [32-1:0]       ext_count_v
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
  reg signed [BPP-1:0]                    color_d6;
  reg signed [BPP-1:0]                    color_d7;

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
      ext_color <= vp_sprite_inside_d7 ? color_d7: 1'd0; // ext_color: delay 8
    end

  // bitmap
  dual_clk_ram
    #(
      .DATA_WIDTH (BPP),
      .ADDR_WIDTH (ADDR_BITS)
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

  shift_register_vector
    #(
      .WIDTH (OFFSET_BITS),
      .DEPTH (2)
      )
  shift_register_vector_x
    (
     .clk (ext_clkv),
     .data_in (x[OFFSET_BITS-1:0]),
     .data_out (x_sync)
     );

  shift_register_vector
    #(
      .WIDTH (OFFSET_BITS),
      .DEPTH (2)
      )
  shift_register_vector_y
    (
     .clk (ext_clkv),
     .data_in (y[OFFSET_BITS-1:0]),
     .data_out (y_sync)
     );

  shift_register_vector
    #(
      .WIDTH (SCALE_BITS_BITS),
      .DEPTH (2)
      )
  shift_register_vector_scale
    (
     .clk (ext_clkv),
     .data_in (scale[SCALE_BITS_BITS-1:0]),
     .data_out (scale_sync)
     );

  shift_register_vector
    #(
      .WIDTH (1),
      .DEPTH (5)
      )
  shift_register_vector_vp_sprite_inside_d7
    (
     .clk (ext_clkv),
     .data_in (vp_sprite_inside_d2),
     .data_out (vp_sprite_inside_d7)
     );

endmodule
