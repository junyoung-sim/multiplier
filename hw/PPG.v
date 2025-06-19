`ifndef PPG_V
`define PPG_V

module PPG
#(
  parameter NBITS = 8,
  parameter PBITS = (NBITS * 2)
)(
  input  logic signed [NBITS-1:0] a,
  input  logic signed [NBITS-1:0] b,
  output logic signed [PBITS-1:0] out [NBITS]
);

  typedef logic signed [PBITS-1:0] pbits_t;

  pbits_t pp [NBITS];

  always_comb begin
    for(int i = 0; i < NBITS; i++) begin
      pp[i] = 0;
      for(int j = 0; j < NBITS; j++) begin
        pp[i] |= pbits_t'((a[j] & b[i]) << (i+j));
      end
      pp[i][NBITS-1+i] = ~pp[i][NBITS-1+i];
    end

    pp[0] |= pbits_t'(1'b1 << NBITS);

    pp[NBITS-1][PBITS-2:NBITS-1] = ~pp[NBITS-1][PBITS-2:NBITS-1];
    pp[NBITS-1] |= pbits_t'(1'b1 << (PBITS-1));
  end

  always_comb begin
    for(int i = 0; i < NBITS; i++) begin
      out[i] = pp[i];
    end
  end

endmodule

`endif