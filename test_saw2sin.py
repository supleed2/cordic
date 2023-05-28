import cocotb
from cocotb.triggers import Timer
from math import sin, cos, pi

@cocotb.test()
async def test_new_cordic(dut):
    """Test that cordic matches sin"""

    diff = 0
    for cycle in range(0, 65536):
        dut.i_saw.value = cycle
        await Timer(1, units='ps')
        e_sin = 32768 * (sin((cycle * pi) / (2**15)) + 1)
        error = e_sin - dut.o_sin.value
        if abs(error) > 4:
            dut._log.info("cycle %d: expected %d, got %d, error %d"
                % (cycle, e_sin, dut.o_sin.value, error))
        diff += abs(error)

    dut._log.info("Testbench finished, average error %f" % (diff / 65536))