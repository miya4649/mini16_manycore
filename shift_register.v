// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2023 miya All rights reserved.

/*
 parameter DELAY >= 2
 'dout' is 'DELAY' clock cycle delay of 'din'
 */

module shift_register
  #(
    parameter DELAY = 2
    )
  (
   input wire  clk,
   input wire  din,
   output wire dout
   );

  reg [DELAY-1:0] sreg;

  always @(posedge clk)
    begin
      sreg <= {sreg[DELAY-2:0], din};
    end

  assign dout = sreg[DELAY-1];

endmodule
