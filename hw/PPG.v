`ifndef PPG_V
`define PPG_V

module PPG
#(
  parameter int NBITS = 8
)(
  input  logic signed [NBITS-1:0] in0,              // input 0
  input  logic signed [NBITS-1:0] in1,              // input 1
  output logic signed [NBITS:0]   prod_0,           // first partial product
  output logic signed [NBITS-1:0] prod_i [NBITS-2], // middle partial products
  output logic signed [NBITS:0]   prod_N            // last partial product
);

  localparam int PBITS = NBITS*2;

  // first partial product (i = 0)
  always_comb begin
    prod_0 = (1'b1 << NBITS);
    for(int i = 0; i < NBITS; i++) begin
      prod_0[i] = (in0[i] & in1[0]);
    end
    prod_0[NBITS-1] = ~prod_0[NBITS-1];
  end

  // middle partial products (i = 1, ... , N-2)
  always_comb begin
    for(int i = 1; i < NBITS-1; i++) begin
      prod_i[i-1] = '0; // initialize
      for(int j = 0; j < NBITS; j++) begin
        prod_i[i-1][j] = (in0[j] & in1[i]);
      end
      prod_i[i-1][NBITS-1] = ~prod_i[i-1][NBITS-1];
    end
  end

  // last partial product (i = N-1)
  always_comb begin
    prod_N = (1'b1 << NBITS);
    for(int i = 0; i < NBITS; i++) begin
      prod_N[i] = (in0[i] & in1[NBITS-1]);
    end
    prod_N[NBITS-2:0] = ~prod_N[NBITS-2:0];
  end

endmodule

`endif