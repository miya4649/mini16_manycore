// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2015 miya All rights reserved.

// ver. 2024/06/01

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
      begin: gen
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
      begin: gen
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
      begin: gen
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
      begin: gen
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
      begin: gen
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
      begin: gen
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
      begin: gen
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
