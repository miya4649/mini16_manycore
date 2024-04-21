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

module mini16_soc
  #(
    parameter CORES = 32,
    parameter UART_CLK_HZ = 50000000,
    parameter UART_SCLK_HZ = 115200,
    parameter WIDTH_M_D = 32,
    parameter WIDTH_P_D = 32,
    parameter DEPTH_M_I = 11,
    parameter DEPTH_M_D = 11,
    parameter DEPTH_P_I = 10,
    parameter DEPTH_P_D = 8,
    parameter DEPTH_M2S = 8,
    parameter DEPTH_FIFO = 4,
    parameter DEPTH_S2M = 9,
    parameter DEPTH_U2M = 11,
    parameter VRAM_BPP = 3,
    parameter VRAM_WIDTH_BITS = 8,
    parameter VRAM_HEIGHT_BITS = 9,
    parameter MASTER_REGFILE_RAM_TYPE = "auto",
    parameter PE_REGFILE_RAM_TYPE = "auto",
    parameter PE_FIFO_RAM_TYPE = "auto",
    parameter PE_M2S_RAM_TYPE = "auto",
    parameter VRAM_RAM_TYPE = "auto",
    parameter PE_DEPTH_REG = 5,
    parameter PE_ENABLE_MVIL = 1'b1,
    parameter PE_ENABLE_MUL = 1'b1,
    parameter PE_ENABLE_MULTI_BIT_SHIFT = 1'b1,
    parameter PE_ENABLE_MVC = 1'b1,
    parameter PE_ENABLE_WA = 1'b1
    )
  (
   input                 clk,
   input                 reset,
`ifdef USE_UART
   input                 uart_rxd,
   output                uart_txd,
`endif
`ifdef USE_VGA
   input                 clkv,
   input                 resetv,
   output                vga_hs,
   output                vga_vs,
   output                vga_de,
   output [VRAM_BPP-1:0] vga_color,
`endif
   output [15:0]         led
   );

  // instruction width
  localparam WIDTH_I = 16;
  // register file depth
  localparam DEPTH_REG = 5;
  // I/O register depth
  localparam DEPTH_IO_REG = 5;
  localparam DEPTH_VRAM = (VRAM_WIDTH_BITS + VRAM_HEIGHT_BITS);
  // UART I/O addr depth
  localparam DEPTH_B_U = max(DEPTH_M_I, DEPTH_U2M);
  // UART I/O Virtual memory depth
  localparam DEPTH_V_U = (DEPTH_B_U + 2);
  localparam CORE_BITS = $clog2(CORES + 6);
  localparam DEPTH_B_F = max(DEPTH_VRAM, DEPTH_S2M);
  localparam DEPTH_B_M2S = max(DEPTH_P_I, DEPTH_M2S);
  localparam DEPTH_V_M2S = (DEPTH_B_M2S + 1);
  // Master write addr depth
  localparam DEPTH_B_M_W = max(DEPTH_V_M2S, max(DEPTH_M_D, DEPTH_IO_REG));
  // Master read addr depth
  localparam DEPTH_B_M_R = max(DEPTH_M_D, max(DEPTH_IO_REG, max(DEPTH_U2M, DEPTH_S2M)));
  // Master virtual memory write depth
  localparam DEPTH_V_M_W = (DEPTH_B_M_W + CORE_BITS);
  // Master virtual memory read depth
  localparam DEPTH_V_M_R = (DEPTH_B_M_R + 2);
  localparam DEPTH_V_F = (DEPTH_B_F + 1);
  localparam DEPTH_V_M = max(DEPTH_V_M_W, DEPTH_V_M_R);
  localparam DEPTH_B_S_R = max(DEPTH_P_D, DEPTH_M2S);
  localparam DEPTH_V_S_R = (DEPTH_B_S_R + 2);
  localparam DEPTH_B_S_W = max(DEPTH_V_F, DEPTH_P_D);
  localparam DEPTH_V_S_W = (DEPTH_B_S_W + 1);
  localparam PE_ID_START = 4;

  localparam MASTER_W_BANK_BC = ((1 << CORE_BITS) - 1);
  localparam MASTER_W_BANK_MEM_D = 0;
  localparam MASTER_W_BANK_IO_REG = 1;
  localparam MASTER_R_BANK_MEM_D = 0;
  localparam MASTER_R_BANK_IO_REG = 1;
  localparam MASTER_R_BANK_U2M = 2;
  localparam MASTER_R_BANK_S2M = 3;
  localparam UART_IO_ADDR_RESET = ((1 << DEPTH_B_U) + 0);
  localparam UART_BANK_MEM_I = 0;
  localparam UART_BANK_U2M = 2;
  localparam FIFO_BANK_S2M = 0;
  localparam FIFO_BANK_VRAM = 1;
  localparam IO_REG_R_UART_BUSY = 0;
  localparam IO_REG_R_VGA_VSYNC = 1;
  localparam IO_REG_R_VGA_VCOUNT = 2;
  localparam IO_REG_W_RESET_PE = 0;
  localparam IO_REG_W_LED = 1;
  localparam IO_REG_W_UART = 2;
  localparam IO_REG_W_SPRITE_X = 3;
  localparam IO_REG_W_SPRITE_Y = 4;
  localparam IO_REG_W_SPRITE_SCALE = 5;

  localparam TRUE = 1'b1;
  localparam FALSE = 1'b0;
  localparam ONE = 1'd1;
  localparam ZERO = 1'd0;

  function integer max (input integer a1, input integer a2);
    begin
      if (a1 > a2)
        begin
          max = a1;
        end
      else
        begin
          max = a2;
        end
    end
  endfunction

  // LED
  assign led = io_reg_w[IO_REG_W_LED];

  // Master IO reg
  reg [WIDTH_M_D-1:0] io_reg_r[0:((1 << DEPTH_IO_REG) - 1)];
  reg [WIDTH_M_D-1:0] io_reg_w[0:((1 << DEPTH_IO_REG) - 1)];

  // Master read
  wire [DEPTH_V_M_R-DEPTH_B_M_R-1:0] master_d_r_bank;
  assign master_d_r_bank = master_d_r_addr[DEPTH_V_M_R-1:DEPTH_B_M_R];
  always @(posedge clk)
    begin
      case (master_d_r_bank)
        MASTER_R_BANK_MEM_D:
          begin
            master_d_r_data <= master_mem_d_r_data;
          end
        MASTER_R_BANK_IO_REG:
          begin
            master_d_r_data <= io_reg_r[master_d_r_addr[DEPTH_IO_REG-1:0]];
          end
`ifdef USE_UART
        MASTER_R_BANK_U2M:
          begin
            master_d_r_data <= u2m_r_data;
          end
`endif
        default:
          begin
            master_d_r_data <= {{(WIDTH_M_D-WIDTH_P_D){1'b0}}, s2m_r_data};
          end
      endcase
    end

  // Master mem_d write
  reg [DEPTH_V_M_W-1:0] master_d_w_addr_d1;
  reg [WIDTH_M_D-1:0] master_d_w_data_d1;
  reg                 master_d_we_d1;
  always @(posedge clk)
    begin
      master_d_w_addr_d1 <= master_d_w_addr;
      master_d_w_data_d1 <= master_d_w_data;
      master_d_we_d1 <= master_d_we;
    end

  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          master_mem_d_we <= FALSE;
        end
      else
        begin
          if ((master_d_we == TRUE) && (master_d_w_bank == MASTER_W_BANK_MEM_D))
            begin
              master_mem_d_we <= TRUE;
            end
          else
            begin
              master_mem_d_we <= FALSE;
            end
        end
    end

  // Master IO reg read
  always @(posedge clk)
    begin
`ifdef USE_UART
      io_reg_r[IO_REG_R_UART_BUSY] <= uart_io_busy;
`endif
`ifdef USE_VGA
      io_reg_r[IO_REG_R_VGA_VSYNC] <= vga_vsync;
      io_reg_r[IO_REG_R_VGA_VCOUNT] <= vga_vcount;
`endif
    end

  // Master IO reg write
  wire [WIDTH_M_D-1:0] io_reg_w_data;
  wire [DEPTH_IO_REG-1:0] io_reg_w_addr;
  reg io_reg_we;
  assign io_reg_w_data = master_d_w_data_d1;
  assign io_reg_w_addr = master_d_w_addr_d1[DEPTH_IO_REG-1:0];
  always @(posedge clk)
    begin
      if ((master_d_we == TRUE) && (master_d_w_bank == MASTER_W_BANK_IO_REG))
        begin
          io_reg_we <= TRUE;
        end
      else
        begin
          io_reg_we <= FALSE;
        end
      if (io_reg_we == TRUE)
        begin
          io_reg_w[io_reg_w_addr] <= io_reg_w_data;
        end
    end

`ifdef USE_UART
  // Master IO reg write: UART TX we
  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          uart_io_tx_we <= FALSE;
        end
      else
        begin
          if ((master_d_we == TRUE) && (master_d_w_addr == ((MASTER_W_BANK_IO_REG << DEPTH_B_M_W) + IO_REG_W_UART)))
            begin
              uart_io_tx_we <= TRUE;
            end
          else
            begin
              uart_io_tx_we <= FALSE;
            end
        end
    end
`endif

  // harvester
  reg [DEPTH_V_F-1:0] s2m_w_addr;
  reg [WIDTH_P_D-1:0] s2m_w_data;
  reg s2m_we;
  reg vram_we;
  wire [DEPTH_V_F-DEPTH_B_F-1:0] harvester_w_bank;
  assign harvester_w_bank = harvester_w_addr[DEPTH_V_F-1:DEPTH_B_F];
  always @(posedge clk)
    begin
      s2m_w_addr <= harvester_w_addr;
      s2m_w_data <= harvester_w_data;
      if (harvester_we == TRUE)
        begin
          if (harvester_w_bank == FIFO_BANK_S2M)
            begin
              s2m_we <= TRUE;
              vram_we <= FALSE;
            end
          else
            begin
              s2m_we <= FALSE;
              vram_we <= TRUE;
            end
        end
      else
        begin
          s2m_we <= FALSE;
          vram_we <= FALSE;
        end
    end

  wire harvester_r_valid [0:CORES-1];
  wire [WIDTH_P_D+DEPTH_V_F-1:0] harvester_r_data [0:CORES-1];
  wire [CORES-1:0] harvester_r_req;
  wire [DEPTH_V_F-1:0] harvester_w_addr;
  wire [WIDTH_P_D-1:0] harvester_w_data;
  wire harvester_we;
  wire [CORE_BITS-1:0] harvester_cs;
  
  harvester
    #(
      .CORE_BITS (CORE_BITS),
      .CORES (CORES),
      .WIDTH (WIDTH_P_D),
      .DEPTH (DEPTH_V_F)
      )
  harvester_0
    (
     .clk (clk),
     .reset (reset),
     .cs (harvester_cs),
     .r_data (harvester_r_data[harvester_cs]),
     .r_valid (harvester_r_valid[harvester_cs]),
     .r_req (harvester_r_req),
     .w_addr (harvester_w_addr),
     .w_data (harvester_w_data),
     .we (harvester_we)
     );

  wire [WIDTH_P_D-1:0] s2m_r_data;
  rw_port_ram
    #(
      .DATA_WIDTH (WIDTH_P_D),
      .ADDR_WIDTH (DEPTH_S2M)
      )
  shared_s2m
    (
     .clk (clk),
     .addr_r (master_d_r_addr[DEPTH_S2M-1:0]),
     .addr_w (s2m_w_addr[DEPTH_S2M-1:0]),
     .data_in (s2m_w_data),
     .we (s2m_we),
     .data_out (s2m_r_data)
     );

`ifdef USE_UART
  // UART IO: write to mem_i
  reg uart_io_tx_we;
  wire uart_io_busy;
  wire [31:0] uart_io_rx_addr;
  wire [31:0] uart_io_rx_data;
  reg [31:0] uart_io_rx_addr_d1;
  reg [31:0] uart_io_rx_data_d1;
  wire uart_io_rx_we;
  reg master_mem_i_we;
  wire [DEPTH_V_U-DEPTH_B_U-1:0] uart_io_rx_bank;
  assign uart_io_rx_bank = uart_io_rx_addr[DEPTH_V_U-1:DEPTH_B_U];

  always @(posedge clk)
    begin
      uart_io_rx_addr_d1 <= uart_io_rx_addr;
      uart_io_rx_data_d1 <= uart_io_rx_data;
    end

  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          master_mem_i_we <= FALSE;
        end
      else
        begin
          if ((uart_io_rx_we == TRUE) && (uart_io_rx_bank == UART_BANK_MEM_I))
            begin
              master_mem_i_we <= TRUE;
            end
          else
            begin
              master_mem_i_we <= FALSE;
            end
        end
    end

  // u2m write
  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          u2m_we <= FALSE;
        end
      else
        begin
          if ((uart_io_rx_we == TRUE) && (uart_io_rx_bank == UART_BANK_U2M))
            begin
              u2m_we <= TRUE;
            end
          else
            begin
              u2m_we <= FALSE;
            end
        end
    end

  // UART IO: reset master
  reg reset_master;
  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          reset_master <= FALSE;
        end
      else
        begin
          if ((uart_io_rx_we == TRUE) && (uart_io_rx_addr == UART_IO_ADDR_RESET))
            begin
              reset_master <= uart_io_rx_data[0];
            end
        end
    end

  uart_io
    #(
      .CLK_HZ (UART_CLK_HZ),
      .SCLK_HZ (UART_SCLK_HZ)
      )
  uart_io_0
    (
     .clk (clk),
     .reset (reset),
     .uart_rxd (uart_rxd),
     .tx_data (io_reg_w[IO_REG_W_UART][7:0]),
     .tx_we (uart_io_tx_we),
     .uart_txd (uart_txd),
     .uart_busy (uart_io_busy),
     .rx_addr (uart_io_rx_addr),
     .rx_data (uart_io_rx_data),
     .rx_we (uart_io_rx_we)
     );
`endif

`ifdef USE_VGA
  // sprite
  localparam SPRITE_BPP = 3;
  wire [SPRITE_BPP-1:0] color_all;
  // vga
  wire                  vga_vsync;
  wire [WIDTH_M_D-1:0]  vga_vcount;
  wire [32-1:0]         ext_vga_count_h;
  wire [32-1:0]         ext_vga_count_v;

  sprite
    #(
      .SPRITE_WIDTH_BITS (VRAM_WIDTH_BITS),
      .SPRITE_HEIGHT_BITS (VRAM_HEIGHT_BITS),
      .BPP (SPRITE_BPP),
      .RAM_TYPE (VRAM_RAM_TYPE)
      )
  sprite_0
    (
     .clk (clk),
     .reset (reset),
     .bitmap_length (),
     .bitmap_address (s2m_w_addr[DEPTH_VRAM-1:0]),
     .bitmap_din (s2m_w_data[VRAM_BPP-1:0]),
     .bitmap_dout (),
     .bitmap_we (vram_we),
     .bitmap_oe (FALSE),
     .x (io_reg_w[IO_REG_W_SPRITE_X]),
     .y (io_reg_w[IO_REG_W_SPRITE_Y]),
     .scale (io_reg_w[IO_REG_W_SPRITE_SCALE]),
     .ext_clkv (clkv),
     .ext_resetv (resetv),
     .ext_color (color_all),
     .ext_count_h (ext_vga_count_h),
     .ext_count_v (ext_vga_count_v)
     );

  vga_iface
    #(
  `ifdef VGA_720P
      .VGA_MAX_H (1650-1),
      .VGA_MAX_V (750-1),
      .VGA_WIDTH (1280),
      .VGA_HEIGHT (720),
      .VGA_SYNC_H_START (1390),
      .VGA_SYNC_V_START (725),
      .VGA_SYNC_H_END (1430),
      .VGA_SYNC_V_END (730),
      .PIXEL_DELAY (2),
  `else
      .VGA_MAX_H (800-1),
      .VGA_MAX_V (525-1),
      .VGA_WIDTH (640),
      .VGA_HEIGHT (480),
      .VGA_SYNC_H_START (656),
      .VGA_SYNC_V_START (490),
      .VGA_SYNC_H_END (752),
      .VGA_SYNC_V_END (492),
      .PIXEL_DELAY (2),
  `endif
  `ifdef CLIPV512
      .CLIP_ENABLE (1),
      .CLIP_V_E (512),
  `endif
      .BPP (VRAM_BPP)
      )
  vga_iface_0
    (
     .clk (clk),
     .reset (reset),
     .vsync (vga_vsync),
     .vcount (vga_vcount),
     .ext_clkv (clkv),
     .ext_resetv (resetv),
     .ext_color_in (color_all),
     .ext_vga_hs (vga_hs),
     .ext_vga_vs (vga_vs),
     .ext_vga_de (vga_de),
     .ext_vga_color_out (vga_color),
     .ext_count_h (ext_vga_count_h),
     .ext_count_v (ext_vga_count_v)
     );
`endif

  // Master core
  wire [DEPTH_V_M_W-1:0] master_d_w_addr;
  wire [WIDTH_M_D-1:0] master_d_w_data;
  wire master_d_we;
  wire [DEPTH_M_I-1:0] master_i_r_addr;
  wire [WIDTH_I-1:0] master_i_r_data;
  wire [DEPTH_V_M_R-1:0] master_d_r_addr;
  reg [WIDTH_M_D-1:0] master_d_r_data;
  wire [DEPTH_V_M_W-DEPTH_B_M_W-1:0] master_d_w_bank;
  assign master_d_w_bank = master_d_w_addr[DEPTH_V_M_W-1:DEPTH_B_M_W];
  mini16_cpu
    #(
      .WIDTH_I (WIDTH_I),
      .WIDTH_D (WIDTH_M_D),
      .DEPTH_I (DEPTH_M_I),
      .DEPTH_D (DEPTH_V_M),
      .DEPTH_REG (DEPTH_REG),
      .ENABLE_MVIL (TRUE),
      .ENABLE_MUL (TRUE),
      .ENABLE_MULTI_BIT_SHIFT (TRUE),
      .ENABLE_MVC (TRUE),
      .ENABLE_WA (TRUE),
      .ENABLE_INT (TRUE),
      .FULL_PIPELINED_ALU (FALSE),
      .REGFILE_RAM_TYPE (MASTER_REGFILE_RAM_TYPE)
      )
  mini16_cpu_master
    (
     .clk (clk),
`ifdef USE_UART
     .soft_reset (reset_master),
`else
     .soft_reset (FALSE),
`endif
     .reset (reset),
     .mem_i_r_addr (master_i_r_addr),
     .mem_i_r_data (master_i_r_data),
     .mem_d_r_addr (master_d_r_addr),
     .mem_d_r_data (master_d_r_data),
     .mem_d_w_addr (master_d_w_addr),
     .mem_d_w_data (master_d_w_data),
     .mem_d_we (master_d_we)
     );

  default_master_code_mem
    #(
      .DATA_WIDTH (WIDTH_I),
      .ADDR_WIDTH (DEPTH_M_I)
      )
  master_mem_i
    (
     .clk (clk),
     .addr_r (master_i_r_addr),
`ifdef USE_UART
     .addr_w (uart_io_rx_addr_d1[DEPTH_M_I-1:0]),
     .data_in (uart_io_rx_data_d1[WIDTH_I-1:0]),
     .we (master_mem_i_we),
`else
     .addr_w ({DEPTH_M_I{1'b0}}),
     .data_in ({WIDTH_I{1'b0}}),
     .we (FALSE),
`endif
     .data_out (master_i_r_data)
     );

  wire [WIDTH_M_D-1:0] master_mem_d_r_data;
  reg master_mem_d_we;
  default_master_data_mem
    #(
      .DATA_WIDTH (WIDTH_M_D),
      .ADDR_WIDTH (DEPTH_M_D)
      )
  master_mem_d
    (
     .clk (clk),
     .addr_r (master_d_r_addr[DEPTH_M_D-1:0]),
     .addr_w (master_d_w_addr_d1[DEPTH_M_D-1:0]),
     .data_in (master_d_w_data_d1),
     .we (master_mem_d_we),
     .data_out (master_mem_d_r_data)
     );

`ifdef USE_UART
  reg u2m_we;
  wire [WIDTH_M_D-1:0] u2m_r_data;
  rw_port_ram
    #(
      .DATA_WIDTH (WIDTH_M_D),
      .ADDR_WIDTH (DEPTH_U2M)
      )
  shared_u2m
    (
     .clk (clk),
     .addr_r (master_d_r_addr[DEPTH_U2M-1:0]),
     .addr_w (uart_io_rx_addr_d1[DEPTH_U2M-1:0]),
     .data_in (uart_io_rx_data_d1[WIDTH_M_D-1:0]),
     .we (u2m_we),
     .data_out (u2m_r_data)
     );
`endif

  generate
    genvar i;
    for (i = 0; i < CORES; i = i + 1)
      begin: mini16_pe_gen
        mini16_pe
             #(
               .WIDTH_D (WIDTH_P_D),
               .DEPTH_I (DEPTH_P_I),
               .DEPTH_D (DEPTH_P_D),
               .DEPTH_M2S (DEPTH_M2S),
               .DEPTH_FIFO (DEPTH_FIFO),
               .CORE_ID (i + PE_ID_START),
               .MASTER_W_BANK_BC (MASTER_W_BANK_BC),
               .DEPTH_V_F (DEPTH_V_F),
               .DEPTH_B_F (DEPTH_B_F),
               .DEPTH_V_M (DEPTH_V_M),
               .DEPTH_B_M (DEPTH_B_M_W),
               .DEPTH_V_S_R (DEPTH_V_S_R),
               .DEPTH_B_S_R (DEPTH_B_S_R),
               .DEPTH_V_S_W (DEPTH_V_S_W),
               .DEPTH_B_S_W (DEPTH_B_S_W),
               .DEPTH_V_M2S (DEPTH_V_M2S),
               .DEPTH_B_M2S (DEPTH_B_M2S),
               .FIFO_RAM_TYPE (PE_FIFO_RAM_TYPE),
               .REGFILE_RAM_TYPE (PE_REGFILE_RAM_TYPE),
               .M2S_RAM_TYPE (PE_M2S_RAM_TYPE),
               .DEPTH_REG (PE_DEPTH_REG),
               .ENABLE_MVIL (PE_ENABLE_MVIL),
               .ENABLE_MUL (PE_ENABLE_MUL),
               .ENABLE_MULTI_BIT_SHIFT (PE_ENABLE_MULTI_BIT_SHIFT),
               .ENABLE_MVC (PE_ENABLE_MVC),
               .ENABLE_WA (PE_ENABLE_WA)
               )
        mini16_pe_0
             (
              .clk (clk),
              .reset (reset),
              .soft_reset (io_reg_w[IO_REG_W_RESET_PE][0]),
              .fifo_req_r (harvester_r_req[i]),
              .fifo_valid (harvester_r_valid[i]),
              .fifo_r_data (harvester_r_data[i]),
              .addr_i (master_d_w_addr_d1),
              .data_i (master_d_w_data_d1),
              .we_i (master_d_we_d1)
              );
      end
  endgenerate

endmodule
