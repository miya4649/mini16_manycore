// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2015 miya All rights reserved.

// ver. 2024/03/31

module vga_iface
  #(
    parameter VGA_MAX_H = 1650-1,
    parameter VGA_MAX_V = 750-1,
    parameter VGA_WIDTH = 1280,
    parameter VGA_HEIGHT = 720,
    parameter VGA_SYNC_H_START = 1390,
    parameter VGA_SYNC_V_START = 725,
    parameter VGA_SYNC_H_END = 1430,
    parameter VGA_SYNC_V_END = 730,
    parameter CLIP_ENABLE = 0,
    parameter CLIP_H_S = 0,
    parameter CLIP_H_E = 1280,
    parameter CLIP_V_S = 0,
    parameter CLIP_V_E = 720,
    parameter PIXEL_DELAY = 2,
    parameter BPP = 8
    )
  (
   input wire            clk,
   input wire            reset,
   output wire           vsync,
   output wire [31:0]    vcount,
   input wire            ext_clkv,
   input wire            ext_resetv,
   input wire [BPP-1:0]  ext_color_in,
   output wire           ext_vga_hs,
   output wire           ext_vga_vs,
   output wire           ext_vga_de,
   output wire [BPP-1:0] ext_vga_color_out,
   output wire [31:0]    ext_count_h,
   output wire [31:0]    ext_count_v
   );

  localparam H_BITS = $clog2(VGA_MAX_H + 2);
  localparam V_BITS = $clog2(VGA_MAX_V + 2);

  reg [H_BITS-1:0] count_h;
  reg [V_BITS-1:0] count_v;
  wire             vga_hs;
  wire             vga_vs;
  wire             pixel_valid;
  wire             vga_hs_delay;
  wire             vga_vs_delay;
  wire             pixel_valid_delay;
  wire             pixel_en;

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

  // clip
  generate
    if (CLIP_ENABLE == 1)
      begin: clip_block
        wire clip;
        wire clip_delay;
        assign clip = ((count_v >= CLIP_V_S) && (count_v < CLIP_V_E) && (count_h >= CLIP_H_S) && (count_h < CLIP_H_E)) ? 1'b1 : 1'b0;
        assign pixel_en = pixel_valid_delay & clip_delay;

        shift_register
          #(
            .DELAY (PIXEL_DELAY)
            )
        shift_register_pixel_valid
          (
           .clk (ext_clkv),
           .din (clip),
           .dout (clip_delay)
           );
      end
    else
      begin: clip_block
        assign pixel_en = pixel_valid_delay;
      end
  endgenerate

  // ext out
  assign ext_vga_color_out = pixel_en ? ext_color_in : {BPP{1'b0}};
  assign ext_vga_hs = vga_hs_delay;
  assign ext_vga_vs = vga_vs_delay;
  assign ext_vga_de = pixel_valid_delay;
  assign ext_count_h = count_h;
  assign ext_count_v = count_v;

  cdc_synchronizer
    #(
      .DATA_WIDTH (V_BITS)
      )
  cdc_synchronizer_vcount
    (
     .data_in (count_v),
     .data_out (vcount),
     .clk (clk)
     );

  shift_register
    #(
      .DELAY (2)
      )
  shift_register_vsync
    (
     .clk (clk),
     .din (ext_vga_vs),
     .dout (vsync)
     );

  shift_register
    #(
      .DELAY (PIXEL_DELAY)
      )
  shift_register_vga_hs
    (
     .clk (ext_clkv),
     .din (vga_hs),
     .dout (vga_hs_delay)
     );

  shift_register
    #(
      .DELAY (PIXEL_DELAY)
      )
  shift_register_vga_vs
    (
     .clk (ext_clkv),
     .din (vga_vs),
     .dout (vga_vs_delay)
     );

  shift_register
    #(
      .DELAY (PIXEL_DELAY)
      )
  shift_register_pixel_valid
    (
     .clk (ext_clkv),
     .din (pixel_valid),
     .dout (pixel_valid_delay)
     );

endmodule
