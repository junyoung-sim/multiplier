from TestUtil import *

#===========================================================

async def reset(dut):
  dut.rst.value = 1
  await RisingEdge(dut.clk)
  dut.rst.value = 0

async def check(dut, rst, en0, in0, in1, out):
  dut.rst.value = rst
  dut.en0.value = en0
  dut.in0.value = in0
  dut.in1.value = in1

  await RisingEdge(dut.clk)

  assert (dut.out.value == out)

#===========================================================

@cocotb.test()
async def test_case_1_simple(dut):
  clock = init_clock(dut)

  await reset(dut)

  await check(dut, 0, 1, 0b00000001, 0b00000001, 0b00000000) # 0
  await check(dut, 0, 1, 0b00000000, 0b00000000, 0b00000000) # 0 1
  await check(dut, 0, 1, 0b00000001, 0b00000001, 0b00000000) # 0 1 2
  await check(dut, 0, 1, 0b00000000, 0b00000000, 0b00000000) # 0 1 2 3
  await check(dut, 0, 0, 0b00000000, 0b00000000, 0b00000000) # 0 1 2 3
  await check(dut, 0, 0, 0b00000000, 0b00000000, 0b00000001) # 0 1 2 3
  await check(dut, 0, 0, 0b00000000, 0b00000000, 0b00000000) #   1 2 3
  await check(dut, 0, 0, 0b00000000, 0b00000000, 0b00000001) #     2 3
  await check(dut, 0, 0, 0b00000000, 0b00000000, 0b00000000) #       3