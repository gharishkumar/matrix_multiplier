import cocotb
from cocotb.triggers import Timer
from cocotb.regression import TestFactory

@cocotb.test()
async def test_matrix_multiplier_16bit(dut):
    # Define input matrices
    A = [[1, 2], [3, 4]]
    B = [[5, 6], [7, 8]]

    # Assign inputs to the DUT
    for i in range(2):
        for j in range(2):
            dut.matA_in[i][j].value = A[i][j]
            dut.matB_in[i][j].value = B[i][j]

    # Wait for some time to allow for multiplication to occur
    await Timer(10, units='ns')

    # Check the result
    C_expected = [[19, 22], [43, 50]]
    for i in range(2):
        for j in range(2):
            assert dut.result_out[i][j].value == C_expected[i][j], f"Expected {C_expected[i][j]}, got {dut.result_out[i][j].value}"

# Create a TestFactory and register the test
factory = TestFactory(test_matrix_multiplier_16bit)
factory.generate_tests()
