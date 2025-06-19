`ifndef MULTIPLIER_INT8_V
`define MULTIPLIER_INT8_V

`include "Reg.v"
`include "PPG.v"
`include "Adder.v"
`include "INT16_8.v"

module Multiplier_INT8
(
  input  logic              clk,
  input  logic              rst,
  input  logic              en0,
  input  logic signed [7:0] in0,
  input  logic signed [7:0] in1,
  output logic signed [7:0] out
);

  genvar i;

  //==========================================================
  // Pipeline Enables
  //==========================================================

  logic en [5];

  assign en[0] = en0;

  generate
    for(i = 1; i < 5; i++) begin: g_en_reg
      Reg #(1) en_reg
      (
        .clk (clk),
        .rst (rst),
        .en  (1'b1),
        .d   (en[i-1]),
        .q   (en[i])
      );
    end
  endgenerate
  
  //==========================================================
  // Stage 0: Input
  //==========================================================

  logic signed [7:0] a;
  logic signed [7:0] b;

  Reg #(8) a_reg
  (
    .clk (clk),
    .rst (rst),
    .en  (en[0]),
    .d   (in0),
    .q   (a)
  );

  Reg #(8) b_reg
  (
    .clk (clk),
    .rst (rst),
    .en  (en[0]),
    .d   (in1),
    .q   (b)
  );

  //==========================================================
  // Stage 1: Partial Product Generation
  //==========================================================

  logic signed [15:0] pp [2][8];

  PPG #(8) ppg
  (
    .a   (a),
    .b   (b),
    .out (pp[0])
  );

  generate
    for(i = 0; i < 8; i++) begin: g_pp_reg
      Reg #(16) pp_reg
      (
        .clk (clk),
        .rst (rst),
        .en  (en[1]),
        .d   (pp[0][i]),
        .q   (pp[1][i])
      );
    end
  endgenerate

  //==========================================================
  // Stage 2-4: Accumulation
  //==========================================================

  `define ACC(ADD_ID, N, IN, REG_ID, CLK, RST, EN, OUT) \
    generate                                            \
      for(i = 0; i < N; i += 2) begin: ADD_ID           \
        Adder #(16) acc_adder                           \
        (                                               \
          .in0 (IN[i]),                                 \
          .in1 (IN[i+1]),                               \
          .out (OUT[0][i/2])                            \
        );                                              \
      end                                               \
      for(i = 0; i < N/2; i++) begin: REG_ID            \
        Reg #(16) acc_reg                               \
        (                                               \
          .clk (CLK),                                   \
          .rst (RST),                                   \
          .en  (EN),                                    \
          .d   (OUT[0][i]),                             \
          .q   (OUT[1][i])                              \
        );                                              \
      end                                               \
    endgenerate

  logic signed [15:0] s0 [2][4];
  logic signed [15:0] s1 [2][2];
  logic signed [15:0] s2 [2][1];

  `ACC(g_s0_adder, 8, pp[1], g_s0_reg, clk, rst, en[2], s0)
  `ACC(g_s1_adder, 4, s0[1], g_s1_reg, clk, rst, en[3], s1)
  `ACC(g_s2_adder, 2, s1[1], g_s2_reg, clk, rst, en[4], s2)

  //==========================================================
  // Stage 5: Saturate
  //==========================================================

  INT16_8 int16_8
  (
    .int16 (s2[1][0]),
    .int8  (out)
  );

endmodule

`endif