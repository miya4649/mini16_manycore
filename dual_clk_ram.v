/*
  Copyright (c) 2015 miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
 dual_clk_ram ver.2
 write delay: immediately
 read delay: 2 clock cycle
*/

`ifndef RAM_TYPE_DISTRIBUTED
  `define RAM_TYPE_DISTRIBUTED "distributed"
`endif

module dual_clk_ram
  #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 12,
    parameter RAM_TYPE = "auto"
    )
  (
   input wire [(DATA_WIDTH-1):0] data_in,
   input wire [(ADDR_WIDTH-1):0] read_addr,
   input wire [(ADDR_WIDTH-1):0] write_addr,
   input wire                    we,
   input wire                    read_clock,
   input wire                    write_clock,
   output reg [(DATA_WIDTH-1):0] data_out
   );

  generate
    if (RAM_TYPE == "distributed")
      begin: gen
        (* ramstyle = `RAM_TYPE_DISTRIBUTED *) reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
      end
    else
      begin: gen
        reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
      end
  endgenerate

  reg [(ADDR_WIDTH-1):0]         read_addr_reg;

  always @(posedge read_clock)
    begin
      read_addr_reg <= read_addr;
      data_out <= gen.ram[read_addr_reg];
    end

  always @(posedge write_clock)
    begin
      if (we)
        begin
          gen.ram[write_addr] <= data_in;
        end
    end

endmodule
