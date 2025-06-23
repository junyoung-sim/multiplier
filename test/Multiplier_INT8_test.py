from TestUtil import *

#===========================================================

INT_MIN = -pow(2, 7)
INT_MAX = (pow(2, 7) - 1)

def rand_8b_full():
  return random.randint(INT_MIN, INT_MAX)

def rand_8b_pos():
  return random.randint(0, INT_MAX)

def rand_8b_neg():
  return random.randint(INT_MIN, 0)

def rand_8b_small_pos():
  return random.randint(0, 31)

def rand_8b_small_neg():
  return random.randint(-31, 0)

def rand_8b_large_pos():
  return random.randint(32, INT_MAX)

def rand_8b_large_neg():
  return random.randint(INT_MIN, -32)

def rand_8b(sel):
  if(sel == 0):
    return rand_8b_full()
  elif(sel == 1):
    return rand_8b_pos()
  elif(sel == 2):
    return rand_8b_neg()
  elif(sel == 3):
    return rand_8b_small_pos()
  elif(sel == 4):
    return rand_8b_small_neg()
  elif(sel == 5):
    return rand_8b_large_pos()
  else:
    return rand_8b_large_neg()

def signed(x, nbits):
  if(x >= 0):
    return x
  else:
    return (x + (1 << nbits))

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

#===========================================================

@cocotb.test()
async def test_case_2_directed_istream(dut):
  clock = init_clock(dut)

  for sel in [0, 1, 2, 3, 4, 5, 6]:
    N = 1000

    a = []
    b = []
    c = []

    for t in range(N):
      _a = rand_8b(sel)
      _b = rand_8b(sel)
      _c = (_a * _b)

      a.append(signed(_a, 8))
      b.append(signed(_b, 8))
      c.append(signed(_c, 16))

    i = 0
    j = 0
    t = 0

    out = 0b00000000

    await reset(dut)

    while(j < N):
      await check (
        dut, 0, (i < N), 
        (a[i] if(i < N) else 0),
        (b[i] if(i < N) else 0), out
      )
      
      i += 1
      t += 1

      if(t >= 5):
        out = c[j]
        j += 1

#===========================================================

@cocotb.test()
async def test_case_3_random_istream(dut):
  clock = init_clock(dut)

  for sel in [0, 1, 2, 3, 4, 5, 6]:
    N = 1000

    a = []
    b = []
    c = []
    t = []

    for i in range(N):
      _a = rand_8b(sel)
      _b = rand_8b(sel)
      _c = (_a * _b)

      a.append(signed(_a, 8))
      b.append(signed(_b, 8))
      c.append(signed(_c, 16))
      t.append(0)
    
    out = 0b00000000

    i = 0
    j = 0
    k = 0

    await reset(dut)

    while(j < N):
      en = ((i < N) & random.randint(0, 1))
      await check (
        dut, 0, en,
        (a[i] if(en) else 0),
        (b[i] if(en) else 0), out
      )
      
      i += en

      for l in range(N):
        t[l] += (t[l] > 0)
      
      if(k < N):
        t[k] = en
        k += en

      if(t[j] == 5):
        out = c[j]
        j += 1

#===========================================================