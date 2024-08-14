// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2017 miya All rights reserved.

// ver. 2024/04/21

module r2w1_port_ram
  #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 12,
    parameter RAM_TYPE = "auto"
    )
  (
   input wire                     clk,
   input wire [(ADDR_WIDTH-1):0]  addr_r_a,
   input wire [(ADDR_WIDTH-1):0]  addr_r_b,
   input wire [(ADDR_WIDTH-1):0]  addr_w,
   input wire [(DATA_WIDTH-1):0]  data_in,
   input wire                     we,
   output wire [(DATA_WIDTH-1):0] data_out_a,
   output wire [(DATA_WIDTH-1):0] data_out_b
   );

  rw_port_ram
    #(
      .DATA_WIDTH (DATA_WIDTH),
      .ADDR_WIDTH (ADDR_WIDTH),
      .RAM_TYPE (RAM_TYPE)
      )
  rw_port_ram_a
    (
     .clk (clk),
     .addr_r (addr_r_a),
     .addr_w (addr_w),
     .data_in (data_in),
     .we (we),
     .data_out (data_out_a)
     );

  rw_port_ram
    #(
      .DATA_WIDTH (DATA_WIDTH),
      .ADDR_WIDTH (ADDR_WIDTH),
      .RAM_TYPE (RAM_TYPE)
      )
  rw_port_ram_b
    (
     .clk (clk),
     .addr_r (addr_r_b),
     .addr_w (addr_w),
     .data_in (data_in),
     .we (we),
     .data_out (data_out_b)
     );

endmodule
