`ifndef MULTIPLIER_INT8_V
`define MULTIPLIER_INT8_V

`include "Reg.v"
`include "PPG.v"
`include "Adder.v"

module Multiplier_INT8
(
  input  logic               clk,
  input  logic               rst,
  input  logic               en0,
  input  logic signed [7:0]  in0,
  input  logic signed [7:0]  in1,
  output logic signed [15:0] out
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

  logic signed [7:0] _in0;
  logic signed [7:0] _in1;

  Reg #(8) in0_reg
  (
    .clk (clk),
    .rst (rst),
    .en  (en[0]),
    .d   (in0),
    .q   (_in0)
  );

  Reg #(8) in1_reg
  (
    .clk (clk),
    .rst (rst),
    .en  (en[0]),
    .d   (in1),
    .q   (_in1)
  );

  //==========================================================
  // Stage 1: Partial Product Generation
  //==========================================================

  //logic signed [15:0] pp [2][8];

  logic signed [8:0] prod_0 [2];
  logic signed [7:0] prod_i [2][6];
  logic signed [8:0] prod_7 [2];

  PPG #(8) ppg
  (
    .in0    (_in0),
    .in1    (_in1),
    .prod_0 (prod_0[0]),
    .prod_i (prod_i[0]),
    .prod_N (prod_7[0])
  );

  `define PP_REG(NBITS, IN, OUT, REG_ID) \
    generate                             \
      Reg #(NBITS) pp_reg                \
      (                                  \
        .clk (clk),                      \
        .rst (rst),                      \
        .en  (en[1]),                    \
        .in  (IN),                       \
        .out (OUT)                       \
      );                                 \
    endgenerate
  
  PP_REG(9, prod_0[0],    prod_0[1],    g_prod_0_reg);
  PP_REG(8, prod_i[0][0], prod_i[1][0], g_prod_1_reg); // (<< 1)
  PP_REG(8, prod_i[0][1], prod_i[1][1], g_prod_2_reg); // (<< 2)
  PP_REG(8, prod_i[0][2], prod_i[1][2], g_prod_3_reg); // (<< 3)
  PP_REG(8, prod_i[0][3], prod_i[1][3], g_prod_4_reg); // (<< 4)
  PP_REG(8, prod_i[0][4], prod_i[1][4], g_prod_5_reg); // (<< 5)
  PP_REG(8, prod_i[0][5], prod_i[1][5], g_prod_6_reg); // (<< 6)
  PP_REG(9, prod_7[0],    prod_7[1],    g_prod_7_reg); // (<< 7)

  /*generate
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
  endgenerate*/

  //==========================================================
  // Stage 2-4: Accumulation
  //==========================================================

  `define ACC(CLK, RST, EN, N, IN, OUT, ADD_ID, REG_ID) \
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

  `ACC(clk, rst, en[2], 8, pp[1], s0, g_s0_adder, g_s0_reg)
  `ACC(clk, rst, en[3], 4, s0[1], s1, g_s1_adder, g_s1_reg)
  `ACC(clk, rst, en[4], 2, s1[1], s2, g_s2_adder, g_s2_reg)

  assign out = s2[1][0];

endmodule

`endif