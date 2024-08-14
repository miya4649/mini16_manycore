// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2015 miya All rights reserved.

/*
 ver. 2024/04/21
 write delay: immediately
 read delay: 2 clock cycle
*/

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

  reg [(ADDR_WIDTH-1):0]         read_addr_reg;
  always @(posedge read_clock)
    begin
      read_addr_reg <= read_addr;
    end

  generate
    if (RAM_TYPE == "xi_distributed")
      begin: gen
        (* ram_style = "distributed" *) reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
        always @(posedge read_clock)
          begin
            data_out <= ram[read_addr_reg];
          end
        always @(posedge write_clock)
          begin
            if (we)
              begin
                ram[write_addr] <= data_in;
              end
          end
      end
    else if (RAM_TYPE == "xi_block")
      begin: gen
        (* ram_style = "block" *) reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
        always @(posedge read_clock)
          begin
            data_out <= ram[read_addr_reg];
          end
        always @(posedge write_clock)
          begin
            if (we)
              begin
                ram[write_addr] <= data_in;
              end
          end
      end
    else if (RAM_TYPE == "xi_register")
      begin: gen
        (* ram_style = "register" *) reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
        always @(posedge read_clock)
          begin
            data_out <= ram[read_addr_reg];
          end
        always @(posedge write_clock)
          begin
            if (we)
              begin
                ram[write_addr] <= data_in;
              end
          end
      end
    else if (RAM_TYPE == "xi_ultra")
      begin: gen
        (* ram_style = "ultra" *) reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
        always @(posedge read_clock)
          begin
            data_out <= ram[read_addr_reg];
          end
        always @(posedge write_clock)
          begin
            if (we)
              begin
                ram[write_addr] <= data_in;
              end
          end
      end
    else if (RAM_TYPE == "al_logic")
      begin: gen
        (* ramstyle = "logic" *) reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
        always @(posedge read_clock)
          begin
            data_out <= ram[read_addr_reg];
          end
        always @(posedge write_clock)
          begin
            if (we)
              begin
                ram[write_addr] <= data_in;
              end
          end
      end
    else if (RAM_TYPE == "al_mlab")
      begin: gen
        (* ramstyle = "MLAB" *) reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
        always @(posedge read_clock)
          begin
            data_out <= ram[read_addr_reg];
          end
        always @(posedge write_clock)
          begin
            if (we)
              begin
                ram[write_addr] <= data_in;
              end
          end
      end
    else
      begin: gen
        reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];
        always @(posedge read_clock)
          begin
            data_out <= ram[read_addr_reg];
          end
        always @(posedge write_clock)
          begin
            if (we)
              begin
                ram[write_addr] <= data_in;
              end
          end
      end
  endgenerate

endmodule
