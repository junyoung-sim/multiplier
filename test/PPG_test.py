from TestUtil import *

#======================================================================

NBITS = 8

#======================================================================

async def check(dut, in0, in1, prod_0, prod_i: [], prod_N):
  dut.in0.value = in0
  dut.in1.value = in1

  await Timer(1, units="ns")

  assert (dut.prod_0.value == prod_0),         \
    "[FAILED] dut.prod_0 != prod_0 ({} != {})" \
    .format(dut.prod_0.value, bin(prod_0))

  for i in range(1, NBITS-1, 1):
    assert (dut.prod_i[i-1].value == prod_i[i-1]),           \
      "[FAILED] dut.prod_i[{}] != prod_i[{}] ({} != {})"     \
      .format(i-1, i-1, dut.prod_i[i-1].value, bin(prod_i[i-1]))
    
  assert (dut.prod_N.value == prod_N),         \
    "[FAILED] dut.prod_N != prod_N ({} != {})" \
    .format(dut.prod_N.value, bin(prod_N))

#======================================================================

@cocotb.test()
async def test_case_1_simple_zeros(dut):
  in0 = 0b00000000
  in1 = 0b00000000
  out = [
    0b110000000,
    0b10000000,
    0b10000000,
    0b10000000,
    0b10000000,
    0b10000000,
    0b10000000,
    0b101111111
  ]
  await check(dut, in0, in1, out[0], out[1:NBITS-1], out[NBITS-1])

#======================================================================

@cocotb.test()
async def test_case_2_simple_ones(dut):
  in0 = 0b11111111
  in1 = 0b11111111
  out = [
    0b101111111,
    0b01111111,
    0b01111111,
    0b01111111,
    0b01111111,
    0b01111111,
    0b01111111,
    0b110000000
  ]
  await check(dut, in0, in1, out[0], out[1:NBITS-1], out[NBITS-1])