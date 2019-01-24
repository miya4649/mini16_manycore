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
