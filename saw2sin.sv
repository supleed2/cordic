`default_nettype none

module saw2sin
( input  var [15:0] i_saw
, output var [15:0] o_sin
);

logic invert;
always_comb invert = i_saw[15];

logic reverse;
always_comb reverse = i_saw[14];

logic [15:0] qsaw;
always_comb qsaw = reverse
  ? {~i_saw[13:0], 2'b11} // Reverse
  : {i_saw[13:0], 2'b01}; // Normal

logic [15:0] qsin;
cordic cordic
( .i_qph (qsaw)
, .o_sin (qsin)
);

logic [16:0] sin;
always_comb sin = reverse
  ? (invert ? ~{1'b1, qsin[15:0]}          // Reverse, Invert
            : {1'b1, qsin[15:0]} + 17'd1)  // Reverse, Normal
  : (invert ? ~{1'b1, qsin[15:0]} + 17'd2  // Normal, Invert
            : {1'b1, qsin[15:0]} + 17'd0); // Normal, Normal

always_comb o_sin = sin[16:1];

endmodule
