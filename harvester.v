// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2019 miya All rights reserved.

module harvester
  #(
    parameter CORE_BITS = 8,
    parameter CORES = 32,
    parameter WIDTH = 32,
    parameter DEPTH = 8
    )
  (
   input                   clk,
   input                   reset,
   output [CORE_BITS-1:0]  cs,
   input [WIDTH+DEPTH-1:0] r_data,
   input                   r_valid,
   output reg [CORES-1:0]  r_req,
   output [DEPTH-1:0]      w_addr,
   output [WIDTH-1:0]      w_data,
   output reg              we
   );

  localparam TRUE = 1'b1;
  localparam FALSE = 1'b0;
  localparam ONE = 1'd1;
  localparam ZERO = 1'd0;

  // fifo to s2m core select
  reg [CORE_BITS-1:0] core;
  reg [CORE_BITS-1:0] core_d1;
  reg [CORE_BITS-1:0] core_d2;
  reg [CORE_BITS-1:0] core_d3;
  always @(posedge clk)
    begin
      core_d1 <= core;
      core_d2 <= core_d1;
      core_d3 <= core_d2;
      if (reset == TRUE)
        begin
          core <= ZERO;
        end
      else
        begin
          if (core == CORES - 1)
            begin
              core <= ZERO;
            end
          else
            begin
              core <= core + ONE;
            end
        end
    end

  assign cs = core_d3;
  assign w_addr = harvester_r_data_fetch_d1[WIDTH+DEPTH-1:WIDTH];
  assign w_data = harvester_r_data_fetch_d1[WIDTH-1:0];

  reg [WIDTH+DEPTH-1:0] harvester_r_data_fetch;
  reg [WIDTH+DEPTH-1:0] harvester_r_data_fetch_d1;
  reg r_valid_d1;

  always @(posedge clk)
    begin
      r_req[core] <= TRUE;
      r_req[core_d1] <= FALSE;
      r_valid_d1 <= r_valid;
      we <= r_valid_d1;
      harvester_r_data_fetch <= r_data;
      harvester_r_data_fetch_d1 <= harvester_r_data_fetch;
    end

endmodule
