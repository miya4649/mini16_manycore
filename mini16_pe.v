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

module mini16_pe
  #(
    parameter WIDTH_D = 16,
    parameter DEPTH_I = 8,
    parameter DEPTH_D = 8,
    parameter DEPTH_M2S = 8,
    parameter DEPTH_FIFO = 7,
    parameter CORE_ID = 0,
    parameter MASTER_W_BANK_BC = 63,
    parameter DEPTH_V_F = 16,
    parameter DEPTH_B_F = 15,
    parameter DEPTH_V_M_W = 17,
    parameter DEPTH_B_M_W = 11,
    parameter DEPTH_V_S_R = 10,
    parameter DEPTH_B_S_R = 8,
    parameter DEPTH_V_S_W = 9,
    parameter DEPTH_B_S_W = 8,
    parameter DEPTH_V_M2S = 9,
    parameter DEPTH_B_M2S = 8,
    parameter FIFO_RAM_TYPE = "auto",
    parameter REGFILE_RAM_TYPE = "auto",
    parameter M2S_RAM_TYPE = "auto",
    parameter DEPTH_REG = 5,
    parameter ENABLE_MVIL = 1'b1,
    parameter ENABLE_MUL = 1'b1,
    parameter ENABLE_MULTI_BIT_SHIFT = 1'b1,
    parameter ENABLE_MVC = 1'b1,
    parameter ENABLE_WA = 1'b1
    )
  (
   input                          clk,
   input                          reset,
   input                          soft_reset,
   input                          fifo_req_r,
   output                         fifo_valid,
   output [WIDTH_D+DEPTH_V_F-1:0] fifo_r_data,
   input [DEPTH_V_M_W-1:0]        addr_i,
   input [WIDTH_D-1:0]            data_i,
   input                          we_i
   );

  localparam WIDTH_I = 16;
  localparam TRUE = 1'b1;
  localparam FALSE = 1'b0;
  localparam ONE = 1'd1;
  localparam ZERO = 1'd0;
  localparam FFFF = {WIDTH_D{1'b1}};

  wire [DEPTH_I-1:0]     cpu_i_r_addr;
  wire [WIDTH_I-1:0]     cpu_i_r_data;
  wire [DEPTH_V_S_W-1:0] cpu_d_r_addr;
  reg [WIDTH_D-1:0]      cpu_d_r_data;
  wire [DEPTH_V_S_W-1:0] cpu_d_w_addr;
  wire [WIDTH_D-1:0]     cpu_d_w_data;
  wire                   cpu_d_we;
  wire [DEPTH_V_S_W-DEPTH_B_S_W-1:0] cpu_d_w_bank;
  wire [DEPTH_V_S_R-DEPTH_B_S_R-1:0] cpu_d_r_bank;

  // cpu data write
  reg [DEPTH_D-1:0]  mem_d_w_addr;
  reg [WIDTH_D-1:0]  mem_d_w_data;
  reg                mem_d_we;
  assign cpu_d_w_bank = cpu_d_w_addr[DEPTH_V_S_W-1:DEPTH_B_S_W];
  always @(posedge clk)
    begin
      mem_d_w_addr <= cpu_d_w_addr[DEPTH_D-1:0];
      mem_d_w_data <= cpu_d_w_data;
      s2mfifo_data_w <= {cpu_d_w_addr[DEPTH_V_F-1:0], cpu_d_w_data};
      if (cpu_d_we == TRUE)
        begin
          case (cpu_d_w_bank)
            0:
              begin
                // mem_d
                mem_d_we <= TRUE;
                s2mfifo_we <= FALSE;
              end
            default:
              begin
                // fifo
                mem_d_we <= FALSE;
                s2mfifo_we <= TRUE;
              end
          endcase
        end
      else
        begin
          mem_d_we <= FALSE;
          s2mfifo_we <= FALSE;
        end
    end

  // cpu data read
  wire [DEPTH_D-1:0] mem_d_r_addr;
  wire [WIDTH_D-1:0] mem_d_r_data;
  wire [WIDTH_D-1:0] shared_m2s_r_data;
  assign mem_d_r_addr = cpu_d_r_addr[DEPTH_D-1:0];
  assign cpu_d_r_bank = cpu_d_r_addr[DEPTH_V_S_R-1:DEPTH_B_S_R];
  always @(posedge clk)
    begin
      case (cpu_d_r_bank)
        // mem_d
        0: cpu_d_r_data <= mem_d_r_data;
        // shared_m2s
        1: cpu_d_r_data <= shared_m2s_r_data;
        // register
        default: cpu_d_r_data <= s2mfifo_item_count;
      endcase
    end

  // data from master
  reg shared_m2s_we;
  reg mem_i_we;
  reg [DEPTH_V_M_W-1:0] addr_i_d1;
  reg [WIDTH_D-1:0]     data_i_d1;
  reg [DEPTH_V_M_W-1:0] addr_i_d2;
  reg [WIDTH_D-1:0]     data_i_d2;
  reg                   we_i_d1;
  wire [DEPTH_V_M_W-DEPTH_B_M_W-1:0] core_bank;
  wire [DEPTH_V_M2S-DEPTH_B_M2S-1:0] m2s_bank;
  assign core_bank = addr_i_d1[DEPTH_V_M_W-1:DEPTH_B_M_W];
  assign m2s_bank = addr_i_d1[DEPTH_V_M2S-1:DEPTH_B_M2S];

  always @(posedge clk)
    begin
      addr_i_d1 <= addr_i;
      data_i_d1 <= data_i;
      addr_i_d2 <= addr_i_d1;
      data_i_d2 <= data_i_d1;
      we_i_d1 <= we_i;
    end

  always @(posedge clk)
    begin
      if ((we_i_d1 == TRUE) && ((core_bank == CORE_ID) || (core_bank == MASTER_W_BANK_BC)))
        begin
          case (m2s_bank)
            0:
              begin
                shared_m2s_we <= TRUE;
                mem_i_we <= FALSE;
              end
            default:
              begin
                shared_m2s_we <= FALSE;
                mem_i_we <= TRUE;
              end
          endcase
        end
      else
        begin
          shared_m2s_we <= FALSE;
          mem_i_we <= FALSE;
        end
    end

  mini16_cpu
    #(
      .WIDTH_I (WIDTH_I),
      .WIDTH_D (WIDTH_D),
      .DEPTH_I (DEPTH_I),
      .DEPTH_D (DEPTH_V_S_W),
      .DEPTH_REG (DEPTH_REG),
      .ENABLE_MVIL (ENABLE_MVIL),
      .ENABLE_MUL (ENABLE_MUL),
      .ENABLE_MULTI_BIT_SHIFT (ENABLE_MULTI_BIT_SHIFT),
      .ENABLE_MVC (ENABLE_MVC),
      .ENABLE_WA (ENABLE_WA),
      .ENABLE_INT (TRUE),
      .FULL_PIPELINED_ALU (FALSE),
      .REGFILE_RAM_TYPE (REGFILE_RAM_TYPE)
      )
  mini16_cpu_0
    (
     .clk (clk),
     .reset (reset),
     .soft_reset (soft_reset),
     .mem_i_r_addr (cpu_i_r_addr),
     .mem_i_r_data (cpu_i_r_data),
     .mem_d_r_addr (cpu_d_r_addr),
     .mem_d_r_data (cpu_d_r_data),
     .mem_d_w_addr (cpu_d_w_addr),
     .mem_d_w_data (cpu_d_w_data),
     .mem_d_we (cpu_d_we)
     );

  default_pe_code_mem
    #(
      .DATA_WIDTH (WIDTH_I),
      .ADDR_WIDTH (DEPTH_I)
      )
  mem_i
    (
     .clk (clk),
     .addr_r (cpu_i_r_addr),
     .addr_w (addr_i_d2[DEPTH_I-1:0]),
     .data_in (data_i_d2[WIDTH_I-1:0]),
     .we (mem_i_we),
     .data_out (cpu_i_r_data)
     );

  default_pe_data_mem
    #(
      .DATA_WIDTH (WIDTH_D),
      .ADDR_WIDTH (DEPTH_D)
      )
  mem_d
    (
     .clk (clk),
     .addr_r (mem_d_r_addr),
     .addr_w (mem_d_w_addr),
     .data_in (mem_d_w_data),
     .we (mem_d_we),
     .data_out (mem_d_r_data)
     );

  rw_port_ram
    #(
      .DATA_WIDTH (WIDTH_D),
      .ADDR_WIDTH (DEPTH_M2S),
      .RAM_TYPE (M2S_RAM_TYPE)
      )
  shared_m2s
    (
     .clk (clk),
     .addr_r (mem_d_r_addr[DEPTH_M2S-1:0]),
     .addr_w (addr_i_d2[DEPTH_M2S-1:0]),
     .data_in (data_i_d2),
     .we (shared_m2s_we),
     .data_out (shared_m2s_r_data)
     );

  reg s2mfifo_we;
  reg [WIDTH_D+DEPTH_V_F-1:0] s2mfifo_data_w;
  wire [DEPTH_FIFO-1:0] s2mfifo_item_count;
  fifo
    #(
      .WIDTH (WIDTH_D+DEPTH_V_F),
      .DEPTH_IN_BITS (DEPTH_FIFO),
      .MAX_ITEMS (((1 << DEPTH_FIFO) - 7)),
      .RAM_TYPE (FIFO_RAM_TYPE)
      )
  s2mfifo
    (
     .clk (clk),
     .reset (reset),
     .req_r (fifo_req_r),
     .we (s2mfifo_we),
     .data_w (s2mfifo_data_w),
     .data_r (fifo_r_data),
     .valid_r (fifo_valid),
     .full (),
     .item_count (s2mfifo_item_count),
     .empty ()
     );

endmodule
