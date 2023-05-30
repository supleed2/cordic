`default_nettype none

module cordic
( input  var [15:0] i_qph // 16-bit unsigned, representing 0-90 degrees
, output var [15:0] o_sin // 16-bit unsigned, representing 0-1
);

// Gain is 1.164435, 2^16 / 1.164435 = 56281.37... = 0xDBD9
logic [15:0] i_x;
logic [15:0] i_y;
always_comb i_x = i_qph[15] ? 16'h0000 : 16'hDBD9;
always_comb i_y = i_qph[15] ? 16'hDBD9 : 16'h0000;

// Cordic angle table
logic [22:0] cordic_angle [0:18];
always_comb cordic_angle[ 0] = 23'h25C80A; // 26.565051 degrees
always_comb cordic_angle[ 1] = 23'h13F670; // 14.036243 degrees
always_comb cordic_angle[ 2] = 23'h0A2223; //  7.125016 degrees
always_comb cordic_angle[ 3] = 23'h05161A; //  3.576334 degrees
always_comb cordic_angle[ 4] = 23'h028BAF; //  1.789911 degrees
always_comb cordic_angle[ 5] = 23'h0145EC; //  0.895174 degrees
always_comb cordic_angle[ 6] = 23'h00A2F8; //  0.447614 degrees
always_comb cordic_angle[ 7] = 23'h00517C; //  0.223811 degrees
always_comb cordic_angle[ 8] = 23'h0028BE; //  0.111906 degrees
always_comb cordic_angle[ 9] = 23'h00145F; //  0.055953 degrees
always_comb cordic_angle[10] = 23'h000A2F; //  0.027976 degrees
always_comb cordic_angle[11] = 23'h000517; //  0.013988 degrees
always_comb cordic_angle[12] = 23'h00028B; //  0.006994 degrees
always_comb cordic_angle[13] = 23'h000145; //  0.003497 degrees
always_comb cordic_angle[14] = 23'h0000A2; //  0.001749 degrees
always_comb cordic_angle[15] = 23'h000051; //  0.000874 degrees
always_comb cordic_angle[16] = 23'h000028; //  0.000437 degrees
always_comb cordic_angle[17] = 23'h000014; //  0.000219 degrees
always_comb cordic_angle[18] = 23'h00000A; //  0.000109 degrees

/* verilator lint_off UNOPTFLAT */
logic [18:0] x [0:19];
logic [18:0] y [0:19];
logic [22:0] p [0:19];
/* verilator lint_on UNOPTFLAT */

// Extend input from input to working widths
always_comb x[0] = {1'b0, i_x, {2{1'b0}}};
always_comb y[0] = {1'b0, i_y, {2{1'b0}}};
always_comb p[0] = {i_qph, {7{1'b0}}};
  // Max pos = 23'h3FFF80, Max neg = 23'h400000

/* verilator lint_off ALWCOMBORDER */
for (genvar i = 0; i < 19; i = i + 1) begin: l_cordic_steps
  // If phase is negative, rotate CW, otherwise CCW
  always_comb
    if (p[i][22]) begin
      x[i+1] = x[i] + (y[i] >>> (i+1));
      y[i+1] = y[i] - (x[i] >>> (i+1));
      p[i+1] = p[i] + cordic_angle[i];
    end else begin
      x[i+1] = x[i] - (y[i] >>> (i+1));
      y[i+1] = y[i] + (x[i] >>> (i+1));
      p[i+1] = p[i] - cordic_angle[i];
    end
end
/* verilator lint_on ALWCOMBORDER */

always_comb
  if (i_qph > 16'd65508)   o_sin = 16'hFFFE;
  else if (i_qph < 16'd32) o_sin = i_qph + (i_qph >> 1);
  else                     o_sin = y[19][17:2];

endmodule
