/*
  Copyright (c) 2023, miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

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
