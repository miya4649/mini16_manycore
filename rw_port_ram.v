/*
  Copyright (c) 2015, miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// ver. 2024/04/21

module rw_port_ram
  #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 12,
    parameter RAM_TYPE = "auto"
    )
  (
   input wire                    clk,
   input wire [(ADDR_WIDTH-1):0] addr_r,
   input wire [(ADDR_WIDTH-1):0] addr_w,
   input wire [(DATA_WIDTH-1):0] data_in,
   input wire                    we,
   output reg [(DATA_WIDTH-1):0] data_out
   );

  generate
    if (RAM_TYPE == "xi_distributed")
      begin
        (* ram_style = "distributed" *) reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
        always @(posedge clk)
          begin
            data_out <= ram[addr_r];
            if (we)
              begin
                ram[addr_w] <= data_in;
              end
          end
      end
    else if (RAM_TYPE == "xi_block")
      begin
        (* ram_style = "block" *) reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
        always @(posedge clk)
          begin
            data_out <= ram[addr_r];
            if (we)
              begin
                ram[addr_w] <= data_in;
              end
          end
      end
    else if (RAM_TYPE == "xi_register")
      begin
        (* ram_style = "register" *) reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
        always @(posedge clk)
          begin
            data_out <= ram[addr_r];
            if (we)
              begin
                ram[addr_w] <= data_in;
              end
          end
      end
    else if (RAM_TYPE == "xi_ultra")
      begin
        (* ram_style = "ultra" *) reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
        always @(posedge clk)
          begin
            data_out <= ram[addr_r];
            if (we)
              begin
                ram[addr_w] <= data_in;
              end
          end
      end
    else if (RAM_TYPE == "al_logic")
      begin
        (* ramstyle = "logic" *) reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
        always @(posedge clk)
          begin
            data_out <= ram[addr_r];
            if (we)
              begin
                ram[addr_w] <= data_in;
              end
          end
      end
    else if (RAM_TYPE == "al_mlab")
      begin
        (* ramstyle = "MLAB" *) reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
        always @(posedge clk)
          begin
            data_out <= ram[addr_r];
            if (we)
              begin
                ram[addr_w] <= data_in;
              end
          end
      end
    else
      begin
        reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
        always @(posedge clk)
          begin
            data_out <= ram[addr_r];
            if (we)
              begin
                ram[addr_w] <= data_in;
              end
          end
      end
  endgenerate

endmodule
