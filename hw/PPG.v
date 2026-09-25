`ifndef PPG_V
`define PPG_V

module PPG
#(
  parameter int NBITS = 8
)(
  input  logic signed [NBITS-1:0]   a,
  input  logic signed [NBITS-1:0]   b,
  output logic signed [2*NBITS-1:0] out [NBITS]
);

  localparam int PBITS = NBITS*2;

  always_comb begin
    // generate AND terms
    for(int i = 0; i < NBITS; i++) begin
      out[i] = '0;
      for(int j = 0; j < NBITS; j++) begin
        out[i][j+i] = (a[i] & b[j]);
      end
    end

    // invert select AND term(s)
    for(int i = 0; i < NBITS-1; i++) begin
      out[i][NBITS-1+i] = ~out[i][NBITS-1+i];
    end
    out[NBITS-1][PBITS-3:NBITS-1] = ~out[NBITS-1][PBITS-3:NBITS-1];

    // add constants
    out[0][NBITS]         = 1'b1;
    out[NBITS-1][PBITS-1] = 1'b1;
  end

endmodule

`endif