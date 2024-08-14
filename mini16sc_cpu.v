// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2024 miya All rights reserved.

module mini16sc_cpu
  #(
    parameter WIDTH_I = 16,
    parameter WIDTH_D = 16,
    parameter DEPTH_I = 8,
    parameter DEPTH_D = 8,
    parameter DEPTH_REG = 5
    )
  (
   input                    clk,
   input                    reset,
   input                    soft_reset,
   output reg [DEPTH_I-1:0] mem_i_r_addr,
   input [WIDTH_I-1:0]      mem_i_r_data,
   output reg [DEPTH_D-1:0] mem_d_r_addr,
   input [WIDTH_D-1:0]      mem_d_r_data,
   output reg [DEPTH_D-1:0] mem_d_w_addr,
   output reg [WIDTH_D-1:0] mem_d_w_data,
   output reg               mem_d_we
   );

  localparam TRUE = 1'b1;
  localparam FALSE = 1'b0;
  localparam ONE = 1'd1;
  localparam ZERO = 1'd0;
  localparam FFFF = {WIDTH_D{1'b1}};
  localparam SHIFT_BITS = $clog2(WIDTH_D);
  localparam DEPTH_OPERAND = 5;
  localparam MUL_DELAY = 3;
  localparam BL_OFFSET = 1'd1;

  // opcode
  // reg_we: FALSE
  localparam I_NOP  = 5'h00;
  localparam I_ST   = 5'h01;
  localparam I_MVC  = 5'h02;
  localparam I_BA   = 5'h03;
  localparam I_BC   = 5'h04;
  localparam I_MUL  = 5'h05;
  localparam I_SR   = 5'h06;
  localparam I_SL   = 5'h07;
  localparam I_SRA  = 5'h08;
  // reg_we: TRUE
  localparam I_ADD  = 5'h10;
  localparam I_SUB  = 5'h11;
  localparam I_AND  = 5'h12;
  localparam I_OR   = 5'h13;
  localparam I_XOR  = 5'h14;
  localparam I_MV   = 5'h15;
  localparam I_MVIL = 5'h16;
  localparam I_MVS  = 5'h17;
  localparam I_BL   = 5'h18;
  localparam I_LD   = 5'h19;
  localparam I_CNZ  = 5'h1a;
  localparam I_CNM  = 5'h1b;

  localparam SP_REG_MVC = 0;
  localparam SP_REG_MVIL = 1;

  reg [WIDTH_I-1:0]        inst;
  wire [DEPTH_OPERAND-1:0] ol_d;
  wire [DEPTH_OPERAND-1:0] ol_a;
  wire [10:0]              im_l;
  wire                     is_im;
  wire [4:0]               op;
  reg                      do_jump;
  reg [DEPTH_I-1:0]        jump_addr;
  reg [WIDTH_D-1:0]        reg_data_w;
  reg [WIDTH_D-1:0]        reg_data_r_d;
  reg [WIDTH_D-1:0]        reg_data_r_a;
  wire [WIDTH_D-1:0]       reg_addr_a;
  reg [DEPTH_REG-1:0]      reg_addr_w;
  reg                      reg_we;
  reg [WIDTH_D-1:0]        alu_din_d,  alu_din_a;
  reg [WIDTH_D-1:0]        result_sl,  sl_pd,  sl_pa,  sl_b;
  reg [WIDTH_D-1:0]        result_sr,  sr_pd,  sr_pa,  sr_b;
  reg [WIDTH_D-1:0]        result_sra, sra_pd, sra_pa, sra_b;
  reg [WIDTH_D-1:0]        result_mul, mul_pd, mul_pa;
  reg [WIDTH_D-1:0]        mul_b [0:MUL_DELAY];
  reg [WIDTH_D-1:0]        regfile [0:(1<<DEPTH_REG)-1];
  reg [WIDTH_D-1:0]        reg_sp [0:3];
  reg                      reg_a_nz;
  reg                      reg_a_nm;
  integer                  i;

  assign ol_d = inst[15:11];
  assign ol_a = inst[10:6];
  assign is_im = inst[5];
  assign op = inst[4:0];
  assign im_l = inst[15:5];

  always @*
  begin
    // register read
    reg_data_r_d = regfile[ol_d];
    reg_data_r_a = regfile[ol_a];

    reg_a_nz = (reg_data_r_a != ZERO);
    reg_a_nm = (reg_data_r_a[WIDTH_D-1] == 1'b0);

    // register write
    case (op)
      I_MVC:   reg_addr_w = SP_REG_MVC;
      I_MVIL:  reg_addr_w = SP_REG_MVIL;
      default: reg_addr_w = ol_d;
    endcase
    if ((op[4] == TRUE) || ((op == I_MVC) && (reg_a_nz == TRUE)))
      reg_we = TRUE;
    else
      reg_we = FALSE;

    // branch
    if ((op == I_BA) || ((op == I_BC) && (reg_data_r_d != ZERO)) || (op == I_BL))
    begin
      do_jump = TRUE;
      jump_addr = reg_data_r_a;
    end
    else
    begin
      do_jump = FALSE;
      jump_addr = ZERO;
    end

    // ALU
    alu_din_d = reg_data_r_d;
    if (is_im == TRUE)
      alu_din_a = $signed(ol_a);
    else
      alu_din_a = reg_data_r_a;

    case (op)
      I_ADD: reg_data_w = alu_din_d + alu_din_a;
      I_SUB: reg_data_w = alu_din_d - alu_din_a;
      I_AND: reg_data_w = alu_din_d & alu_din_a;
      I_OR:  reg_data_w = alu_din_d | alu_din_a;
      I_XOR: reg_data_w = alu_din_d ^ alu_din_a;
      I_MV:  reg_data_w = alu_din_a;
      I_MVC: reg_data_w = alu_din_d;
      I_MVS: reg_data_w = reg_sp[alu_din_a];
      I_BL:  reg_data_w = mem_i_r_addr + BL_OFFSET;
      I_LD:  reg_data_w = mem_d_r_data;
      I_MVIL: reg_data_w = im_l;
      I_CNZ:
        begin
          if (reg_a_nz == TRUE)
            reg_data_w = {WIDTH_D{TRUE}};
          else
            reg_data_w = {WIDTH_D{FALSE}};
        end
      I_CNM:
        begin
          if (reg_a_nm == TRUE)
            reg_data_w = {WIDTH_D{TRUE}};
          else
            reg_data_w = {WIDTH_D{FALSE}};
        end
      default: reg_data_w = ZERO;
    endcase
  end

  always @(posedge clk)
  begin
    // register write
    if (reg_we == 1'b1)
    begin
      regfile[reg_addr_w] <= reg_data_w;
    end

    // PC
    if (reset == TRUE)
    begin
      mem_i_r_addr <= ZERO;
    end
    else
    begin
      if (soft_reset == TRUE)
      begin
        mem_i_r_addr <= ZERO;
      end
      else
      begin
        if (do_jump == TRUE)
        begin
          mem_i_r_addr <= jump_addr;
        end
        else
        begin
          mem_i_r_addr <= mem_i_r_addr + ONE;
        end
      end
    end

    // fetch
    if (reset == TRUE)
      inst <= ZERO;
    else
      inst <= mem_i_r_data;

    // load, store
    if (op == I_LD)
      mem_d_r_addr <= reg_data_r_a;
    if (op == I_ST)
      mem_d_w_addr <= reg_data_r_d;
    if (op == I_ST)
      mem_d_w_data <= alu_din_a;
    if (op == I_ST)
      mem_d_we <= TRUE;
    else
      mem_d_we <= FALSE;

    // mul
    if (op == I_MUL)
    begin
      mul_pd <= alu_din_d;
      mul_pa <= alu_din_a;
    end
    mul_b[0] <= mul_pd * mul_pa;
    for (i = 0; i < MUL_DELAY; i = i + 1)
    begin: gen_mul_b
      mul_b[i + 1] <= mul_b[i];
    end
    reg_sp[3] <= mul_b[MUL_DELAY];

    // shift
    if (op == I_SL)
    begin
      sl_pd <= alu_din_d;
      sl_pa <= alu_din_a;
    end
    sl_b <= sl_pd << sl_pa;
    reg_sp[0] <= sl_b;

    if (op == I_SR)
    begin
      sr_pd <= alu_din_d;
      sr_pa <= alu_din_a;
    end
    sr_b <= sr_pd >> sr_pa;
    reg_sp[1] <= sr_b;

    if (op == I_SRA)
    begin
      sra_pd <= alu_din_d;
      sra_pa <= alu_din_a;
    end
    sra_b <= $signed(sra_pd) >>> sra_pa;
    reg_sp[2] <= sra_b;
  end
endmodule
