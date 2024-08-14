// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2023 miya All rights reserved.

// ver. 2024/04/21

module cdc_synchronizer
  #(
    parameter DATA_WIDTH = 8,
    parameter SYNC_TIMES = 3,
    parameter SMOOTH_TIMES = 1
    )
  (
   // clock domain (in) ------------------
   input wire [(DATA_WIDTH-1):0] data_in,
   // clock domain (out)------------------
   output reg [(DATA_WIDTH-1):0] data_out,
   input wire                    clk
   // ------------------------------------
   );

  generate
    genvar                       i;
    wire [(SMOOTH_TIMES-1):0]    smooth;
    reg [(DATA_WIDTH-1):0]       sync_data[SYNC_TIMES:0];

    always @(posedge clk)
      begin
        sync_data[0] <= data_in;
      end

    for (i = 0; i < SYNC_TIMES; i = i + 1)
      begin: sync_block
        always @(posedge clk)
          begin
            sync_data[i + 1] <= sync_data[i];
          end
      end

    for (i = 0; i < SMOOTH_TIMES; i = i + 1)
      begin: smooth_block
        assign smooth[i] = (sync_data[SYNC_TIMES - i - 1] == sync_data[SYNC_TIMES - i]);
      end

    always @(posedge clk)
      begin
        if (smooth == {SMOOTH_TIMES{1'b1}})
          begin
            data_out <= sync_data[SYNC_TIMES];
          end
      end
  endgenerate

endmodule
