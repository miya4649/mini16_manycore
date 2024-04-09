/*
  Copyright (c) 2018-2019, miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

`timescale 1ns / 1ps
//`define USE_UART
`define USE_VGA
`define DEBUG
`define RAM_TYPE_DISTRIBUTED "distributed"

module testbench;

  localparam STEP  = 20; // 20 ns: 50MHz
  localparam TICKS = 10000;

  localparam TRUE = 1'b1;
  localparam FALSE = 1'b0;
  localparam CORES = 4;
  localparam DEPTH_REG = 5;

`ifdef PE16
  // PE:16bit
  localparam WIDTH_P_D = 16;
  localparam DEPTH_P_I = 9;
  localparam DEPTH_M2S = 4;
  localparam DEPTH_FIFO = 3;
  localparam VRAM_WIDTH_BITS = 6;
  localparam VRAM_HEIGHT_BITS = 7;
  localparam PE_REGFILE_RAM_TYPE = "distributed";
  localparam PE_M2S_RAM_TYPE = "distributed";
  localparam PE_DEPTH_REG = 4;
  localparam PE_ENABLE_MUL = FALSE;
  localparam PE_ENABLE_MULTI_BIT_SHIFT = FALSE;
  localparam PE_ENABLE_MVC = FALSE;
  localparam PE_ENABLE_WA = FALSE;
`else
  // PE:32bit
  localparam WIDTH_P_D = 32;
  localparam DEPTH_P_I = 10;
  localparam DEPTH_M2S = 8;
  localparam DEPTH_FIFO = 4;
  localparam VRAM_WIDTH_BITS = 8;
  localparam VRAM_HEIGHT_BITS = 9;
  localparam PE_REGFILE_RAM_TYPE = "auto";
  localparam PE_M2S_RAM_TYPE = "auto";
  localparam PE_DEPTH_REG = 5;
  localparam PE_ENABLE_MUL = TRUE;
  localparam PE_ENABLE_MULTI_BIT_SHIFT = TRUE;
  localparam PE_ENABLE_MVC = TRUE;
  localparam PE_ENABLE_WA = TRUE;
`endif

  localparam PE_FIFO_RAM_TYPE = "distributed";
  localparam PE_ENABLE_MVIL = TRUE;
  localparam UART_CLK_HZ = 50000000;
  localparam UART_SCLK_HZ = 115200;

  reg clk;
  reg reset;
  wire [15:0] led;
`ifdef USE_UART
  // uart
  wire uart_txd;
  wire uart_rxd;
`endif
`ifdef USE_VGA
  localparam VRAM_BPP = 3;
  localparam STEPV = 40;
  wire VGA_HS;
  wire VGA_VS;
  wire [VRAM_BPP-1:0] VGA_COLOR;
`endif

  integer i;
  initial
    begin
      $dumpfile("wave.vcd");
      $dumpvars(10, testbench);
      $monitor("time: %d reset: %d led: %d", $time, reset, led);
      for (i = 0; i < (1 << DEPTH_REG); i = i + 1)
        begin
          $dumpvars(0, testbench.mini16_soc_0.mini16_cpu_master.reg_file.rw_port_ram_a.gen.ram[i]);
        end
      for (i = 0; i < (1 << PE_DEPTH_REG); i = i + 1)
        begin
          $dumpvars(0, testbench.mini16_soc_0.mini16_pe_gen[0].mini16_pe_0.mini16_cpu_0.reg_file.rw_port_ram_a.gen.ram[i]);
          $dumpvars(0, testbench.mini16_soc_0.mini16_pe_gen[1].mini16_pe_0.mini16_cpu_0.reg_file.rw_port_ram_a.gen.ram[i]);
        end
      for (i = 0; i < 4; i = i + 1)
        begin
          $dumpvars(0, testbench.mini16_soc_0.master_mem_d.ram[i]);
          $dumpvars(0, testbench.mini16_soc_0.mini16_pe_gen[0].mini16_pe_0.shared_m2s.gen.ram[i]);
          $dumpvars(0, testbench.mini16_soc_0.mini16_pe_gen[1].mini16_pe_0.shared_m2s.gen.ram[i]);
          $dumpvars(0, testbench.mini16_soc_0.mini16_pe_gen[2].mini16_pe_0.shared_m2s.gen.ram[i]);
          $dumpvars(0, testbench.mini16_soc_0.mini16_pe_gen[3].mini16_pe_0.shared_m2s.gen.ram[i]);
          $dumpvars(0, testbench.mini16_soc_0.shared_s2m.gen.ram[i]);
        end
      for (i = 0; i < 16; i = i + 1)
        begin
          $dumpvars(0, testbench.mini16_soc_0.io_reg_r[i]);
          $dumpvars(0, testbench.mini16_soc_0.io_reg_w[i]);
        end
    end

  // generate clk
  initial
    begin
      clk = 1'b1;
      forever
        begin
          #(STEP / 2) clk = ~clk;
        end
    end

  // generate reset signal
  initial
    begin
      reset = 1'b0;
      repeat (10) @(posedge clk) reset <= 1'b1;
      @(posedge clk) reset <= 1'b0;
    end

  // stop simulation after TICKS
  initial
    begin
      repeat (TICKS) @(posedge clk);
      $finish;
    end

`ifdef USE_VGA
  reg clkv;
  reg resetv;
  reg resetv1;
  // truncate RGB data
  wire VGA_COLOR_in;
  assign VGA_COLOR = VGA_COLOR_in;

  initial
    begin
      clkv = 1'b1;
      forever
        begin
          #(STEPV / 2) clkv = ~clkv;
        end
    end

  always @(posedge clkv)
    begin
      resetv1 <= reset;
      resetv <= resetv1;
    end
`endif

  mini16_soc
    #(
      .CORES (CORES),
      .UART_CLK_HZ (UART_CLK_HZ),
      .UART_SCLK_HZ (UART_SCLK_HZ),
      .WIDTH_P_D (WIDTH_P_D),
      .DEPTH_P_I (DEPTH_P_I),
      .DEPTH_M2S (DEPTH_M2S),
      .DEPTH_FIFO (DEPTH_FIFO),
      .VRAM_WIDTH_BITS (VRAM_WIDTH_BITS),
      .VRAM_HEIGHT_BITS (VRAM_HEIGHT_BITS),
      .PE_REGFILE_RAM_TYPE (PE_REGFILE_RAM_TYPE),
      .PE_FIFO_RAM_TYPE (PE_FIFO_RAM_TYPE),
      .PE_M2S_RAM_TYPE (PE_M2S_RAM_TYPE),
      .PE_DEPTH_REG (PE_DEPTH_REG),
      .PE_ENABLE_MVIL (PE_ENABLE_MVIL),
      .PE_ENABLE_MUL (PE_ENABLE_MUL),
      .PE_ENABLE_MULTI_BIT_SHIFT (PE_ENABLE_MULTI_BIT_SHIFT),
      .PE_ENABLE_MVC (PE_ENABLE_MVC),
      .PE_ENABLE_WA (PE_ENABLE_WA)
      )
  mini16_soc_0
    (
     .clk (clk),
     .reset (reset),
`ifdef USE_UART
     .uart_rxd (uart_rxd),
     .uart_txd (uart_txd),
`endif
`ifdef USE_VGA
     .clkv (clkv),
     .resetv (resetv),
     .vga_hs (VGA_HS),
     .vga_vs (VGA_VS),
     .vga_color (VGA_COLOR_in),
`endif
     .led (led)
     );

endmodule
