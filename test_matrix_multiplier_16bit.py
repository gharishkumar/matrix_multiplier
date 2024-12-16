import cocotb
from cocotb.triggers import Timer
import numpy as np

@cocotb.test()
async def test_matrix_multiplier_16bit(dut):
    # Define input matrices using numpy
    A = np.array([[1, 2], [3, 4]], dtype=np.int16)
    B = np.array([[5, 6], [7, 8]], dtype=np.int16)

    # Assign inputs to the DUT
    for i in range(2):
        for j in range(2):
            dut.matA_in[i][j].value = int(A[i][j])
            dut.matB_in[i][j].value = int(B[i][j])

    # Wait for some time to allow for multiplication to occur
    await Timer(10, units='ns')

    # Compute the expected result using numpy
    C_expected = np.dot(A, B)

    # Check the result
    for i in range(2):
        for j in range(2):
            assert dut.result_out[i][j].value == int(C_expected[i][j]), f"Expected {int(C_expected[i][j])}, got {dut.result_out[i][j].value}"
