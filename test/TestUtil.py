import random
import cocotb
import subprocess

from fixedpt import Fixed
from cocotb.triggers import *
from cocotb.clock import Clock

#===========================================================

def init_clock(dut):
  return cocotb.start_soon (
    Clock(dut.clk, 1, units="ns").start(start_high=False)
  )

#===========================================================
