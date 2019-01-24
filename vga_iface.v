/*
  Copyright (c) 2015-2016, 2019, miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

module vga_iface
  #(
    parameter BPP = 8,
    parameter BPC = 8
    )
  (
   input                     clk,
   input                     reset,

   output                    vsync,
   output signed [32-1 : 0]  vcount,
   input                     ext_clkv,
   input                     ext_resetv,
   input signed [BPP-1 : 0]  ext_color,
   output                    ext_vga_hs,
   output                    ext_vga_vs,
   output                    ext_vga_de,
   output signed [BPC-1 : 0] ext_vga_r,
   output signed [BPC-1 : 0] ext_vga_g,
   output signed [BPC-1 : 0] ext_vga_b,
   output signed [32-1 : 0]  ext_count_h,
   output signed [32-1 : 0]  ext_count_v
   );

  localparam VGA_MAX_H = 800-1;
  localparam VGA_MAX_V = 525-1;
  localparam VGA_WIDTH = 640;
  localparam VGA_HEIGHT = 480;
  localparam VGA_SYNC_H_START = 656;
  localparam VGA_SYNC_V_START = 490;
  localparam VGA_SYNC_H_END = 752;
  localparam VGA_SYNC_V_END = 492;
  localparam LINE_BITS = 10;
  localparam PIXEL_DELAY = 8;

  reg [LINE_BITS-1:0] count_h;
  reg [LINE_BITS-1:0] count_v;
  wire                vga_hs;
  wire                vga_vs;
  wire                pixel_valid;
  wire                vga_hs_delay;
  wire                vga_vs_delay;
  wire                pixel_valid_delay;

  // H counter
  always @(posedge ext_clkv)
    begin
      if (ext_resetv == 1'b1)
        begin
          count_h <= 1'd0;
        end
      else
        begin
          if (count_h == VGA_MAX_H)
            begin
              count_h <= 1'd0;
            end
          else
            begin
              count_h <= count_h + 1'd1;
            end
        end
    end

  // V counter
  always @(posedge ext_clkv)
    begin
      if (ext_resetv == 1'b1)
        begin
          count_v <= 1'd0;
        end
      else
        begin
          if (count_h == VGA_MAX_H)
            begin
              if (count_v == VGA_MAX_V)
                begin
                  count_v <= 1'd0;
                end
              else
                begin
                  count_v <= count_v + 1'd1;
                end
            end
        end
    end

  // H sync
  assign vga_hs = ((count_h >= VGA_SYNC_H_START) && (count_h < VGA_SYNC_H_END)) ? 1'b0 : 1'b1;
  // V sync
  assign vga_vs = ((count_v >= VGA_SYNC_V_START) && (count_v < VGA_SYNC_V_END)) ? 1'b0 : 1'b1;
  // Pixel valid
  assign pixel_valid = ((count_h < VGA_WIDTH) && (count_v < VGA_HEIGHT)) ? 1'b1 : 1'b0;

  // ext out
  assign ext_vga_r = pixel_valid_delay ? ext_color[2] : 1'd0;
  assign ext_vga_g = pixel_valid_delay ? ext_color[1] : 1'd0;
  assign ext_vga_b = pixel_valid_delay ? ext_color[0] : 1'd0;
  assign ext_vga_hs = vga_hs_delay;
  assign ext_vga_vs = vga_vs_delay;
  assign ext_vga_de = pixel_valid_delay;
  assign ext_count_h = count_h;
  assign ext_count_v = count_v;


  shift_register_vector
    #(
      .WIDTH (1),
      .DEPTH (2)
      )
  shift_register_vector_vsync
    (
     .clk (clk),
     .data_in (ext_vga_vs),
     .data_out (vsync)
     );

  shift_register_vector
    #(
      .WIDTH (LINE_BITS),
      .DEPTH (2)
      )
  shift_register_vector_vcount
    (
     .clk (clk),
     .data_in (count_v),
     .data_out (vcount)
     );

  shift_register_vector
    #(
      .WIDTH (1),
      .DEPTH (PIXEL_DELAY)
      )
  shift_register_vector_vga_hs
    (
     .clk (ext_clkv),
     .data_in (vga_hs),
     .data_out (vga_hs_delay)
     );

  shift_register_vector
    #(
      .WIDTH (1),
      .DEPTH (PIXEL_DELAY)
      )
  shift_register_vector_vga_vs
    (
     .clk (ext_clkv),
     .data_in (vga_vs),
     .data_out (vga_vs_delay)
     );

  shift_register_vector
    #(
      .WIDTH (1),
      .DEPTH (PIXEL_DELAY)
      )
  shift_register_vector_pixel_valid
    (
     .clk (ext_clkv),
     .data_in (pixel_valid),
     .data_out (pixel_valid_delay)
     );

endmodule
