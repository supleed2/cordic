import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from math import sin, cos, pi

@cocotb.test()
async def test_new_cordic(dut):
    """Test that cordic matches sin"""

    await cocotb.start(Clock(dut.i_clk, 10, units='ps').start())
    diff = 0
    for cycle in range(0, 65536):
        dut.i_saw.value = cycle
        await Timer(20, units='ps')
        e_sin = 32768 * (sin((cycle * pi) / (2**15)) + 1)
        error = float(dut.o_sin.value) - e_sin
        if abs(error) > 2:
            dut._log.info("cycle %5d, rev %d, inv %d, expected %5d, got %5d, error %+.6f"
                % (cycle, (cycle & 0x4000) != 0, (cycle & 0x8000) != 0, e_sin, dut.o_sin.value, error))
        diff += abs(error)

    dut._log.info("Testbench finished, average error %f" % (diff / 65536))
