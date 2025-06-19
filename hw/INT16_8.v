`ifndef INT16_8_v
`define INT16_8_v

module INT16_8
(
  input  logic signed [15:0] int16,
  output logic signed [7:0]  int8
);

  always_comb begin
    if(int16 > 127)
      int8 = 127;
    else if(int16 < -128)
      int8 = -128;
    else
      int8 = int16[7:0];
  end

endmodule

`endif